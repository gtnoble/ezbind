#!/usr/bin/env python3
"""Executable-level regression tests for ezbind's public command-line contract."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
FIXTURES = ROOT / "tests" / "fixtures"
USAGE = "Usage: ezbind [OPTIONS] INPUT.pdf OUTPUT.pdf"


def executable_path():
    override = os.environ.get("EZBIND_BIN")
    if override:
        return Path(override).expanduser().resolve()
    return ROOT / "bin" / "ezbind"


class EzbindCliTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.exe = executable_path()
        if not cls.exe.is_file():
            raise unittest.SkipTest(
                f"ezbind executable not found at {cls.exe}; build it before running tests"
            )
        cls.fixture_dir = tempfile.TemporaryDirectory(prefix="ezbind-cli-")
        cls.work = Path(cls.fixture_dir.name)
        cls.source_pdf = cls.work / "fixture-source.pdf"
        result = subprocess.run(
            [
                str(cls.exe),
                "--cover-front", str(FIXTURES / "cover-front.svg"),
                "--cover-back", str(FIXTURES / "cover-back.svg"),
                "--cover-output", str(cls.source_pdf),
            ],
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode != 0 or not cls.source_pdf.is_file():
            cls.fixture_dir.cleanup()
            raise RuntimeError(
                "could not create isolated PDF fixture with cover-only CLI:\n"
                f"status={result.returncode}\nstdout={result.stdout}\nstderr={result.stderr}"
            )

    @classmethod
    def tearDownClass(cls):
        if hasattr(cls, "fixture_dir"):
            cls.fixture_dir.cleanup()

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="ezbind-cli-case-")
        self.dir = Path(self.temp.name)
        self.input_pdf = self.dir / "input.pdf"
        self.input_pdf.write_bytes(self.source_pdf.read_bytes())
        self.front = FIXTURES / "cover-front.svg"
        self.back = FIXTURES / "cover-back.svg"

    def tearDown(self):
        self.temp.cleanup()

    def run_cli(self, *args):
        return subprocess.run(
            [str(self.exe), *(str(arg) for arg in args)],
            capture_output=True,
            text=True,
            check=False,
            cwd=self.dir,
            timeout=15,
        )

    def assert_usage_error(self, result):
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertEqual(result.stdout, "")
        self.assertIn(USAGE, result.stderr)

    def assert_success(self, result):
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stderr, "")

    def assert_valid_pdf(self, path):
        self.assertTrue(path.is_file(), f"missing output PDF: {path}")
        self.assertGreater(path.stat().st_size, 0)
        self.assertTrue(path.read_bytes().startswith(b"%PDF-"), f"not a PDF: {path}")

    def cover_args(self, output):
        return (
            "--cover-front", self.front,
            "--cover-back", self.back,
            "--cover-output", output,
        )

    def test_help_describes_the_new_interface(self):
        for flag in ("-h", "--help"):
            with self.subTest(flag=flag):
                result = self.run_cli(flag)
                self.assert_success(result)
                self.assertEqual(result.stdout.splitlines()[0], USAGE)
                self.assertIn("replaced without prompting", result.stdout)
                self.assertNotIn("--force", result.stdout)
                self.assertNotIn("--output", result.stdout)

    def test_combined_svg_failure_preserves_both_destinations(self):
        folio = self.dir / "folio.pdf"
        cover = self.dir / "cover.pdf"
        folio.write_bytes(b"folio sentinel")
        cover.write_bytes(b"cover sentinel")
        result = self.run_cli(
            "--cover-front", self.dir / "missing.svg",
            "--cover-back", self.back, "--cover-output", cover,
            self.input_pdf, folio,
        )
        self.assertEqual(result.returncode, 5, result.stderr)
        self.assertEqual(folio.read_bytes(), b"folio sentinel")
        self.assertEqual(cover.read_bytes(), b"cover sentinel")
        self.assertFalse(list(self.dir.glob("*.ezbind.tmp")))

    def test_folio_generation_and_unconditional_overwrite(self):
        output = self.dir / "folio.pdf"
        result = self.run_cli(self.input_pdf, output)
        self.assert_success(result)
        self.assert_valid_pdf(output)
        self.assertNotIn(str(self.input_pdf), result.stdout + result.stderr)
        output.write_bytes(b"pre-existing sentinel")
        result = self.run_cli(self.input_pdf, output)
        self.assert_success(result)
        self.assert_valid_pdf(output)
        self.assertNotEqual(output.read_bytes(), b"pre-existing sentinel")

    def test_cover_only_generation_and_unconditional_overwrite(self):
        output = self.dir / "cover.pdf"
        result = self.run_cli(*self.cover_args(output))
        self.assert_success(result)
        self.assert_valid_pdf(output)
        self.assert_output_does_not_disclose_sources(result, output)
        output.write_bytes(b"cover sentinel")
        result = self.run_cli(*self.cover_args(output))
        self.assert_success(result)
        self.assert_valid_pdf(output)
        self.assertNotEqual(output.read_bytes(), b"cover sentinel")

    def test_combined_generation_overwrites_both_outputs(self):
        folio = self.dir / "combined-folio.pdf"
        cover = self.dir / "combined-cover.pdf"
        folio.write_bytes(b"folio sentinel")
        cover.write_bytes(b"cover sentinel")
        result = self.run_cli(
            "--cover-front", self.front,
            self.input_pdf,
            "--cover-back", self.back,
            folio,
            "--cover-output", cover,
        )
        self.assert_success(result)
        self.assert_valid_pdf(folio)
        self.assert_valid_pdf(cover)
        self.assertNotEqual(folio.read_bytes(), b"folio sentinel")
        self.assertNotEqual(cover.read_bytes(), b"cover sentinel")
        self.assert_output_does_not_disclose_sources(result, folio, cover)

    def assert_output_does_not_disclose_sources(self, result, *allowed_outputs):
        transcript = result.stdout + result.stderr
        forbidden = [self.input_pdf, self.front, self.back]
        # Success may identify either destination, but not source paths.
        for path in forbidden:
            self.assertNotIn(str(path), transcript)
            self.assertNotIn(str(path.resolve()), transcript)

    def test_retired_output_and_force_flags_are_usage_errors(self):
        for flag in ("-o", "--output", "-f", "--force"):
            with self.subTest(flag=flag):
                target = self.dir / (flag.replace("-", "") + ".pdf")
                target.write_bytes(b"untouched sentinel")
                result = self.run_cli(self.input_pdf, flag, target)
                self.assert_usage_error(result)
                self.assertEqual(target.read_bytes(), b"untouched sentinel")

    def test_malformed_positional_arity_is_usage_error(self):
        cases = (
            (),
            (self.input_pdf,),
            (self.input_pdf, self.dir / "one.pdf", self.dir / "extra.pdf"),
            ("", self.dir / "empty-input-output.pdf"),
            (self.input_pdf, ""),
            ("--cover-front", self.front, "--cover-back", self.back,
             "--cover-output", self.dir / "cover.pdf", self.input_pdf),
        )
        for args in cases:
            with self.subTest(args=args):
                self.assert_usage_error(self.run_cli(*args))

    def test_oversized_positional_path_is_usage_error(self):
        oversized = "x" * 4096
        self.assert_usage_error(self.run_cli(self.input_pdf, oversized))

    def test_end_of_options_allows_dash_leading_paths(self):
        dash_input = self.dir / "-source.pdf"
        dash_output = self.dir / "-result.pdf"
        dash_input.write_bytes(self.input_pdf.read_bytes())
        result = self.run_cli("--", dash_input.name, dash_output.name)
        self.assert_success(result)
        self.assert_valid_pdf(dash_output)

    def test_interspersed_options_are_accepted(self):
        output = self.dir / "interspersed.pdf"
        result = self.run_cli(
            self.input_pdf, "--sheet", "letter", output,
            "--cover-front", self.front,
            "--cover-back", self.back,
            "--cover-output", self.dir / "interspersed-cover.pdf",
        )
        self.assert_success(result)
        self.assert_valid_pdf(output)
        self.assert_valid_pdf(self.dir / "interspersed-cover.pdf")

    def test_invalid_pdf_does_not_modify_existing_destinations(self):
        invalid = self.dir / "invalid.pdf"
        invalid.write_bytes(b"not a PDF")
        folio = self.dir / "folio-existing.pdf"
        cover = self.dir / "cover-existing.pdf"
        folio.write_bytes(b"folio sentinel")
        cover.write_bytes(b"cover sentinel")
        result = self.run_cli(
            "--cover-front", self.front,
            invalid,
            "--cover-back", self.back,
            folio,
            "--cover-output", cover,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(folio.read_bytes(), b"folio sentinel")
        self.assertEqual(cover.read_bytes(), b"cover sentinel")

    def test_svg_render_failure_does_not_modify_existing_cover(self):
        invalid_svg = self.dir / "invalid.svg"
        invalid_svg.write_text("<svg><unclosed>", encoding="utf-8")
        cover = self.dir / "cover-existing.pdf"
        cover.write_bytes(b"cover sentinel")
        result = self.run_cli(
            "--cover-front", invalid_svg,
            "--cover-back", self.back,
            "--cover-output", cover,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(cover.read_bytes(), b"cover sentinel")

    def test_normalized_path_aliases_are_rejected(self):
        (self.dir / "nested").mkdir()
        output = self.dir / "nested" / ".." / "input.pdf"
        cases = [
            (self.input_pdf, output),
            (self.input_pdf, self.dir / "." / "input.pdf"),
        ]
        for source, destination in cases:
            with self.subTest(destination=destination):
                self.assert_usage_error(self.run_cli(source, destination))

    def test_symbolic_link_aliases_and_source_svg_collisions_are_rejected(self):
        input_link = self.dir / "input-link.pdf"
        input_link.symlink_to(self.input_pdf)
        self.assert_usage_error(self.run_cli(self.input_pdf, input_link))
        copied_svg = self.dir / "front-copy.svg"
        copied_svg.write_bytes(self.front.read_bytes())
        svg_link = self.dir / "front-link.svg"
        svg_link.symlink_to(copied_svg)
        self.assert_usage_error(
            self.run_cli(
                "--cover-front", copied_svg,
                "--cover-back", self.back,
                "--cover-output", svg_link,
            )
        )

    def test_combined_output_collisions_are_rejected(self):
        (self.dir / "nested").mkdir()
        folio = self.dir / "same.pdf"
        cover_alias = self.dir / "nested" / ".." / "same.pdf"
        self.assert_usage_error(
            self.run_cli(
                "--cover-front", self.front,
                self.input_pdf,
                "--cover-back", self.back,
                folio,
                "--cover-output", cover_alias,
            )
        )


if __name__ == "__main__":
    unittest.main(verbosity=2)
