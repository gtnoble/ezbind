--  ----------------------------------------------------------------------
--  EZBIND_CLI
--
--  Purpose:
--   Define the public usage and help behavior of the ezbind command.
--  ----------------------------------------------------------------------
package Ezbind_CLI is
   Usage_Line : constant String :=
     "Usage: ezbind [OPTIONS] INPUT.pdf OUTPUT.pdf";

   procedure Print_Help;
   procedure Print_Usage_Error (Message : String);
end Ezbind_CLI;
