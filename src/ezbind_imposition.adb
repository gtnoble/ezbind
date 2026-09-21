--  ----------------------------------------------------------------------
--  EZBIND_IMPOSITION
--  ----------------------------------------------------------------------
package body Ezbind_Imposition is
   function Required_Page_Count
     (Source_Page_Count : in Natural) return Natural is
      Remainder : constant Natural :=
        Source_Page_Count mod 4;
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
      Sheet_Count  : constant Positive := Positive (Padded_Count / 4);
      Result       : Placement_Array (1 .. Padded_Count);
      Logical_Page : Positive := 1;
      Source_Page  : Natural := 1;
   begin
      for Sheet_Number in 1 .. Sheet_Count loop
         Result (Logical_Page) :=
           (Logical_Page => Logical_Page,
            Source_Page => Source_Page,
            Is_Blank => Source_Page > Source_Page_Count,
            Sheet_Number => Sheet_Number,
            Side => Front,
            Position => Left,
            Region => Layout.Left_Page);
         Logical_Page := Logical_Page + 1;
         Source_Page := Source_Page + 1;

         Result (Logical_Page) :=
           (Logical_Page => Logical_Page,
            Source_Page => Source_Page,
            Is_Blank => Source_Page > Source_Page_Count,
            Sheet_Number => Sheet_Number,
            Side => Front,
            Position => Right,
            Region => Layout.Right_Page);
         Logical_Page := Logical_Page + 1;
         Source_Page := Source_Page + 1;

         Result (Logical_Page) :=
           (Logical_Page => Logical_Page,
            Source_Page => Source_Page,
            Is_Blank => Source_Page > Source_Page_Count,
            Sheet_Number => Sheet_Number,
            Side => Back,
            Position => Left,
            Region => Layout.Left_Page);
         Logical_Page := Logical_Page + 1;
         Source_Page := Source_Page + 1;

         Result (Logical_Page) :=
           (Logical_Page => Logical_Page,
            Source_Page => Source_Page,
            Is_Blank => Source_Page > Source_Page_Count,
            Sheet_Number => Sheet_Number,
            Side => Back,
            Position => Right,
            Region => Layout.Right_Page);
         Logical_Page := Logical_Page + 1;
         Source_Page := Source_Page + 1;
      end loop;
      return Result;
   end Create_Placements;
end Ezbind_Imposition;
