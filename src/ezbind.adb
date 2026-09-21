------------------------------------------------------------------------
--  EZBIND
--
--  Purpose:
--   Command-line entry point for ezbind.
------------------------------------------------------------------------
with Ada.Command_Line;
with Ezbind_Application;

procedure Ezbind is
begin
   Ada.Command_Line.Set_Exit_Status
     (Ada.Command_Line.Exit_Status (Ezbind_Application.Run));
end Ezbind;
