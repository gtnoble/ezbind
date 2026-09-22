------------------------------------------------------------------------
--  EZBIND_SVG_BRIDGE
------------------------------------------------------------------------
with Interfaces.C;
with Interfaces.C.Strings;
with System;

package body Ezbind_SVG_Bridge is
   use type Interfaces.C.int;
   function C_Render_Cover_Sheet
     (Back_Path   : Interfaces.C.Strings.chars_ptr;
      Front_Path  : Interfaces.C.Strings.chars_ptr;
      Width       : Interfaces.C.double;
      Height      : Interfaces.C.double;
      Output_Path : Interfaces.C.Strings.chars_ptr;
      Error_Text  : System.Address;
      Error_Size  : Interfaces.C.size_t) return Interfaces.C.int
     with Import, Convention => C, External_Name => "ez_svg_render_cover_sheet";

   function Render_Cover_Sheet
     (Back_Path   : in String;
      Front_Path  : in String;
      Width       : in Long_Float;
      Height      : in Long_Float;
      Output_Path : in String) return Boolean is
      C_Back_Path   : Interfaces.C.Strings.chars_ptr :=
        Interfaces.C.Strings.New_String (Back_Path);
      C_Front_Path  : Interfaces.C.Strings.chars_ptr :=
        Interfaces.C.Strings.New_String (Front_Path);
      C_Output_Path : Interfaces.C.Strings.chars_ptr :=
        Interfaces.C.Strings.New_String (Output_Path);
      Status        : Interfaces.C.int;
   begin
      Status := C_Render_Cover_Sheet
        (C_Back_Path, C_Front_Path,
         Interfaces.C.double (Width), Interfaces.C.double (Height),
         C_Output_Path, System.Null_Address, 0);
      Interfaces.C.Strings.Free (C_Back_Path);
      Interfaces.C.Strings.Free (C_Front_Path);
      Interfaces.C.Strings.Free (C_Output_Path);
      return Status = 0;
   exception
      when others =>
         Interfaces.C.Strings.Free (C_Back_Path);
         Interfaces.C.Strings.Free (C_Front_Path);
         Interfaces.C.Strings.Free (C_Output_Path);
         return False;
   end Render_Cover_Sheet;
end Ezbind_SVG_Bridge;
