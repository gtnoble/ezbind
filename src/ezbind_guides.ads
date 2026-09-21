--  ----------------------------------------------------------------------
--  EZBIND_GUIDES
--
--  Purpose:
--   Calculate vector line counts for margin grids and physical guides.
--  ----------------------------------------------------------------------
with Ezbind_Geometry;

package Ezbind_Guides is
   function Grid_Line_Count
     (Region  : in Ezbind_Geometry.Rectangle;
      Spacing : in Ezbind_Geometry.Coordinate) return Natural;
end Ezbind_Guides;
