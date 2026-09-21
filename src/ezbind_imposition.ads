--  ----------------------------------------------------------------------
--  EZBIND_IMPOSITION
--
--  Purpose:
--   Produce deterministic four-page folded-folio placement records.
--  ----------------------------------------------------------------------
with Ezbind_Geometry;

package Ezbind_Imposition is
   subtype Page_Number is Natural;

   type Side_Kind is (Front, Back);
   type Position_Kind is (Left, Right);

   type Placement is record
      Logical_Page : Page_Number;
      Source_Page  : Page_Number;
      Is_Blank     : Boolean;
      Sheet_Number : Positive;
      Side         : Side_Kind;
      Position     : Position_Kind;
      Region       : Ezbind_Geometry.Rectangle;
   end record;

   type Placement_Array is array (Positive range <>) of Placement;

   function Required_Page_Count
     (Source_Page_Count : in Natural) return Natural;

   function Create_Placements
     (Source_Page_Count : in Natural;
      Layout            : in Ezbind_Geometry.Sheet_Layout)
      return
        Placement_Array;
end Ezbind_Imposition;
