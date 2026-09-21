------------------------------------------------------------------------
--  EZBIND_IMPOSITION
------------------------------------------------------------------------
package body Ezbind_Imposition is
   function Required_Page_Count
     (Source_Page_Count : in Natural) return Natural is
      Remainder : constant Natural := Source_Page_Count mod 4;
   begin
      if Remainder = 0 then
         return Source_Page_Count;
      else
         return Source_Page_Count + (4 - Remainder);
      end if;
   end Required_Page_Count;

   function Create_Placements
     (Source_Page_Count : in Natural;
      Layout            : in Ezbind_Geometry.Sheet_Layout)
      return Placement_Array is
      Padded_Count : constant Natural :=
        Required_Page_Count (Source_Page_Count);
      Sheet_Count : constant Positive := Positive (Padded_Count / 4);
      Result      : Placement_Array (1 .. Padded_Count);

      procedure Set_Placement
        (Slot         : in Positive;
         Logical_Page : in Positive;
         Source_Page  : in Natural;
         Sheet_Number : in Positive;
         Side         : in Side_Kind;
         Position     : in Position_Kind;
         Region       : in Ezbind_Geometry.Rectangle) is
      begin
         Result (Slot) :=
           (Logical_Page => Logical_Page,
            Source_Page  => Source_Page,
            Is_Blank     => Source_Page = 0,
            Sheet_Number => Sheet_Number,
            Side         => Side,
            Position     => Position,
            Region       => Region);
      end Set_Placement;

      function Existing_Page (Page : in Positive) return Natural is
      begin
         if Page <= Source_Page_Count then
            return Page;
         else
            return 0;
         end if;
      end Existing_Page;
   begin
      for Sheet_Number in 1 .. Sheet_Count loop
         declare
            First_Page : constant Positive :=
              Positive (4 * (Sheet_Number - 1) + 1);
            Front_Left  : constant Positive := First_Page + 3;
            Front_Right : constant Positive := First_Page;
            Back_Left   : constant Positive := First_Page + 1;
            Back_Right  : constant Positive := First_Page + 2;
         begin
            Set_Placement
              (Slot => First_Page,
               Logical_Page => Front_Left,
               Source_Page => Existing_Page (Front_Left),
               Sheet_Number => Sheet_Number,
               Side => Front,
               Position => Left,
               Region => Layout.Left_Content);
            Set_Placement
              (Slot => First_Page + 1,
               Logical_Page => Front_Right,
               Source_Page => Existing_Page (Front_Right),
               Sheet_Number => Sheet_Number,
               Side => Front,
               Position => Right,
               Region => Layout.Right_Content);
            Set_Placement
              (Slot => First_Page + 2,
               Logical_Page => Back_Left,
               Source_Page => Existing_Page (Back_Left),
               Sheet_Number => Sheet_Number,
               Side => Back,
               Position => Left,
               Region => Layout.Left_Content);
            Set_Placement
              (Slot => First_Page + 3,
               Logical_Page => Back_Right,
               Source_Page => Existing_Page (Back_Right),
               Sheet_Number => Sheet_Number,
               Side => Back,
               Position => Right,
               Region => Layout.Right_Content);
         end;
      end loop;
      return Result;
   end Create_Placements;
end Ezbind_Imposition;
