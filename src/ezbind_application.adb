------------------------------------------------------------------------
--  EZBIND_APPLICATION
------------------------------------------------------------------------
with Ada.Command_Line;
with Ada.Directories;
with Ada.Text_IO;
with Ezbind_CLI;
with Ezbind_Geometry;
with Ezbind_Imposition;
with Ezbind_Physical;
with Ezbind_QPDF_Bridge;

package body Ezbind_Application is
   use type Ezbind_Imposition.Side_Kind;
   type Sheet_Kind is (Letter, A4);

   type Options is record
      Input_Path  : String (1 .. 1024) := (others => ' ');
      Input_Last  : Natural := 0;
      Output_Path : String (1 .. 1024) := (others => ' ');
      Output_Last : Natural := 0;
      Sheet       : Sheet_Kind := Letter;
      Force       : Boolean := False;
      Grid        : Boolean := False;
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

   function Parse_Options
     (Result : out Options) return Boolean is
      Index : Positive := 1;
      Count : constant Natural := Ada.Command_Line.Argument_Count;
   begin
      if Count = 0 then
         Ezbind_CLI.Print_Usage_Error ("an input PDF and --output are required");
         return False;
      end if;

      while Index <= Count loop
         declare
            Argument : constant String := Ada.Command_Line.Argument (Index);
         begin
            if Argument = "--output" then
               if Index = Count then
                  Ezbind_CLI.Print_Usage_Error
                    ("--output requires a path");
                  return False;
               end if;
               Index := Index + 1;
               if not Set_Path
                 (Result.Output_Path, Result.Output_Last,
                  Ada.Command_Line.Argument (Index))
               then
                  Ezbind_CLI.Print_Usage_Error ("output path is too long");
                  return False;
               end if;
            elsif Argument = "--force" then
               Result.Force := True;
            elsif Argument = "--grid" then
               Result.Grid := True;
            elsif Argument = "--sheet" then
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
            elsif Argument'Length > 0 and then Argument (Argument'First) = '-' then
               Ezbind_CLI.Print_Usage_Error ("unknown or malformed option");
               return False;
            elsif Result.Input_Last /= 0 then
               Ezbind_CLI.Print_Usage_Error ("exactly one input PDF is required");
               return False;
            else
               if not Set_Path
                 (Result.Input_Path, Result.Input_Last, Argument)
               then
                  Ezbind_CLI.Print_Usage_Error ("input path is too long");
                  return False;
               end if;
            end if;
         end;
         Index := Index + 1;
      end loop;

      if Result.Input_Last = 0 or else Result.Output_Last = 0 then
         Ezbind_CLI.Print_Usage_Error ("an input PDF and --output are required");
         return False;
      end if;
      return True;
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
      Output_Path    : in String;
      Force          : in Boolean) return Boolean is
   begin
      if Force and then Ada.Directories.Exists (Output_Path) then
         Ada.Directories.Delete_File (Output_Path);
      end if;
      Ada.Directories.Rename (Temporary_Path, Output_Path);
      return True;
   exception
      when others =>
         return False;
   end Commit_Output;

   function Draw_Grid
     (Output : in Ezbind_QPDF_Bridge.Output_Handle;
      Page   : in Ezbind_Geometry.Rectangle;
      Content : in Ezbind_Geometry.Rectangle;
      Spacing : in Long_Float) return Boolean is
      X : Long_Float := Long_Float (Page.Left) + Spacing;
      Y : Long_Float := Long_Float (Page.Bottom) + Spacing;
      Good : Boolean := True;
   begin
      while X < Long_Float (Page.Right) loop
         if X > Long_Float (Content.Right) then
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
              (Output, Long_Float (Content.Left), Y,
               Long_Float (Content.Right), Y);
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
        (Top => 36.0, Bottom => 36.0, Fore_Edge => 36.0, Spine => 48.0);
      Temporary_Path : constant String :=
        Value (Settings.Output_Path, Settings.Output_Last) & ".ezbind.tmp";
      Input_Open  : Boolean := False;
      Output_Open : Boolean := False;
      Layout      : Ezbind_Geometry.Sheet_Layout;
      Good        : Boolean := True;
   begin
      if Ada.Directories.Exists
        (Value (Settings.Output_Path, Settings.Output_Last))
        and then not Settings.Force
      then
         Ada.Text_IO.Put_Line
           (Ada.Text_IO.Standard_Error,
            "ezbind: output exists; use --force to replace it");
         return 5;
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
         Ezbind_QPDF_Bridge.Close (Input);
         return 4;
      end if;

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
                        Long_Float (Placements (Slot).Region.Left),
                        Long_Float (Placements (Slot).Region.Bottom),
                        Long_Float (Placements (Slot).Region.Right),
                        Long_Float (Placements (Slot).Region.Top));
                  end if;
               end loop;
               if Settings.Grid then
                  Good := Good and then Draw_Grid
                    (Output, Layout.Left_Page, Layout.Left_Content,
                     14.1732283);
                  Good := Good and then Draw_Grid
                    (Output, Layout.Right_Page, Layout.Right_Content,
                     14.1732283);
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
      if not Commit_Output
        (Temporary_Path, Value (Settings.Output_Path, Settings.Output_Last),
         Settings.Force)
      then
         if Ada.Directories.Exists (Temporary_Path) then
            Ada.Directories.Delete_File (Temporary_Path);
         end if;
         Ada.Text_IO.Put_Line
           (Ada.Text_IO.Standard_Error, "ezbind: cannot commit output PDF");
         return 5;
      end if;
      Ada.Text_IO.Put_Line
        ("ezbind: wrote " & Value (Settings.Output_Path, Settings.Output_Last));
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
