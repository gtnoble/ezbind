--  ----------------------------------------------------------------------
--  EZBIND_PHYSICAL
--  ----------------------------------------------------------------------
package body Ezbind_Physical is
   Points_Per_Inch : constant Point_Value := 72.0;
   Millimetres_Per_Inch : constant Point_Value := 25.4;

   function Parse
     (Text   : in String;
      Result : out Physical_Value) return Boolean is
      Suffix_Length : Natural := 0;
      Unit          : Unit_Kind := Point;
   begin
      if Text'Length < 3 then
         return False;
      elsif Text (Text'Last - 1 .. Text'Last) = "mm" then
         Suffix_Length := 2;
         Unit := Millimetre;
      elsif Text (Text'Last - 1 .. Text'Last) = "in" then
         Suffix_Length := 2;
         Unit := Inch;
      elsif Text (Text'Last - 1 .. Text'Last) = "pt" then
         Suffix_Length := 2;
         Unit := Point;
      else
         return False;
      end if;

      declare
         Number : constant String :=
           Text (Text'First .. Text'Last - Suffix_Length);
         Parsed : constant Long_Float := Long_Float'Value (Number);
      begin
         if Parsed < 0.0 then
            return False;
         end if;
         Result :=
           (Value => Point_Value (Parsed),
            Unit => Unit);
         return True;
      end;
   exception
      when others =>
         return False;
   end Parse;

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
