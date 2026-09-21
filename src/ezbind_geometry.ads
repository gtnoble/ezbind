--  ----------------------------------------------------------------------
--  EZBIND_GEOMETRY
--
--  Purpose:
--   Validate sheet layout dimensions and calculate finished-page regions.
--  ----------------------------------------------------------------------
with Ezbind_Physical;

package Ezbind_Geometry is
   subtype Coordinate is Ezbind_Physical.Point_Value;

   type Rectangle is record
      Left   : Coordinate;
      Bottom : Coordinate;
      Right  : Coordinate;
      Top    : Coordinate;
   end record;

   type Margins is record
      Top       : Coordinate;
      Bottom    : Coordinate;
      Fore_Edge : Coordinate;
      Spine     : Coordinate;
   end record;

   type Sheet_Layout is record
      Sheet         : Rectangle;
      Left_Page     : Rectangle;
      Right_Page    : Rectangle;
      Left_Content  : Rectangle;
      Right_Content : Rectangle;
   end record;

   function Width (Region : in Rectangle) return Coordinate;
   function Height (Region : in Rectangle) return Coordinate;

   function Contains
     (Outer : in Rectangle;
      Inner : in Rectangle) return Boolean;

   function Is_Valid (Region : in Rectangle) return Boolean;
   function Is_Valid (Layout : in Sheet_Layout) return Boolean;

   function Create_Layout
     (Sheet_Width   : in Coordinate;
      Sheet_Height  : in Coordinate;
      Page_Width    : in Coordinate;
      Page_Height   : in Coordinate;
      Page_Margins  : in Margins) return Sheet_Layout;
end Ezbind_Geometry;
