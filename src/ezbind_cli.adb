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
        ("  --output PATH    Write the imposed PDF to PATH.");
      Ada.Text_IO.Put_Line
        ("  --sheet letter|a4  Select the physical output sheet.");
      Ada.Text_IO.Put_Line
        ("  --grid           Draw a 5 mm margin grid.");
      Ada.Text_IO.Put_Line
        ("  --force          Replace an existing output file.");
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
