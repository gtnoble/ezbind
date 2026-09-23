------------------------------------------------------------------------
--  EZBIND_CLI
------------------------------------------------------------------------
with Ada.Text_IO;

package body Ezbind_CLI is
   procedure Print_Help is
   begin
      Ada.Text_IO.Put_Line (Usage_Line);
      Ada.Text_IO.Put_Line
        ("  --help, -h       Show this help text.");
      Ada.Text_IO.Put_Line
        ("  -o PATH, --output PATH  Write the imposed PDF to PATH.");
      Ada.Text_IO.Put_Line
        ("  -s letter|a4, --sheet letter|a4  Select the physical output sheet.");
      Ada.Text_IO.Put_Line
        ("  -g, --grid             Draw a margin grid (default spacing 5 mm).");
      Ada.Text_IO.Put_Line
        ("  -G V, --grid-spacing V  Set positive grid spacing in mm, in, or pt.");
      Ada.Text_IO.Put_Line
        ("  --crop-top V; --crop-bottom V; --crop-left V; --crop-right V");
      Ada.Text_IO.Put_Line
        ("                   Remove source-page edges; visual edges, no auto-crop.");
      Ada.Text_IO.Put_Line
        ("  -t V, --margin-top V; -b V, --margin-bottom V,");
      Ada.Text_IO.Put_Line
        ("  -e V, --margin-fore-edge V; -i V, --margin-spine V");
      Ada.Text_IO.Put_Line
        ("                   Minimum clearance; uniform fit, no crop/distortion.");
      Ada.Text_IO.Put_Line
        ("  -f, --force            Replace an existing output file.");
      Ada.Text_IO.Put_Line
        ("  --cover-front PATH     SVG artwork for the front cover.");
      Ada.Text_IO.Put_Line
        ("  --cover-back PATH      SVG artwork for the back cover.");
      Ada.Text_IO.Put_Line
        ("  --cover-output PATH    Separate one-sheet cover PDF output.");
      Ada.Text_IO.Put_Line
        ("                         Cover output is back-left/front-right.");
      Ada.Text_IO.Put_Line
        ("                         Cover-only mode omits INPUT.pdf and --output.");
      Ada.Text_IO.Put_Line
        ("Exit statuses: 0 success, 2 usage, 3 input, 4 layout,");
      Ada.Text_IO.Put_Line ("5 output, 6 dependency, 10 internal error.");
   end Print_Help;

   procedure Print_Usage_Error (Message : String) is
   begin
      Ada.Text_IO.Put_Line (Ada.Text_IO.Standard_Error, "ezbind: " & Message);
      Ada.Text_IO.Put_Line (Ada.Text_IO.Standard_Error, Usage_Line);
   end Print_Usage_Error;
end Ezbind_CLI;
