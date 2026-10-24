------------------------------------------------------------------------
--  EZBIND_APPLICATION
--
--  Purpose:
--   Validate text/cover commands and create the requested PDF output.
--
--  Effects:
--   Reads a PDF or SVG artwork and writes one PDF on success.
--   Expected failures are reported on standard error and returned as status
--   values; document content is never written to diagnostics.
------------------------------------------------------------------------
package Ezbind_Application is
   function Run return Integer;
end Ezbind_Application;
