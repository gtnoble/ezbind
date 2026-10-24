------------------------------------------------------------------------
--  EZBIND_CLI
------------------------------------------------------------------------
with Ada.Text_IO;

package body Ezbind_CLI is
   procedure Print_Help (Command : in String := "") is
      use Ada.Text_IO;
   begin
      if Command = "text" then
         Put_Line (Text_Usage_Line);
         Put_Line ("  Prepare a duplex-printable folded text block.");
         Put_Line ("  -g, --grid             Draw a margin grid (default 5 mm).");
         Put_Line ("  -G V, --grid-spacing V  Positive spacing in mm, in, or pt.");
         Put_Line ("  --crop-top V; --crop-bottom V; --crop-left V; --crop-right V");
         Put_Line ("                         Remove source-page visual edges.");
         Put_Line ("  -t V, --margin-top V; -b V, --margin-bottom V");
         Put_Line ("  -e V, --margin-fore-edge V; -i V, --margin-spine V");
         Put_Line ("                         Output margins; uniform content fit.");
         Put_Line ("  Physical values require mm, in, or pt; defaults are zero.");
      elsif Command = "cover" then
         Put_Line (Cover_Usage_Line);
         Put_Line ("  --front PATH    Required front-cover SVG artwork.");
         Put_Line ("  --back PATH     Required back-cover SVG artwork.");
         Put_Line ("  Write one landscape sheet: back-left, front-right,");
         Put_Line ("  with a dashed center cut guide.");
      else
         Put_Line (Usage_Line);
         Put_Line ("  text   Prepare a PDF text block for duplex printing.");
         Put_Line ("  cover  Render front/back SVGs to a cardstock cover PDF.");
         Put_Line ("  Run ezbind text --help or ezbind cover --help for options.");
      end if;
      Put_Line ("  -h, --help                Show help on its own.");
      Put_Line ("  -s, --sheet letter|a4     Physical sheet (default letter).");
      Put_Line ("  --                       End options; remaining args are paths.");
      Put_Line ("  Existing outputs are replaced without prompting.");
      Put_Line ("Exit statuses: 0 success, 2 usage, 3 input, 4 layout,");
      Put_Line ("5 output, 6 dependency, 10 internal error.");
   end Print_Help;

   procedure Print_Usage_Error
     (Message : in String;
      Command : in String := "") is
   begin
      Ada.Text_IO.Put_Line (Ada.Text_IO.Standard_Error, "ezbind: " & Message);
      if Command = "text" then
         Ada.Text_IO.Put_Line (Ada.Text_IO.Standard_Error, Text_Usage_Line);
      elsif Command = "cover" then
         Ada.Text_IO.Put_Line (Ada.Text_IO.Standard_Error, Cover_Usage_Line);
      else
         Ada.Text_IO.Put_Line (Ada.Text_IO.Standard_Error, Usage_Line);
      end if;
   end Print_Usage_Error;
end Ezbind_CLI;
