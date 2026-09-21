--  ----------------------------------------------------------------------
--  EZBIND_PHYSICAL
--
--  Purpose:
--   Parse physical dimensions and represent them in PDF points.
--
--  Effects:
--   Operations are pure calculations and do not access the filesystem.
--  ----------------------------------------------------------------------
package Ezbind_Physical is
   type Unit_Kind is (Millimetre, Inch, Point);

   type Point_Value is digits 12 range -1.0E9 .. 1.0E9;

   type Physical_Value is record
      Value : Point_Value;
      Unit  : Unit_Kind;
   end record;

   function Parse
     (Text   : in String;
      Result : out Physical_Value) return Boolean;

   function To_Points (Value : in Physical_Value) return Point_Value;

   function Millimetres (Value : in Point_Value) return Point_Value;

   function Inches (Value : in Point_Value) return Point_Value;

   function Points (Value : in Point_Value) return Point_Value;
end Ezbind_Physical;
