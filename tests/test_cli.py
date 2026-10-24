#!/usr/bin/env python3
"""Executable-level regression tests for ezbind's public command-line contract."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
FIXTURES = ROOT / "tests" / "fixtures"
USAGE = "Usage: ezbind COMMAND [OPTIONS]"
TEXT_USAGE = "Usage: ezbind text [OPTIONS] INPUT.pdf OUTPUT.pdf"
COVER_USAGE = (
    "Usage: ezbind cover [OPTIONS] --front FRONT.svg --back BACK.svg OUTPUT.pdf"
)


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
            [str(cls.exe), "cover", "--front", str(FIXTURES / "cover-front.svg"),
             "--back", str(FIXTURES / "cover-back.svg"), str(cls.source_pdf)],
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode != 0 or not cls.source_pdf.is_file():
            cls.fixture_dir.cleanup()
            raise RuntimeError(
                "could not create isolated PDF fixture with cover command:\n"
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

    def assert_usage_error(self, result, usage=None):
        if usage is None:
            command = result.args[1] if len(result.args) > 1 else ""
            usage = {"text": TEXT_USAGE, "cover": COVER_USAGE}.get(command, USAGE)
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertEqual(result.stdout, "")
        self.assertEqual(result.stderr.splitlines()[-1], usage)

    def assert_success(self, result):
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stderr, "")

    def assert_valid_pdf(self, path):
        self.assertTrue(path.is_file(), f"missing output PDF: {path}")
        self.assertGreater(path.stat().st_size, 0)
        self.assertTrue(path.read_bytes().startswith(b"%PDF-"), f"not a PDF: {path}")

    def assert_output_does_not_disclose_sources(self, result):
        transcript = result.stdout + result.stderr
        for path in (self.input_pdf, self.front, self.back):
            self.assertNotIn(str(path), transcript)
            self.assertNotIn(str(path.resolve()), transcript)

    def assert_no_temp_output(self):
        self.assertFalse(list(self.dir.glob("*.ezbind.tmp")))

    def test_help_usage_and_standalone_only(self):
        for args, first_line in (
            (("--help",), USAGE), (("-h",), USAGE),
            (("text", "--help"), TEXT_USAGE), (("text", "-h"), TEXT_USAGE),
            (("cover", "--help"), COVER_USAGE), (("cover", "-h"), COVER_USAGE),
        ):
            with self.subTest(args=args):
                result = self.run_cli(*args)
                self.assert_success(result)
                self.assertEqual(result.stdout.splitlines()[0], first_line)
        global_help = self.run_cli("--help").stdout
        self.assertIn("text   ", global_help)
        self.assertIn("cover  ", global_help)
        text_help = self.run_cli("text", "--help").stdout
        for option in ("--front", "--back"):
            self.assertNotIn(option, text_help)
        cover_help = self.run_cli("cover", "--help").stdout
        for option in ("--crop", "--grid", "--margin"):
            self.assertNotIn(option, cover_help)
        for args in (("--help", "text"), ("text", "--help", self.input_pdf),
                     ("cover", "--help", "--front", self.front),
                     ("unknown", "--help")):
            with self.subTest(args=args):
                self.assert_usage_error(self.run_cli(*args))

    def test_missing_unknown_and_legacy_commands_are_usage_errors(self):
        for args in ((), ("unknown",), ("--sheet", "letter", self.input_pdf,
                                         self.dir / "output.pdf"),
                     (self.input_pdf, self.dir / "legacy.pdf")):
            with self.subTest(args=args):
                self.assert_usage_error(self.run_cli(*args))

    def test_text_path_arities_empty_and_oversized_paths(self):
        cases = (
            (("text",), TEXT_USAGE),
            (("text", self.input_pdf), TEXT_USAGE),
            (("text", self.input_pdf, self.dir / "one.pdf", self.dir / "extra.pdf"), TEXT_USAGE),
            (("text", "", self.dir / "empty-input.pdf"), TEXT_USAGE),
            (("text", self.input_pdf, ""), TEXT_USAGE),
            (("text", self.input_pdf, "x" * 1025), TEXT_USAGE),
            (("text", "x" * 1025, self.dir / "output.pdf"), TEXT_USAGE),
        )
        for args, usage in cases:
            with self.subTest(args=args[:2]):
                self.assert_usage_error(self.run_cli(*args), usage)

    def test_text_generation_replacement_and_path_aliases(self):
        output = self.dir / "folio.pdf"
        for prior in (None, b"pre-existing sentinel"):
            if prior is not None:
                output.write_bytes(prior)
            result = self.run_cli("text", self.input_pdf, output)
            self.assert_success(result)
            self.assert_valid_pdf(output)
            if prior is not None:
                self.assertNotEqual(output.read_bytes(), prior)
        self.assertNotIn(str(self.input_pdf), result.stdout + result.stderr)
        (self.dir / "nested").mkdir()
        for destination in (self.input_pdf, self.dir / "." / "input.pdf",
                            self.dir / "nested" / ".." / "input.pdf"):
            with self.subTest(destination=destination):
                self.assert_usage_error(self.run_cli("text", self.input_pdf, destination))

    def test_cover_generation_replacement_and_path_validation(self):
        output = self.dir / "cover.pdf"
        valid = ("cover", "--front", self.front, "--back", self.back, output)
        result = self.run_cli(*valid)
        self.assert_success(result)
        self.assert_valid_pdf(output)
        self.assert_output_does_not_disclose_sources(result)
        output.write_bytes(b"cover sentinel")
        result = self.run_cli(*valid)
        self.assert_success(result)
        self.assert_valid_pdf(output)
        self.assertNotEqual(output.read_bytes(), b"cover sentinel")
        invalid_cases = (
            ("cover",), ("cover", output),
            ("cover", "--front", self.front, output),
            ("cover", "--back", self.back, output),
            ("cover", "--front", self.front, "--back", self.back),
            (*valid, self.dir / "extra.pdf"),
            ("cover", "--front"),
            ("cover", "--back"),
            ("cover", "--front", self.front, "--back", self.back, output,
             "--front"),
            ("cover", "--front", "", "--back", self.back, output),
            ("cover", "--front", "x" * 1025, "--back", self.back, output),
            ("cover", "--front", self.front, "--back", "", output),
            ("cover", "--front", self.front, "--back", "x" * 1025, output),
            ("cover", "--front", self.front, "--back", self.back, ""),
            ("cover", "--front", self.front, "--back", self.back, "x" * 1025),
        )
        for args in invalid_cases:
            with self.subTest(args=args[:4]):
                self.assert_usage_error(self.run_cli(*args))

    def test_shared_sheet_option_values_and_cover_interspersing(self):
        text_prefix = ("text", self.input_pdf, self.dir / "text.pdf")
        cover_prefix = ("cover", "--front", self.front, "--back", self.back,
                        self.dir / "cover.pdf")
        for prefix in (text_prefix, cover_prefix):
            command = prefix[0]
            for args in (("--sheet", "legal"), ("-s", "")):
                with self.subTest(command=command, args=args):
                    self.assert_usage_error(self.run_cli(command, *args, *prefix[1:]))
            with self.subTest(command=command, missing="long"):
                self.assert_usage_error(self.run_cli(*prefix, "--sheet"))
            with self.subTest(command=command, missing="short"):
                self.assert_usage_error(self.run_cli(*prefix, "-s"))
        text = self.dir / "sheet-text.pdf"
        result = self.run_cli("text", self.input_pdf, "--sheet", "a4", text)
        self.assert_success(result)
        self.assert_valid_pdf(text)
        cover = self.dir / "sheet-cover.pdf"
        result = self.run_cli("cover", "--front", self.front, "--sheet", "letter",
                              "--back", self.back, cover)
        self.assert_success(result)
        self.assert_valid_pdf(cover)
        dash_output = self.dir / "-cover-output.pdf"
        result = self.run_cli("cover", "--front", self.front, "--back", self.back,
                              "--", dash_output.name)
        self.assert_success(result)
        self.assert_valid_pdf(dash_output)

    def test_all_mode_specific_options_are_rejected_by_other_mode(self):
        text_options = (
            ("--grid",), ("-g",), ("--grid-spacing", "1mm"), ("-G", "1mm"),
            ("--crop-top", "1mm"), ("--crop-bottom", "1mm"),
            ("--crop-left", "1mm"), ("--crop-right", "1mm"),
            ("--margin-top", "1mm"), ("-t", "1mm"),
            ("--margin-bottom", "1mm"), ("-b", "1mm"),
            ("--margin-fore-edge", "1mm"), ("-e", "1mm"),
            ("--margin-spine", "1mm"), ("-i", "1mm"),
        )
        text_input = (self.input_pdf, self.dir / "text.pdf")
        cover_args = ("--front", self.front, "--back", self.back,
                      self.dir / "cover.pdf")
        for option in text_options:
            with self.subTest(mode="cover", option=option):
                self.assert_usage_error(self.run_cli("cover", *option, *cover_args))
        for flag in ("--front", "--back", "--cover-front", "--cover-back",
                     "--cover-output"):
            args = ("text", *text_input, flag, self.front)
            with self.subTest(mode="text", flag=flag):
                self.assert_usage_error(self.run_cli(*args))
        for flag in ("-o", "--output", "-f", "--force"):
            sentinel = self.dir / "legacy-sentinel.pdf"
            sentinel.write_bytes(b"untouched sentinel")
            result = self.run_cli("text", self.input_pdf, flag, sentinel)
            self.assert_usage_error(result)
            self.assertEqual(sentinel.read_bytes(), b"untouched sentinel")

    def test_text_options_interspersed_and_dash_paths(self):
        output = self.dir / "options.pdf"
        result = self.run_cli("text", "--grid", "-G", "2mm", self.input_pdf,
                              "-s", "a4", "--crop-top", "1mm", output)
        self.assert_success(result)
        self.assert_valid_pdf(output)
        dash_input = self.dir / "-source.pdf"
        dash_output = self.dir / "-result.pdf"
        dash_input.write_bytes(self.input_pdf.read_bytes())
        result = self.run_cli("text", "--", dash_input.name, dash_output.name)
        self.assert_success(result)
        self.assert_valid_pdf(dash_output)

    def test_two_command_workflow_keeps_outputs_independent(self):
        text_output = self.dir / "text.pdf"
        cover_output = self.dir / "cover.pdf"
        self.assert_success(self.run_cli("text", self.input_pdf, text_output))
        text_bytes = text_output.read_bytes()
        self.assert_success(self.run_cli("cover", "--front", self.front,
                                         "--back", self.back, cover_output))
        self.assertEqual(text_output.read_bytes(), text_bytes)
        cover_bytes = cover_output.read_bytes()
        self.assert_success(self.run_cli("text", "--sheet", "a4",
                                         self.input_pdf, text_output))
        self.assertEqual(cover_output.read_bytes(), cover_bytes)
        failure = self.run_cli("cover", "--front", self.dir / "missing.svg",
                               "--back", self.back, cover_output)
        self.assertEqual(failure.returncode, 5, failure.stderr)
        self.assertEqual(cover_output.read_bytes(), cover_bytes)
        self.assert_valid_pdf(text_output)
        self.assert_no_temp_output()

    def test_text_physical_options_and_invalid_values(self):
        output = self.dir / "physical-options.pdf"
        options = ("--crop-top", "1mm", "--crop-bottom", "1mm",
                   "--crop-left", "1mm", "--crop-right", "1mm",
                   "--margin-top", "1mm", "--margin-bottom", "1mm",
                   "--margin-fore-edge", "1mm", "--margin-spine", "1mm",
                   "-t", "1mm", "-b", "1mm", "-e", "1mm", "-i", "1mm",
                   "-g", "--grid-spacing", "2mm")
        self.assert_success(self.run_cli("text", *options, self.input_pdf, output))
        for flag in ("--crop-top", "--crop-bottom", "--crop-left", "--crop-right",
                     "--margin-top", "--margin-bottom", "--margin-fore-edge",
                     "--margin-spine", "-t", "-b", "-e", "-i",
                     "--grid-spacing", "-G"):
            for value in ("-1mm", "1", "bogus"):
                with self.subTest(flag=flag, value=value):
                    self.assert_usage_error(self.run_cli(
                        "text", flag, value, self.input_pdf, output))
            with self.subTest(flag=flag, missing=True):
                self.assert_usage_error(self.run_cli(
                    "text", self.input_pdf, output, flag))
        self.assert_usage_error(self.run_cli(
            "text", "--grid-spacing", "0mm", self.input_pdf, output))
        prior = output.read_bytes()
        for flag in ("--crop-left", "--margin-spine"):
            with self.subTest(impossible=flag):
                result = self.run_cli("text", flag, "100in", self.input_pdf, output)
                self.assertEqual(result.returncode, 4, result.stderr)
                self.assertEqual(output.read_bytes(), prior)
                self.assert_no_temp_output()

    def test_malformed_pdf_preserves_destination_and_cleans_temp(self):
        invalid = self.dir / "invalid.pdf"
        invalid.write_bytes(b"not a PDF")
        output = self.dir / "existing.pdf"
        output.write_bytes(b"PDF sentinel")
        result = self.run_cli("text", invalid, output)
        self.assertEqual(result.returncode, 3, result.stderr)
        self.assertEqual(output.read_bytes(), b"PDF sentinel")
        self.assert_no_temp_output()

    def test_missing_svg_preserves_destination_and_cleans_temp(self):
        output = self.dir / "cover.pdf"
        output.write_bytes(b"cover sentinel")
        result = self.run_cli("cover", "--front", self.dir / "missing.svg",
                              "--back", self.back, output)
        self.assertEqual(result.returncode, 5, result.stderr)
        self.assertEqual(output.read_bytes(), b"cover sentinel")
        self.assert_no_temp_output()

    def test_failed_output_commit_preserves_destination_and_cleans_temp(self):
        for command, args in (
            ("text", (self.input_pdf,)),
            ("cover", ("--front", self.front, "--back", self.back)),
        ):
            with self.subTest(command=command):
                destination = self.dir / f"{command}-directory.pdf"
                destination.mkdir()
                marker = destination / "sentinel"
                marker.write_bytes(b"directory sentinel")
                result = self.run_cli(command, *args, destination)
                self.assertEqual(result.returncode, 5, result.stderr)
                self.assertEqual(marker.read_bytes(), b"directory sentinel")
                self.assert_no_temp_output()

    def test_missing_input_failure_preserves_destination_and_cleans_temp(self):
        output = self.dir / "folio.pdf"
        output.write_bytes(b"folio sentinel")
        result = self.run_cli("text", self.dir / "missing.pdf", output)
        self.assertEqual(result.returncode, 3, result.stderr)
        self.assertEqual(output.read_bytes(), b"folio sentinel")
        self.assert_no_temp_output()

    def test_cover_render_failure_preserves_destination_and_cleans_temp(self):
        invalid_svg = self.dir / "invalid.svg"
        invalid_svg.write_text("<svg><unclosed>", encoding="utf-8")
        output = self.dir / "cover.pdf"
        output.write_bytes(b"cover sentinel")
        result = self.run_cli("cover", "--front", invalid_svg, "--back", self.back,
                              output)
        self.assertEqual(result.returncode, 5, result.stderr)
        self.assertEqual(output.read_bytes(), b"cover sentinel")
        self.assert_no_temp_output()

    def test_symbolic_link_and_source_artwork_collisions_are_rejected(self):
        input_link = self.dir / "input-link.pdf"
        input_link.symlink_to(self.input_pdf)
        self.assert_usage_error(self.run_cli("text", self.input_pdf, input_link))
        copied_svg = self.dir / "front-copy.svg"
        copied_svg.write_bytes(self.front.read_bytes())
        svg_link = self.dir / "front-link.svg"
        svg_link.symlink_to(copied_svg)
        self.assert_usage_error(self.run_cli("cover", "--front", copied_svg,
                                             "--back", self.back, svg_link))


if __name__ == "__main__":
    unittest.main(verbosity=2)
