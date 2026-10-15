with Ada.Command_Line;
with Ada.Text_IO;
with Ezbind_Geometry;
with Ezbind_Imposition;
with Ezbind_Physical;
with Ezbind_QPDF_Bridge;
with Ezbind_SVG_Bridge;

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
   Cover_Back_Path : constant String :=
     (if Ada.Command_Line.Argument_Count >= 3
      then Ada.Command_Line.Argument (3)
      else "");
   Cover_Front_Path : constant String :=
     (if Ada.Command_Line.Argument_Count >= 4
      then Ada.Command_Line.Argument (4)
      else "");
   Cover_Output_Path : constant String :=
     (if Ada.Command_Line.Argument_Count >= 5
      then Ada.Command_Line.Argument (5)
      else "/tmp/ezbind-cover-test.pdf");
   use type Ezbind_Physical.Point_Value;
   Parsed : Ezbind_Physical.Physical_Value;

   Layout : constant Ezbind_Geometry.Sheet_Layout :=
     Ezbind_Geometry.Create_Layout
       (Sheet_Width => 792.0,
        Sheet_Height => 612.0,
        Page_Width => 396.0,
        Page_Height => 612.0,
        Page_Margins =>
          (Top => 0.0, Bottom => 0.0,
           Fore_Edge => 0.0, Spine => 0.0));
   Custom_Layout : constant Ezbind_Geometry.Sheet_Layout :=
     Ezbind_Geometry.Create_Layout
       (Sheet_Width => 792.0,
        Sheet_Height => 612.0,
        Page_Width => 396.0,
        Page_Height => 612.0,
        Page_Margins =>
          (Top => 18.0, Bottom => 20.0,
           Fore_Edge => 24.0, Spine => 60.0));
   Placements : constant Ezbind_Imposition.Placement_Array :=
     Ezbind_Imposition.Create_Placements (4, Custom_Layout);
   use type Ezbind_Imposition.Position_Kind;
   use type Ezbind_Imposition.Side_Kind;
begin
   if Ezbind_Physical.To_Points
        ((Value => 25.4, Unit => Ezbind_Physical.Millimetre)) /= 72.0
   then
      raise Program_Error with "millimetre conversion failed";
   end if;

   if not Ezbind_Physical.Parse ("25.4mm", Parsed)
     or else Ezbind_Physical.To_Points (Parsed) /= 72.0
     or else not Ezbind_Physical.Parse ("1in", Parsed)
     or else Ezbind_Physical.To_Points (Parsed) /= 72.0
     or else not Ezbind_Physical.Parse ("72pt", Parsed)
     or else Ezbind_Physical.To_Points (Parsed) /= 72.0
     or else Ezbind_Physical.Parse ("-1mm", Parsed)
     or else Ezbind_Physical.Parse ("72", Parsed)
   then
      raise Program_Error with "physical parser failed";
   end if;

   if Ezbind_Imposition.Required_Page_Count (5) /= 8 then
      raise Program_Error with "padding failed";
   end if;

   if not Ezbind_Geometry.Is_Valid (Layout)
     or else Layout.Left_Content.Left /= 0.0
     or else Layout.Left_Content.Bottom /= 0.0
     or else Layout.Left_Content.Right /= 396.0
     or else Layout.Left_Content.Top /= 612.0
     or else Layout.Right_Content.Left /= 396.0
     or else Layout.Right_Content.Bottom /= 0.0
     or else Layout.Right_Content.Right /= 792.0
     or else Layout.Right_Content.Top /= 612.0
     or else not Ezbind_Geometry.Is_Valid (Custom_Layout)
     or else Custom_Layout.Left_Content.Left /= 24.0
     or else Custom_Layout.Left_Content.Right /= 336.0
     or else Custom_Layout.Right_Content.Left /= 456.0
     or else Custom_Layout.Right_Content.Right /= 768.0
     or else Placements (1).Region.Left /= Custom_Layout.Left_Content.Left
     or else Placements (1).Region.Right /= Custom_Layout.Left_Content.Right
     or else Placements (2).Region.Left /= Custom_Layout.Right_Content.Left
     or else Placements (2).Region.Right /= Custom_Layout.Right_Content.Right
     or else Placements (1).Source_Page /= 4
     or else Placements (2).Source_Page /= 1
     or else Placements (3).Source_Page /= 2
     or else Placements (4).Source_Page /= 3
     or else Placements (1).Side /= Ezbind_Imposition.Front
     or else Placements (2).Position /= Ezbind_Imposition.Right
     or else Placements (3).Side /= Ezbind_Imposition.Back
     or else Placements (4).Position /= Ezbind_Imposition.Right
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

      declare
         Descriptor : Ezbind_QPDF_Bridge.Page_Descriptor;
      begin
         if not Ezbind_QPDF_Bridge.Get_Page_Descriptor
           (Input, 0, Descriptor)
           or else Descriptor.Visual_Width <= 0.0
           or else Descriptor.Visual_Height <= 0.0
         then
            raise Program_Error with "qpdf page descriptor failed";
         end if;
      end;

      if not Ezbind_QPDF_Bridge.Create_Output (612.0, 792.0, Output)
        or else not Ezbind_QPDF_Bridge.Begin_Page (Output)
        or else not Ezbind_QPDF_Bridge.Place_Page
          (Input, 0, Output, 0.0, 0.0, 0.0, 0.0,
           0.0, 0.0, 612.0, 792.0)
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
      Ada.Text_IO.Put_Line ("B2 qpdf bridge test passed.");
   end if;

   if Cover_Back_Path /= "" or else Cover_Front_Path /= "" then
      if Cover_Back_Path = "" or else Cover_Front_Path = ""
        or else not Ezbind_SVG_Bridge.Render_Cover_Sheet
          (Cover_Back_Path, Cover_Front_Path, 792.0, 612.0,
           Cover_Output_Path)
      then
         raise Program_Error with "SVG bridge smoke test failed";
      end if;
      Ada.Text_IO.Put_Line ("librsvg/Cairo cover bridge test passed.");
   end if;

   Ada.Text_IO.Put_Line ("B2 Ada core tests passed.");
end Ezbind_Tests;
