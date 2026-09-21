--  ----------------------------------------------------------------------
--  EZBIND_GEOMETRY
--  ----------------------------------------------------------------------
package body Ezbind_Geometry is
   use type Ezbind_Physical.Point_Value;
   function Width (Region : in Rectangle) return Coordinate is
   begin
      return Region.Right - Region.Left;
   end Width;

   function Height (Region : in Rectangle) return Coordinate is
   begin
      return Region.Top - Region.Bottom;
   end Height;

   function Contains
     (Outer : in Rectangle;
      Inner : in Rectangle) return Boolean is
   begin
      return Inner.Left >= Outer.Left
        and then Inner.Bottom >= Outer.Bottom
        and then Inner.Right <= Outer.Right
        and then Inner.Top <= Outer.Top;
   end Contains;

   function Is_Valid (Region : in Rectangle) return Boolean is
   begin
      return Width (Region) > 0.0 and then Height (Region) > 0.0;
   end Is_Valid;

   function Is_Valid (Layout : in Sheet_Layout) return Boolean is
   begin
      return Is_Valid (Layout.Sheet)
        and then Is_Valid (Layout.Left_Page)
        and then Is_Valid (Layout.Right_Page)
        and then Is_Valid (Layout.Left_Content)
        and then Is_Valid (Layout.Right_Content)
        and then Contains (Layout.Sheet, Layout.Left_Page)
        and then Contains (Layout.Sheet, Layout.Right_Page)
        and then Contains (Layout.Left_Page, Layout.Left_Content)
        and then Contains (Layout.Right_Page, Layout.Right_Content);
   end Is_Valid;

   function Create_Layout
     (Sheet_Width   : in Coordinate;
      Sheet_Height  : in Coordinate;
      Page_Width    : in Coordinate;
      Page_Height   : in Coordinate;
      Page_Margins  : in Margins) return Sheet_Layout is
      Sheet : constant Rectangle :=
        (Left => 0.0, Bottom => 0.0,
         Right => Sheet_Width, Top => Sheet_Height);
      Left_Page : constant Rectangle :=
        (Left => 0.0, Bottom => 0.0,
         Right => Page_Width, Top => Page_Height);
      Right_Page : constant Rectangle :=
        (Left => Page_Width, Bottom => 0.0,
         Right => Coordinate (2.0) * Page_Width, Top => Page_Height);
      Left_Content : constant Rectangle :=
        (Left => Page_Margins.Spine,
         Bottom => Page_Margins.Bottom,
         Right => Page_Width - Page_Margins.Fore_Edge,
         Top => Page_Height - Page_Margins.Top);
      Right_Content : constant Rectangle :=
        (Left => Page_Width + Page_Margins.Spine,
         Bottom => Page_Margins.Bottom,
         Right => Coordinate (2.0) * Page_Width - Page_Margins.Fore_Edge,
         Top => Page_Height - Page_Margins.Top);
   begin
      return
        (Sheet => Sheet,
         Left_Page => Left_Page,
         Right_Page => Right_Page,
         Left_Content => Left_Content,
         Right_Content => Right_Content);
   end Create_Layout;
end Ezbind_Geometry;
