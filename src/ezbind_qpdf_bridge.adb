------------------------------------------------------------------------
--  EZBIND_QPDF_BRIDGE
------------------------------------------------------------------------
with Interfaces.C;
with Interfaces.C.Strings;
package body Ezbind_QPDF_Bridge is
   use type Interfaces.C.int;
   function C_Open_Input (Path : Interfaces.C.Strings.chars_ptr; Result : access Input_Handle; Page_Count : access Interfaces.C.size_t; Error_Text : System.Address; Error_Size : Interfaces.C.size_t) return Interfaces.C.int with Import, Convention => C, External_Name => "ez_qpdf_open_input";
   function C_Get_Page_Descriptor (Input : Input_Handle; Source_Index : Interfaces.C.size_t; Visual_Width : access Interfaces.C.double; Visual_Height : access Interfaces.C.double; Error_Text : System.Address; Error_Size : Interfaces.C.size_t) return Interfaces.C.int with Import, Convention => C, External_Name => "ez_qpdf_get_page_descriptor";
   function C_Create_Output (Width : Interfaces.C.double; Height : Interfaces.C.double; Result : access Output_Handle; Error_Text : System.Address; Error_Size : Interfaces.C.size_t) return Interfaces.C.int with Import, Convention => C, External_Name => "ez_qpdf_create_output";
   function C_Begin_Page (Output : Output_Handle; Error_Text : System.Address; Error_Size : Interfaces.C.size_t) return Interfaces.C.int with Import, Convention => C, External_Name => "ez_qpdf_begin_page";
   function C_Place_Page (Input : Input_Handle; Source_Index : Interfaces.C.size_t; Output : Output_Handle; Crop_Left : Interfaces.C.double; Crop_Bottom : Interfaces.C.double; Crop_Right : Interfaces.C.double; Crop_Top : Interfaces.C.double; Left : Interfaces.C.double; Bottom : Interfaces.C.double; Right : Interfaces.C.double; Top : Interfaces.C.double; Error_Text : System.Address; Error_Size : Interfaces.C.size_t) return Interfaces.C.int with Import, Convention => C, External_Name => "ez_qpdf_place_page";
   function C_Append_Line (Output : Output_Handle; X1 : Interfaces.C.double; Y1 : Interfaces.C.double; X2 : Interfaces.C.double; Y2 : Interfaces.C.double; Error_Text : System.Address; Error_Size : Interfaces.C.size_t) return Interfaces.C.int with Import, Convention => C, External_Name => "ez_qpdf_append_line";
   function C_Write_Output (Output : Output_Handle; Path : Interfaces.C.Strings.chars_ptr; Error_Text : System.Address; Error_Size : Interfaces.C.size_t) return Interfaces.C.int with Import, Convention => C, External_Name => "ez_qpdf_write_output";
   procedure C_Close_Input (Input : Input_Handle) with Import, Convention => C, External_Name => "ez_qpdf_close_input";
   procedure C_Close_Output (Output : Output_Handle) with Import, Convention => C, External_Name => "ez_qpdf_close_output";

   function Open_Input (Path : in String; Input : out Input_Handle; Page_Count : out Natural) return Boolean is
      C_Path : Interfaces.C.Strings.chars_ptr := Interfaces.C.Strings.New_String (Path);
      Count : aliased Interfaces.C.size_t := 0;
      Native_Input : aliased Input_Handle := Input_Handle (System.Null_Address);
      Status : Interfaces.C.int;
   begin
      Status := C_Open_Input (C_Path, Native_Input'Access, Count'Access, System.Null_Address, 0);
      Input := Native_Input; Interfaces.C.Strings.Free (C_Path); Page_Count := Natural (Count); return Status = 0;
   end Open_Input;

   function Get_Page_Descriptor (Input : in Input_Handle; Source_Index : in Natural; Descriptor : out Page_Descriptor) return Boolean is
      Width : aliased Interfaces.C.double := 0.0; Height : aliased Interfaces.C.double := 0.0;
   begin
      if C_Get_Page_Descriptor (Input, Interfaces.C.size_t (Source_Index), Width'Access, Height'Access, System.Null_Address, 0) = 0 then
         Descriptor := (Visual_Width => Long_Float (Width), Visual_Height => Long_Float (Height)); return True;
      end if;
      Descriptor := (Visual_Width => 0.0, Visual_Height => 0.0); return False;
   end Get_Page_Descriptor;

   function Create_Output (Width : in Long_Float; Height : in Long_Float; Output : out Output_Handle) return Boolean is
      Native_Output : aliased Output_Handle := Output_Handle (System.Null_Address);
   begin
      if C_Create_Output (Interfaces.C.double (Width), Interfaces.C.double (Height), Native_Output'Access, System.Null_Address, 0) = 0 then Output := Native_Output; return True; end if;
      Output := Output_Handle (System.Null_Address); return False;
   end Create_Output;
   function Begin_Page (Output : in Output_Handle) return Boolean is begin return C_Begin_Page (Output, System.Null_Address, 0) = 0; end Begin_Page;
   function Place_Page (Input : in Input_Handle; Source_Index : in Natural; Output : in Output_Handle; Crop_Left : in Long_Float; Crop_Bottom : in Long_Float; Crop_Right : in Long_Float; Crop_Top : in Long_Float; Left : in Long_Float; Bottom : in Long_Float; Right : in Long_Float; Top : in Long_Float) return Boolean is
   begin
      return C_Place_Page (Input, Interfaces.C.size_t (Source_Index), Output, Interfaces.C.double (Crop_Left), Interfaces.C.double (Crop_Bottom), Interfaces.C.double (Crop_Right), Interfaces.C.double (Crop_Top), Interfaces.C.double (Left), Interfaces.C.double (Bottom), Interfaces.C.double (Right), Interfaces.C.double (Top), System.Null_Address, 0) = 0;
   end Place_Page;
   function Append_Line (Output : in Output_Handle; X1 : in Long_Float; Y1 : in Long_Float; X2 : in Long_Float; Y2 : in Long_Float) return Boolean is
   begin return C_Append_Line (Output, Interfaces.C.double (X1), Interfaces.C.double (Y1), Interfaces.C.double (X2), Interfaces.C.double (Y2), System.Null_Address, 0) = 0; end Append_Line;
   function Write_Output (Output : in Output_Handle; Path : in String) return Boolean is
      C_Path : Interfaces.C.Strings.chars_ptr := Interfaces.C.Strings.New_String (Path); Status : Interfaces.C.int;
   begin Status := C_Write_Output (Output, C_Path, System.Null_Address, 0); Interfaces.C.Strings.Free (C_Path); return Status = 0; end Write_Output;
   procedure Close (Input : in out Input_Handle) is begin if Input /= Input_Handle (System.Null_Address) then C_Close_Input (Input); Input := Input_Handle (System.Null_Address); end if; end Close;
   procedure Close (Output : in out Output_Handle) is begin if Output /= Output_Handle (System.Null_Address) then C_Close_Output (Output); Output := Output_Handle (System.Null_Address); end if; end Close;
end Ezbind_QPDF_Bridge;
