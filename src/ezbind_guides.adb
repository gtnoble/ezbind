--  ----------------------------------------------------------------------
--  EZBIND_GUIDES
--  ----------------------------------------------------------------------
package body Ezbind_Guides is
   function Grid_Line_Count
     (Region  : in Ezbind_Geometry.Rectangle;
      Spacing : in Ezbind_Geometry.Coordinate) return Natural is
   begin
      if Spacing <= 0.0 or else not Ezbind_Geometry.Is_Valid (Region) then
         return 0;
      else
         return Natural (Ezbind_Geometry.Width (Region) / Spacing)
           + Natural (Ezbind_Geometry.Height (Region) / Spacing);
      end if;
   end Grid_Line_Count;
end Ezbind_Guides;
