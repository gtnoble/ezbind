--  ----------------------------------------------------------------------
--  EZBIND
--
--  Purpose:
--   Command-line entry point for ezbind.
--  ----------------------------------------------------------------------
with Ada.Command_Line;
with Ezbind_CLI;

procedure Ezbind is
begin
   if Ada.Command_Line.Argument_Count = 1
     and then (Ada.Command_Line.Argument (1) = "--help"
               or else Ada.Command_Line.Argument (1) = "-h")
   then
      Ezbind_CLI.Print_Help;
   else
      Ezbind_CLI.Print_Usage_Error ("invalid command-line arguments");
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Exit_Status (2));
   end if;
end Ezbind;
