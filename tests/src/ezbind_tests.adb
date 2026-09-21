with Ada.Command_Line;
with Ada.Text_IO;
with Ezbind_Geometry;
with Ezbind_Imposition;
with Ezbind_Physical;
with Ezbind_QPDF_Bridge;

procedure Ezbind_Tests is
   Input : Ezbind_QPDF_Bridge.Input_Handle;
   Output : Ezbind_QPDF_Bridge.Output_Handle;
   Page_Count : Natural;
   Source_Path : constant String :=
     (if Ada.Command_Line.Argument_Count >= 1
      then Ada.Command_Line.Argument (1)
      else "");
   Output_Path : constant String :=
     (if Ada.Command_Line.Argument_Count >= 2
      then Ada.Command_Line.Argument (2)
      else "/tmp/ezbind-b1-output.pdf");
   use type Ezbind_Physical.Point_Value;

   Layout : constant Ezbind_Geometry.Sheet_Layout :=
     Ezbind_Geometry.Create_Layout
       (Sheet_Width => 792.0,
        Sheet_Height => 612.0,
        Page_Width => 396.0,
        Page_Height => 612.0,
        Page_Margins =>
          (Top => 36.0, Bottom => 36.0,
           Fore_Edge => 36.0, Spine => 48.0));
   Placements : constant Ezbind_Imposition.Placement_Array :=
     Ezbind_Imposition.Create_Placements (4, Layout);
begin
   if Ezbind_Physical.To_Points
        ((Value => 25.4, Unit => Ezbind_Physical.Millimetre)) /= 72.0
   then
      raise Program_Error with "millimetre conversion failed";
   end if;

   if Ezbind_Imposition.Required_Page_Count (5) /= 8 then
      raise Program_Error with "padding failed";
   end if;

   if not Ezbind_Geometry.Is_Valid (Layout)
     or else Placements (1).Source_Page /= 1
     or else Placements (4).Source_Page /= 4
   then
      raise Program_Error with "layout or placement failed";
   end if;

   if Source_Path /= "" then
      if not Ezbind_QPDF_Bridge.Open_Input
        (Source_Path, Input, Page_Count)
        or else Page_Count = 0
      then
         raise Program_Error with "qpdf input open failed";
      end if;

      if not Ezbind_QPDF_Bridge.Create_Output (612.0, 792.0, Output)
        or else not Ezbind_QPDF_Bridge.Place_Page
          (Input, 0, Output, 0.0, 0.0, 612.0, 792.0)
        or else not Ezbind_QPDF_Bridge.Append_Line
          (Output, 36.0, 36.0, 576.0, 36.0)
        or else not Ezbind_QPDF_Bridge.Write_Output (Output, Output_Path)
      then
         Ezbind_QPDF_Bridge.Close (Input);
         Ezbind_QPDF_Bridge.Close (Output);
         raise Program_Error with "qpdf smoke test failed";
      end if;

      Ezbind_QPDF_Bridge.Close (Input);
      Ezbind_QPDF_Bridge.Close (Output);
      Ada.Text_IO.Put_Line ("B1 qpdf bridge test passed.");
   end if;

   Ada.Text_IO.Put_Line ("B1 Ada core tests passed.");
end Ezbind_Tests;
