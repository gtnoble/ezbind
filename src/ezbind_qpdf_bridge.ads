------------------------------------------------------------------------
--  EZBIND_QPDF_BRIDGE
------------------------------------------------------------------------
with System;
package Ezbind_QPDF_Bridge is
   type Input_Handle is private;
   type Output_Handle is private;
   type Page_Descriptor is record
      Visual_Width  : Long_Float;
      Visual_Height : Long_Float;
   end record;
   function Open_Input (Path : in String; Input : out Input_Handle; Page_Count : out Natural) return Boolean;
   function Get_Page_Descriptor (Input : in Input_Handle; Source_Index : in Natural; Descriptor : out Page_Descriptor) return Boolean;
   function Create_Output (Width : in Long_Float; Height : in Long_Float; Output : out Output_Handle) return Boolean;
   function Begin_Page (Output : in Output_Handle) return Boolean;
   function Place_Page
     (Input : in Input_Handle; Source_Index : in Natural; Output : in Output_Handle;
      Crop_Left : in Long_Float; Crop_Bottom : in Long_Float; Crop_Right : in Long_Float; Crop_Top : in Long_Float;
      Left : in Long_Float; Bottom : in Long_Float; Right : in Long_Float; Top : in Long_Float) return Boolean;
   function Append_Line (Output : in Output_Handle; X1 : in Long_Float; Y1 : in Long_Float; X2 : in Long_Float; Y2 : in Long_Float) return Boolean;
   function Write_Output (Output : in Output_Handle; Path : in String) return Boolean;
   procedure Close (Input : in out Input_Handle);
   procedure Close (Output : in out Output_Handle);
private
   type Input_Handle is new System.Address;
   type Output_Handle is new System.Address;
end Ezbind_QPDF_Bridge;
