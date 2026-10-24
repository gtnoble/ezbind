------------------------------------------------------------------------
--  EZBIND_APPLICATION
------------------------------------------------------------------------
with Ada.Command_Line;
with Ada.Directories;
with Ada.Text_IO;
with GNAT.OS_Lib;
with Ezbind_CLI;
with Ezbind_Geometry;
with Ezbind_Imposition;
with Ezbind_Physical;
with Ezbind_QPDF_Bridge;
with Ezbind_SVG_Bridge;

package body Ezbind_Application is
   use type Ezbind_Imposition.Side_Kind;
   use type Ezbind_Physical.Point_Value;
   type Sheet_Kind is (Letter, A4);

   type Options is record
      Input_Path        : String (1 .. 1024) := (others => ' ');
      Input_Last        : Natural := 0;
      Output_Path       : String (1 .. 1024) := (others => ' ');
      Output_Last       : Natural := 0;
      Cover_Front_Path  : String (1 .. 1024) := (others => ' ');
      Cover_Front_Last  : Natural := 0;
      Cover_Back_Path   : String (1 .. 1024) := (others => ' ');
      Cover_Back_Last   : Natural := 0;
      Cover_Output_Path : String (1 .. 1024) := (others => ' ');
      Cover_Output_Last : Natural := 0;
      Sheet             : Sheet_Kind := Letter;
      Grid              : Boolean := False;
      Crop_Top          : Ezbind_Physical.Point_Value := 0.0;
      Crop_Bottom       : Ezbind_Physical.Point_Value := 0.0;
      Crop_Left         : Ezbind_Physical.Point_Value := 0.0;
      Crop_Right        : Ezbind_Physical.Point_Value := 0.0;
      Top_Margin        : Ezbind_Physical.Point_Value := 0.0;
      Bottom_Margin     : Ezbind_Physical.Point_Value := 0.0;
      Fore_Margin       : Ezbind_Physical.Point_Value := 0.0;
      Spine_Margin      : Ezbind_Physical.Point_Value := 0.0;
      Grid_Spacing      : Ezbind_Physical.Point_Value := 14.1732283464567;
   end record;

   function Value
     (Text : in String;
      Last : in Natural) return String is
   begin
      return Text (Text'First .. Text'First + Last - 1);
   end Value;

   function Set_Path
     (Target : in out String;
      Last   : in out Natural;
      Value  : in String) return Boolean is
   begin
      if Value'Length = 0 or else Value'Length > Target'Length then
         return False;
      end if;
      Target (Target'First .. Target'First + Value'Length - 1) := Value;
      Last := Value'Length;
      return True;
   end Set_Path;

   function Read_Path
     (Option_Name : in String;
      Index       : in out Positive;
      Count       : in Natural;
      Target      : in out String;
      Last        : in out Natural) return Boolean is
   begin
      if Index = Count then
         Ezbind_CLI.Print_Usage_Error (Option_Name & " requires a path");
         return False;
      end if;
      Index := Index + 1;
      if not Set_Path (Target, Last, Ada.Command_Line.Argument (Index)) then
         Ezbind_CLI.Print_Usage_Error (Option_Name & " path is too long or empty");
         return False;
      end if;
      return True;
   end Read_Path;

   function Read_Physical
     (Option_Name : in String;
      Index       : in out Positive;
      Count       : in Natural;
      Result      : out Ezbind_Physical.Point_Value) return Boolean is
   begin
      if Index = Count then
         Ezbind_CLI.Print_Usage_Error (Option_Name & " requires a value in mm, in, or pt");
         return False;
      end if;
      Index := Index + 1;
      declare
         Parsed : Ezbind_Physical.Physical_Value;
      begin
         if not Ezbind_Physical.Parse
           (Ada.Command_Line.Argument (Index), Parsed)
         then
            Ezbind_CLI.Print_Usage_Error
              (Option_Name & " requires a non-negative value in mm, in, or pt");
            return False;
         end if;
         Result := Ezbind_Physical.To_Points (Parsed);
         return True;
      exception
         when others =>
            Ezbind_CLI.Print_Usage_Error
              (Option_Name & " requires a non-negative value in mm, in, or pt");
            return False;
      end;
   end Read_Physical;

   function Parse_Options
     (Result : out Options) return Boolean is
      Index : Positive := 1;
      Count : constant Natural := Ada.Command_Line.Argument_Count;
      Options_Ended : Boolean := False;

      function Same_Path (Left, Right : in String) return Boolean is
      begin
         return Left'Length /= 0 and then Right'Length /= 0
           and then GNAT.OS_Lib.Normalize_Pathname (Left) =
             GNAT.OS_Lib.Normalize_Pathname (Right);
      end Same_Path;

      function Conflicts_With_Source (Path : in String) return Boolean is
      begin
         return Same_Path
           (Path, Value (Result.Input_Path, Result.Input_Last))
           or else Same_Path
             (Path, Value (Result.Cover_Front_Path, Result.Cover_Front_Last))
           or else Same_Path
             (Path, Value (Result.Cover_Back_Path, Result.Cover_Back_Last));
      end Conflicts_With_Source;
   begin
      if Count = 0 then
         Ezbind_CLI.Print_Usage_Error ("input and output PDF paths are required");
         return False;
      end if;

      while Index <= Count loop
         declare
            Argument : constant String := Ada.Command_Line.Argument (Index);
         begin
            if Options_Ended or else Argument'Length = 0
              or else Argument (Argument'First) /= '-'
            then
               if Result.Input_Last = 0 then
                  if not Set_Path
                    (Result.Input_Path, Result.Input_Last, Argument)
                  then
                     Ezbind_CLI.Print_Usage_Error
                       ("input path is too long or empty");
                     return False;
                  end if;
               elsif Result.Output_Last = 0 then
                  if not Set_Path
                    (Result.Output_Path, Result.Output_Last, Argument)
                  then
                     Ezbind_CLI.Print_Usage_Error
                       ("output path is too long or empty");
                     return False;
                  end if;
               else
                  Ezbind_CLI.Print_Usage_Error
                    ("exactly two PDF paths are required: input then output");
                  return False;
               end if;
            elsif Argument = "--" then
               Options_Ended := True;
            elsif Argument = "--cover-front" then
               if not Read_Path
                 ("--cover-front", Index, Count,
                  Result.Cover_Front_Path, Result.Cover_Front_Last)
               then
                  return False;
               end if;
            elsif Argument = "--cover-back" then
               if not Read_Path
                 ("--cover-back", Index, Count,
                  Result.Cover_Back_Path, Result.Cover_Back_Last)
               then
                  return False;
               end if;
            elsif Argument = "--cover-output" then
               if not Read_Path
                 ("--cover-output", Index, Count,
                  Result.Cover_Output_Path, Result.Cover_Output_Last)
               then
                  return False;
               end if;
            elsif Argument = "--grid" or else Argument = "-g" then
               Result.Grid := True;
            elsif Argument = "--grid-spacing" or else Argument = "-G" then
               if not Read_Physical
                 ("--grid-spacing", Index, Count, Result.Grid_Spacing)
                 or else Result.Grid_Spacing <= 0.0
               then
                  Ezbind_CLI.Print_Usage_Error
                    ("--grid-spacing requires a positive value in mm, in, or pt");
                  return False;
               end if;
            elsif Argument = "--crop-top" then
               if not Read_Physical ("--crop-top", Index, Count, Result.Crop_Top) then
                  return False;
               end if;
            elsif Argument = "--crop-bottom" then
               if not Read_Physical ("--crop-bottom", Index, Count, Result.Crop_Bottom) then
                  return False;
               end if;
            elsif Argument = "--crop-left" then
               if not Read_Physical ("--crop-left", Index, Count, Result.Crop_Left) then
                  return False;
               end if;
            elsif Argument = "--crop-right" then
               if not Read_Physical ("--crop-right", Index, Count, Result.Crop_Right) then
                  return False;
               end if;
            elsif Argument = "--margin-top" or else Argument = "-t" then
               if not Read_Physical
                 ("--margin-top", Index, Count, Result.Top_Margin)
               then
                  return False;
               end if;
            elsif Argument = "--margin-bottom" or else Argument = "-b" then
               if not Read_Physical
                 ("--margin-bottom", Index, Count, Result.Bottom_Margin)
               then
                  return False;
               end if;
            elsif Argument = "--margin-fore-edge" or else Argument = "-e" then
               if not Read_Physical
                 ("--margin-fore-edge", Index, Count, Result.Fore_Margin)
               then
                  return False;
               end if;
            elsif Argument = "--margin-spine" or else Argument = "-i" then
               if not Read_Physical
                 ("--margin-spine", Index, Count, Result.Spine_Margin)
               then
                  return False;
               end if;
            elsif Argument = "--sheet" or else Argument = "-s" then
               if Index = Count then
                  Ezbind_CLI.Print_Usage_Error ("--sheet requires letter or a4");
                  return False;
               end if;
               Index := Index + 1;
               declare
                  Sheet : constant String := Ada.Command_Line.Argument (Index);
               begin
                  if Sheet = "letter" then
                     Result.Sheet := Letter;
                  elsif Sheet = "a4" then
                     Result.Sheet := A4;
                  else
                     Ezbind_CLI.Print_Usage_Error
                       ("--sheet accepts only letter or a4");
                     return False;
                  end if;
               end;
            else
               Ezbind_CLI.Print_Usage_Error
                 ("unknown or malformed option: " & Argument);
               return False;
            end if;
         end;
         Index := Index + 1;
      end loop;

      declare
         Cover_Options : constant Boolean :=
           Result.Cover_Front_Last /= 0
           or else Result.Cover_Back_Last /= 0
           or else Result.Cover_Output_Last /= 0;
         Complete_Cover_Options : constant Boolean :=
           Result.Cover_Front_Last /= 0
           and then Result.Cover_Back_Last /= 0
           and then Result.Cover_Output_Last /= 0;
         Cover_Only : constant Boolean :=
           Complete_Cover_Options
           and then Result.Input_Last = 0
           and then Result.Output_Last = 0;
      begin
         if Cover_Options and then not Complete_Cover_Options then
            Ezbind_CLI.Print_Usage_Error
              ("--cover-front, --cover-back, and --cover-output are required together");
            return False;
         end if;

         if not Cover_Only then
            if Result.Input_Last = 0 then
               Ezbind_CLI.Print_Usage_Error ("missing input PDF path");
               return False;
            elsif Result.Output_Last = 0 then
               Ezbind_CLI.Print_Usage_Error ("missing output PDF path");
               return False;
            end if;
         end if;

         if Same_Path
           (Value (Result.Output_Path, Result.Output_Last),
            Value (Result.Cover_Output_Path, Result.Cover_Output_Last))
         then
            Ezbind_CLI.Print_Usage_Error
              ("folio output and --cover-output must name different files");
            return False;
         end if;

         if Conflicts_With_Source
           (Value (Result.Output_Path, Result.Output_Last))
           or else Conflicts_With_Source
             (Value (Result.Cover_Output_Path, Result.Cover_Output_Last))
         then
            Ezbind_CLI.Print_Usage_Error
              ("output paths must not name source PDF or SVG files");
            return False;
         end if;
         return True;
      end;
   end Parse_Options;

   procedure Geometry
     (Selected_Sheet : in Sheet_Kind;
      Sheet_Width    : out Long_Float;
      Sheet_Height   : out Long_Float;
      Page_Width     : out Long_Float;
      Page_Height    : out Long_Float) is
   begin
      case Selected_Sheet is
         when Letter =>
            Sheet_Width := 792.0;
            Sheet_Height := 612.0;
            Page_Width := 396.0;
            Page_Height := 612.0;
         when A4 =>
            Sheet_Width := 841.8897638;
            Sheet_Height := 595.2755906;
            Page_Width := 420.9448819;
            Page_Height := 595.2755906;
      end case;
   end Geometry;

   function Commit_Output
     (Temporary_Path : in String;
      Output_Path    : in String) return Boolean is
      Success : Boolean;
   begin
      --  On Unix, GNAT uses POSIX rename to replace the destination without
      --  deleting it first. Ada.Directories.Rename refuses existing targets.
      GNAT.OS_Lib.Rename_File (Temporary_Path, Output_Path, Success);
      return Success;
   exception
      when others =>
         return False;
   end Commit_Output;

   function Draw_Grid
     (Output  : in Ezbind_QPDF_Bridge.Output_Handle;
      Page    : in Ezbind_Geometry.Rectangle;
      Content : in Ezbind_Geometry.Rectangle;
      Spacing : in Long_Float) return Boolean is
      X    : Long_Float := Long_Float (Page.Left) + Spacing;
      Y    : Long_Float := Long_Float (Page.Bottom) + Spacing;
      Good : Boolean := True;
   begin
      while X < Long_Float (Page.Right) loop
         if X < Long_Float (Content.Left)
           or else X > Long_Float (Content.Right)
         then
            Good := Good and then Ezbind_QPDF_Bridge.Append_Line
              (Output, X, Long_Float (Page.Bottom), X,
               Long_Float (Page.Top));
         end if;
         X := X + Spacing;
      end loop;
      while Y < Long_Float (Page.Top) loop
         if Y < Long_Float (Content.Bottom)
           or else Y > Long_Float (Content.Top)
         then
            Good := Good and then Ezbind_QPDF_Bridge.Append_Line
              (Output, Long_Float (Page.Left), Y,
               Long_Float (Page.Right), Y);
         end if;
         Y := Y + Spacing;
      end loop;
      return Good;
   end Draw_Grid;

   function Produce
     (Settings : in Options) return Integer is
      Input       : Ezbind_QPDF_Bridge.Input_Handle;
      Output      : Ezbind_QPDF_Bridge.Output_Handle;
      Page_Count  : Natural := 0;
      Sheet_Width : Long_Float;
      Sheet_Height : Long_Float;
      Page_Width  : Long_Float;
      Page_Height : Long_Float;
      Margins     : constant Ezbind_Geometry.Margins :=
        (Top => Settings.Top_Margin,
         Bottom => Settings.Bottom_Margin,
         Fore_Edge => Settings.Fore_Margin,
         Spine => Settings.Spine_Margin);
      Cover_Mode : constant Boolean := Settings.Cover_Front_Last /= 0;
      Cover_Only : constant Boolean :=
        Cover_Mode and then Settings.Input_Last = 0;
      Output_Path : constant String :=
        (if Settings.Output_Last /= 0
         then Value (Settings.Output_Path, Settings.Output_Last)
         else Value (Settings.Cover_Output_Path, Settings.Cover_Output_Last));
      Cover_Output_Path : constant String :=
        (if Cover_Mode
         then Value (Settings.Cover_Output_Path, Settings.Cover_Output_Last)
         else Output_Path & ".unused-cover.pdf");
      Temporary_Path : constant String :=
        (if Cover_Only
         then Cover_Output_Path & ".unused-folio.pdf"
         else Output_Path & ".ezbind.tmp");
      Cover_Temporary_Path : constant String := Cover_Output_Path & ".ezbind.tmp";
      Input_Open  : Boolean := False;
      Output_Open : Boolean := False;
      Layout      : Ezbind_Geometry.Sheet_Layout;
      Good        : Boolean := True;
   begin
      Geometry
        (Settings.Sheet, Sheet_Width, Sheet_Height, Page_Width, Page_Height);
      Layout := Ezbind_Geometry.Create_Layout
        (Sheet_Width => Ezbind_Physical.Point_Value (Sheet_Width),
         Sheet_Height => Ezbind_Physical.Point_Value (Sheet_Height),
         Page_Width => Ezbind_Physical.Point_Value (Page_Width),
         Page_Height => Ezbind_Physical.Point_Value (Page_Height),
         Page_Margins => Margins);
      if not Ezbind_Geometry.Is_Valid (Layout) then
         Ada.Text_IO.Put_Line
           (Ada.Text_IO.Standard_Error, "ezbind: requested layout does not fit");
         return 4;
      end if;

      if Cover_Only then
         if not Ezbind_SVG_Bridge.Render_Cover_Sheet
           (Value (Settings.Cover_Back_Path, Settings.Cover_Back_Last),
            Value (Settings.Cover_Front_Path, Settings.Cover_Front_Last),
            Sheet_Width, Sheet_Height, Cover_Temporary_Path)
           or else not Commit_Output
             (Cover_Temporary_Path, Cover_Output_Path)
         then
            if Ada.Directories.Exists (Cover_Temporary_Path) then
               Ada.Directories.Delete_File (Cover_Temporary_Path);
            end if;
            Ada.Text_IO.Put_Line
              (Ada.Text_IO.Standard_Error, "ezbind: cover SVG rendering failed");
            return 5;
         end if;
         Ada.Text_IO.Put_Line ("ezbind: wrote " & Cover_Output_Path);
         return 0;
      end if;

      if not Ezbind_QPDF_Bridge.Open_Input
        (Value (Settings.Input_Path, Settings.Input_Last), Input, Page_Count)
        or else Page_Count = 0
      then
         Ada.Text_IO.Put_Line
           (Ada.Text_IO.Standard_Error, "ezbind: cannot read input PDF");
         return 3;
      end if;
      Input_Open := True;

      declare
         Descriptor : Ezbind_QPDF_Bridge.Page_Descriptor;
      begin
         for Source_Index in 0 .. Page_Count - 1 loop
            if not Ezbind_QPDF_Bridge.Get_Page_Descriptor
              (Input, Source_Index, Descriptor)
            then
               Ezbind_QPDF_Bridge.Close (Input);
               Input_Open := False;
               Ada.Text_IO.Put_Line
                 (Ada.Text_IO.Standard_Error,
                  "ezbind: cannot inspect source page geometry");
               return 3;
            end if;
            if Descriptor.Visual_Width <=
                 Long_Float (Settings.Crop_Left + Settings.Crop_Right)
              or else Descriptor.Visual_Height <=
                 Long_Float (Settings.Crop_Top + Settings.Crop_Bottom)
            then
               Ezbind_QPDF_Bridge.Close (Input);
               Input_Open := False;
               Ada.Text_IO.Put_Line
                 (Ada.Text_IO.Standard_Error,
                  "ezbind: source crop margins leave no page area; reduce the crop values");
               return 4;
            end if;
         end loop;
      end;

      if not Ezbind_QPDF_Bridge.Create_Output
        (Sheet_Width, Sheet_Height, Output)
      then
         Ezbind_QPDF_Bridge.Close (Input);
         Ada.Text_IO.Put_Line
           (Ada.Text_IO.Standard_Error, "ezbind: cannot create PDF output");
         return 5;
      end if;
      Output_Open := True;

      declare
         Placements : constant Ezbind_Imposition.Placement_Array :=
           Ezbind_Imposition.Create_Placements (Page_Count, Layout);
      begin
         for Sheet_Number in 1 .. Natural (Placements'Length / 4) loop
            for Side in Ezbind_Imposition.Side_Kind loop
               Good := Good and then Ezbind_QPDF_Bridge.Begin_Page (Output);
               for Slot in Placements'Range loop
                  if Placements (Slot).Sheet_Number = Sheet_Number
                    and then Placements (Slot).Side = Side
                    and then not Placements (Slot).Is_Blank
                  then
                     Good := Good and then Ezbind_QPDF_Bridge.Place_Page
                       (Input,
                        Placements (Slot).Source_Page - 1,
                        Output,
                        Long_Float (Settings.Crop_Left),
                        Long_Float (Settings.Crop_Bottom),
                        Long_Float (Settings.Crop_Right),
                        Long_Float (Settings.Crop_Top),
                        Long_Float (Placements (Slot).Region.Left),
                        Long_Float (Placements (Slot).Region.Bottom),
                        Long_Float (Placements (Slot).Region.Right),
                        Long_Float (Placements (Slot).Region.Top));
                  end if;
               end loop;
               if Settings.Grid then
                  Good := Good and then Draw_Grid
                    (Output, Layout.Left_Page, Layout.Left_Content,
                     Long_Float (Settings.Grid_Spacing));
                  Good := Good and then Draw_Grid
                    (Output, Layout.Right_Page, Layout.Right_Content,
                     Long_Float (Settings.Grid_Spacing));
               end if;
            end loop;
         end loop;
      end;

      if not Good
        or else not Ezbind_QPDF_Bridge.Write_Output (Output, Temporary_Path)
      then
         Ezbind_QPDF_Bridge.Close (Input);
         Ezbind_QPDF_Bridge.Close (Output);
         if Ada.Directories.Exists (Temporary_Path) then
            Ada.Directories.Delete_File (Temporary_Path);
         end if;
         Ada.Text_IO.Put_Line
           (Ada.Text_IO.Standard_Error, "ezbind: PDF generation failed");
         return 5;
      end if;

      Ezbind_QPDF_Bridge.Close (Input);
      Ezbind_QPDF_Bridge.Close (Output);
      Input_Open := False;
      Output_Open := False;

      if Cover_Mode
        and then not Ezbind_SVG_Bridge.Render_Cover_Sheet
          (Value (Settings.Cover_Back_Path, Settings.Cover_Back_Last),
           Value (Settings.Cover_Front_Path, Settings.Cover_Front_Last),
           Sheet_Width, Sheet_Height, Cover_Temporary_Path)
      then
         if Ada.Directories.Exists (Temporary_Path) then
            Ada.Directories.Delete_File (Temporary_Path);
         end if;
         if Ada.Directories.Exists (Cover_Temporary_Path) then
            Ada.Directories.Delete_File (Cover_Temporary_Path);
         end if;
         Ada.Text_IO.Put_Line
           (Ada.Text_IO.Standard_Error, "ezbind: cover SVG rendering failed");
         return 5;
      end if;

      if Cover_Mode
        and then not Commit_Output
          (Cover_Temporary_Path, Cover_Output_Path)
      then
         if Ada.Directories.Exists (Temporary_Path) then
            Ada.Directories.Delete_File (Temporary_Path);
         end if;
         if Ada.Directories.Exists (Cover_Temporary_Path) then
            Ada.Directories.Delete_File (Cover_Temporary_Path);
         end if;
         Ada.Text_IO.Put_Line
           (Ada.Text_IO.Standard_Error, "ezbind: cannot commit cover output PDF");
         return 5;
      end if;

      if not Commit_Output (Temporary_Path, Output_Path) then
         if Ada.Directories.Exists (Temporary_Path) then
            Ada.Directories.Delete_File (Temporary_Path);
         end if;
         Ada.Text_IO.Put_Line
           (Ada.Text_IO.Standard_Error, "ezbind: cannot commit output PDF");
         return 5;
      end if;
      Ada.Text_IO.Put_Line ("ezbind: wrote " & Output_Path);
      if Cover_Mode then
         Ada.Text_IO.Put_Line ("ezbind: wrote " & Cover_Output_Path);
      end if;
      return 0;
   exception
      when others =>
         if Input_Open then
            Ezbind_QPDF_Bridge.Close (Input);
         end if;
         if Output_Open then
            Ezbind_QPDF_Bridge.Close (Output);
         end if;
         if Ada.Directories.Exists (Temporary_Path) then
            Ada.Directories.Delete_File (Temporary_Path);
         end if;
         if Ada.Directories.Exists (Cover_Temporary_Path) then
            Ada.Directories.Delete_File (Cover_Temporary_Path);
         end if;
         Ada.Text_IO.Put_Line
           (Ada.Text_IO.Standard_Error, "ezbind: internal processing error");
         return 10;
   end Produce;

   function Run return Integer is
      Settings : Options;
   begin
      if Ada.Command_Line.Argument_Count = 1
        and then (Ada.Command_Line.Argument (1) = "--help"
                  or else Ada.Command_Line.Argument (1) = "-h")
      then
         Ezbind_CLI.Print_Help;
         return 0;
      elsif not Parse_Options (Settings) then
         return 2;
      else
         return Produce (Settings);
      end if;
   end Run;
end Ezbind_Application;
