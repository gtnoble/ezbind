--  ----------------------------------------------------------------------
--  EZBIND_CLI
--
--  Purpose:
--   Define the public usage and help behavior of the ezbind command.
--  ----------------------------------------------------------------------
package Ezbind_CLI is
   Usage_Line : constant String := "Usage: ezbind COMMAND [OPTIONS]";
   Text_Usage_Line : constant String :=
     "Usage: ezbind text [OPTIONS] INPUT.pdf OUTPUT.pdf";
   Cover_Usage_Line : constant String :=
     "Usage: ezbind cover [OPTIONS] --front FRONT.svg --back BACK.svg OUTPUT.pdf";

   procedure Print_Help (Command : in String := "");
   procedure Print_Usage_Error
     (Message : in String;
      Command : in String := "");
end Ezbind_CLI;
