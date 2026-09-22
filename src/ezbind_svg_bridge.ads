------------------------------------------------------------------------
--  EZBIND_SVG_BRIDGE
--
--  Purpose:
--    Provide a safe Ada interface to the project-owned librsvg/Cairo bridge.
------------------------------------------------------------------------
package Ezbind_SVG_Bridge is
   function Render_Cover_Sheet
     (Back_Path   : in String;
      Front_Path  : in String;
      Width       : in Long_Float;
      Height      : in Long_Float;
      Output_Path : in String) return Boolean;
end Ezbind_SVG_Bridge;
