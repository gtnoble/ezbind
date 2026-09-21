------------------------------------------------------------------------
--  EZBIND_APPLICATION
--
--  Purpose:
--   Validate command-line options and create an imposed PDF output.
--
--  Effects:
--   Reads one input PDF and writes one output PDF on successful completion.
--   Expected failures are reported on standard error and returned as status
--   values; document content is never written to diagnostics.
------------------------------------------------------------------------
package Ezbind_Application is
   function Run return Integer;
end Ezbind_Application;
