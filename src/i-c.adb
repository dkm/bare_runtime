package body Interfaces.C
is

--  Convert String to char_array (function form)

   function To_C (Item : Character) return char is
   begin
      return char'Val (Character'Pos (Item));
   end To_C;

   function To_C
     (Item       : String;
      Append_Nul : Boolean := True) return char_array
   is
   begin
      if Append_Nul then
         declare
            R : char_array (0 .. Item'Length) with Relaxed_Initialization;

         begin
            for J in Item'Range loop
               R (size_t (J - Item'First)) := To_C (Item (J));

               pragma Loop_Invariant
                 (for all K in 0 .. size_t (J - Item'First) =>
                    R (K)'Initialized);
               pragma Loop_Invariant
                 (for all K in Item'First .. J =>
                    R (size_t (K - Item'First)) = To_C (Item (K)));
            end loop;

            R (R'Last) := nul;

            pragma Assert
              (for all J in Item'Range =>
                 R (size_t (J - Item'First)) = To_C (Item (J)));

            return R;
         end;

      --  Append_Nul False

      else
         --  A nasty case, if the string is null, we must return a null
         --  char_array. The lower bound of this array is required to be zero
         --  (RM B.3(50)) but that is of course impossible given that size_t
         --  is unsigned. According to Ada 2005 AI-258, the result is to raise
         --  Constraint_Error. This is also the appropriate behavior in Ada 95,
         --  since nothing else makes sense.

         if Item'Length = 0 then
            raise Constraint_Error;

         --  Normal case

         else
            declare
               R : char_array (0 .. Item'Length - 1)
                 with Relaxed_Initialization;

            begin
               for J in Item'Range loop
                  R (size_t (J - Item'First)) := To_C (Item (J));

                  pragma Loop_Invariant
                    (for all K in 0 .. size_t (J - Item'First) =>
                       R (K)'Initialized);
                  pragma Loop_Invariant
                    (for all K in Item'First .. J =>
                       R (size_t (K - Item'First)) = To_C (Item (K)));
               end loop;

               return R;
            end;
         end if;
      end if;
   end To_C;

   procedure To_C
     (Item       : String;
      Target     : out char_array;
      Count      : out size_t;
      Append_Nul : Boolean := True)
   is
      To : size_t;

   begin
      if Target'Length < Item'Length then
         raise Constraint_Error;

      else
         To := Target'First;
         for From in Item'Range loop
            Target (To) := char (Item (From));

            pragma Loop_Invariant (To in Target'Range);
            pragma Loop_Invariant
              (To - Target'First = size_t (From - Item'First));
            pragma Loop_Invariant
              (for all J in Target'First .. To => Target (J)'Initialized);
            pragma Loop_Invariant
              (Target (Target'First .. To)'Initialized);
            pragma Loop_Invariant
              (for all J in Item'First .. From =>
                 Target (Target'First + size_t (J - Item'First)) =
                   To_C (Item (J)));

            To := To + 1;
         end loop;

         if Append_Nul then
            if To > Target'Last then
               raise Constraint_Error;
            else
               Target (To) := nul;
               Count := Item'Length + 1;
            end if;

         else
            Count := Item'Length;
         end if;
      end if;
   end To_C;

end Interfaces.C;
