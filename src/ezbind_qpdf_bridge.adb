------------------------------------------------------------------------
--  EZBIND_QPDF_BRIDGE
------------------------------------------------------------------------
with Interfaces.C;
with Interfaces.C.Strings;
with System;

package body Ezbind_QPDF_Bridge is
   use type Interfaces.C.int;

   function C_Open_Input
     (Path       : Interfaces.C.Strings.chars_ptr;
      Result     : access Input_Handle;
      Page_Count : access Interfaces.C.size_t;
      Error_Text : System.Address;
      Error_Size : Interfaces.C.size_t) return Interfaces.C.int
     with Import, Convention => C, External_Name => "ez_qpdf_open_input";

   function C_Create_Output
     (Width      : Interfaces.C.double;
      Height     : Interfaces.C.double;
      Result     : access Output_Handle;
      Error_Text : System.Address;
      Error_Size : Interfaces.C.size_t) return Interfaces.C.int
     with Import, Convention => C, External_Name => "ez_qpdf_create_output";

   function C_Place_Page
     (Input        : Input_Handle;
      Source_Index : Interfaces.C.size_t;
      Output       : Output_Handle;
      Left         : Interfaces.C.double;
      Bottom       : Interfaces.C.double;
      Right        : Interfaces.C.double;
      Top          : Interfaces.C.double;
      Error_Text   : System.Address;
      Error_Size   : Interfaces.C.size_t) return Interfaces.C.int
     with Import, Convention => C, External_Name => "ez_qpdf_place_page";

   function C_Append_Line
     (Output     : Output_Handle;
      X1         : Interfaces.C.double;
      Y1         : Interfaces.C.double;
      X2         : Interfaces.C.double;
      Y2         : Interfaces.C.double;
      Error_Text : System.Address;
      Error_Size : Interfaces.C.size_t) return Interfaces.C.int
     with Import, Convention => C, External_Name => "ez_qpdf_append_line";

   function C_Write_Output
     (Output     : Output_Handle;
      Path       : Interfaces.C.Strings.chars_ptr;
      Error_Text : System.Address;
      Error_Size : Interfaces.C.size_t) return Interfaces.C.int
     with Import, Convention => C, External_Name => "ez_qpdf_write_output";

   procedure C_Close_Input (Input : Input_Handle)
     with Import, Convention => C, External_Name => "ez_qpdf_close_input";

   procedure C_Close_Output (Output : Output_Handle)
     with Import, Convention => C, External_Name => "ez_qpdf_close_output";

   function Open_Input
     (Path       : in String;
      Input      : out Input_Handle;
      Page_Count : out Natural) return Boolean is
      C_Path : Interfaces.C.Strings.chars_ptr :=
        Interfaces.C.Strings.New_String (Path);
      Count : aliased Interfaces.C.size_t := 0;
      Native_Input : aliased Input_Handle :=
        Input_Handle (System.Null_Address);
      Status : Interfaces.C.int;
   begin
      Status := C_Open_Input
        (C_Path, Native_Input'Access, Count'Access, System.Null_Address, 0);
      Input := Native_Input;
      Interfaces.C.Strings.Free (C_Path);
      Page_Count := Natural (Count);
      return Status = 0;
   end Open_Input;

   function Create_Output
     (Width  : in Long_Float;
      Height : in Long_Float;
      Output : out Output_Handle) return Boolean is
   begin
      declare
         Native_Output : aliased Output_Handle :=
           Output_Handle (System.Null_Address);
      begin
         if C_Create_Output
           (Interfaces.C.double (Width), Interfaces.C.double (Height),
            Native_Output'Access, System.Null_Address, 0) = 0
         then
            Output := Native_Output;
            return True;
         else
            return False;
         end if;
      end;
   end Create_Output;

   function Place_Page
     (Input        : in Input_Handle;
      Source_Index : in Natural;
      Output       : in Output_Handle;
      Left         : in Long_Float;
      Bottom       : in Long_Float;
      Right        : in Long_Float;
      Top          : in Long_Float) return Boolean is
   begin
      return C_Place_Page
        (Input, Interfaces.C.size_t (Source_Index), Output,
         Interfaces.C.double (Left), Interfaces.C.double (Bottom),
         Interfaces.C.double (Right), Interfaces.C.double (Top),
         System.Null_Address, 0) = 0;
   end Place_Page;

   function Append_Line
     (Output : in Output_Handle;
      X1     : in Long_Float;
      Y1     : in Long_Float;
      X2     : in Long_Float;
      Y2     : in Long_Float) return Boolean is
   begin
      return C_Append_Line
        (Output, Interfaces.C.double (X1), Interfaces.C.double (Y1),
         Interfaces.C.double (X2), Interfaces.C.double (Y2),
         System.Null_Address, 0) = 0;
   end Append_Line;

   function Write_Output
     (Output : in Output_Handle;
      Path   : in String) return Boolean is
      C_Path : Interfaces.C.Strings.chars_ptr :=
        Interfaces.C.Strings.New_String (Path);
      Status : Interfaces.C.int;
   begin
      Status := C_Write_Output
        (Output, C_Path, System.Null_Address, 0);
      Interfaces.C.Strings.Free (C_Path);
      return Status = 0;
   end Write_Output;

   procedure Close (Input : in out Input_Handle) is
   begin
      C_Close_Input (Input);
      Input := Input_Handle (System.Null_Address);
   end Close;

   procedure Close (Output : in out Output_Handle) is
   begin
      C_Close_Output (Output);
      Output := Output_Handle (System.Null_Address);
   end Close;
end Ezbind_QPDF_Bridge;
