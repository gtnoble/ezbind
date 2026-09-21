--  ----------------------------------------------------------------------
--  EZBIND_PHYSICAL
--  ----------------------------------------------------------------------
package body Ezbind_Physical is
   Points_Per_Inch : constant Point_Value := 72.0;
   Millimetres_Per_Inch : constant Point_Value := 25.4;

   function To_Points (Value : in Physical_Value) return Point_Value is
   begin
      case Value.Unit is
         when Millimetre =>
            return Value.Value * Points_Per_Inch / Millimetres_Per_Inch;
         when Inch =>
            return Value.Value * Points_Per_Inch;
         when Point =>
            return Value.Value;
      end case;
   end To_Points;

   function Millimetres (Value : in Point_Value) return Point_Value is
   begin
      return Value * Millimetres_Per_Inch / Points_Per_Inch;
   end Millimetres;

   function Inches (Value : in Point_Value) return Point_Value is
   begin
      return Value / Points_Per_Inch;
   end Inches;

   function Points (Value : in Point_Value) return Point_Value is
   begin
      return Value;
   end Points;
end Ezbind_Physical;
