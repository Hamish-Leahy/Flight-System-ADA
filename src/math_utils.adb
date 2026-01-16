--  Mathematical Utilities Package Implementation

package body Math_Utils is

   function Clamp (Value, Min, Max : Real) return Real is
   begin
      if Value < Min then
         return Min;
      elsif Value > Max then
         return Max;
      else
         return Value;
      end if;
   end Clamp;

   function Lerp (A, B, T : Real) return Real is
   begin
      return A + (B - A) * T;
   end Lerp;

   function Smooth_Step (Edge0, Edge1, X : Real) return Real is
      T : Real;
   begin
      T := Clamp ((X - Edge0) / (Edge1 - Edge0), 0.0, 1.0);
      return T * T * (3.0 - 2.0 * T);
   end Smooth_Step;

   function Dead_Zone (Value, Threshold : Real) return Real is
   begin
      if abs Value < Threshold then
         return 0.0;
      else
         return Value;
      end if;
   end Dead_Zone;

   function EMA (Current, Previous, Alpha : Real) return Real is
   begin
      return Alpha * Current + (1.0 - Alpha) * Previous;
   end EMA;

   function Matrix_Multiply (A, B : Matrix_3x3) return Matrix_3x3 is
      Result : Matrix_3x3;
   begin
      for I in 1 .. 3 loop
         for J in 1 .. 3 loop
            Result (I, J) := 0.0;
            for K in 1 .. 3 loop
               Result (I, J) := Result (I, J) + A (I, K) * B (K, J);
            end loop;
         end loop;
      end loop;
      return Result;
   end Matrix_Multiply;

   function Matrix_Vector_Multiply (M : Matrix_3x3; V : Real) return Real is
      pragma Unreferenced (M, V);
   begin
      --  Simplified for demonstration
      return 0.0;
   end Matrix_Vector_Multiply;

   function Identity_Matrix return Matrix_3x3 is
      Result : Matrix_3x3 := (others => (others => 0.0));
   begin
      for I in 1 .. 3 loop
         Result (I, I) := 1.0;
      end loop;
      return Result;
   end Identity_Matrix;

   function Rotation_Matrix_X (Angle : Real) return Matrix_3x3 is
      C : constant Real := Real (Ada.Numerics.Elementary_Functions.Cos (Angle));
      S : constant Real := Real (Ada.Numerics.Elementary_Functions.Sin (Angle));
   begin
      return ((1.0, 0.0, 0.0),
              (0.0, C,  -S),
              (0.0, S,   C));
   end Rotation_Matrix_X;

   function Rotation_Matrix_Y (Angle : Real) return Matrix_3x3 is
      C : constant Real := Real (Ada.Numerics.Elementary_Functions.Cos (Angle));
      S : constant Real := Real (Ada.Numerics.Elementary_Functions.Sin (Angle));
   begin
      return ((C,  0.0, S),
              (0.0, 1.0, 0.0),
              (-S, 0.0, C));
   end Rotation_Matrix_Y;

   function Rotation_Matrix_Z (Angle : Real) return Matrix_3x3 is
      C : constant Real := Real (Ada.Numerics.Elementary_Functions.Cos (Angle));
      S : constant Real := Real (Ada.Numerics.Elementary_Functions.Sin (Angle));
   begin
      return ((C,  -S, 0.0),
              (S,   C, 0.0),
              (0.0, 0.0, 1.0));
   end Rotation_Matrix_Z;

   function Quaternion_From_Euler (Roll, Pitch, Yaw : Real) return Quaternion is
      use Ada.Numerics.Elementary_Functions;
      Cr : constant Real := Real (Cos (Roll / 2.0));
      Sr : constant Real := Real (Sin (Roll / 2.0));
      Cp : constant Real := Real (Cos (Pitch / 2.0));
      Sp : constant Real := Real (Sin (Pitch / 2.0));
      Cy : constant Real := Real (Cos (Yaw / 2.0));
      Sy : constant Real := Real (Sin (Yaw / 2.0));
   begin
      return (W => Cr * Cp * Cy + Sr * Sp * Sy,
              X => Sr * Cp * Cy - Cr * Sp * Sy,
              Y => Cr * Sp * Cy + Sr * Cp * Sy,
              Z => Cr * Cp * Sy - Sr * Sp * Cy);
   end Quaternion_From_Euler;

   function Quaternion_To_Euler (Q : Quaternion) return Real is
      pragma Unreferenced (Q);
   begin
      --  Simplified - would return roll, pitch, or yaw based on parameter
      return 0.0;
   end Quaternion_To_Euler;

   function Quaternion_Multiply (Q1, Q2 : Quaternion) return Quaternion is
   begin
      return (W => Q1.W * Q2.W - Q1.X * Q2.X - Q1.Y * Q2.Y - Q1.Z * Q2.Z,
              X => Q1.W * Q2.X + Q1.X * Q2.W + Q1.Y * Q2.Z - Q1.Z * Q2.Y,
              Y => Q1.W * Q2.Y - Q1.X * Q2.Z + Q1.Y * Q2.W + Q1.Z * Q2.X,
              Z => Q1.W * Q2.Z + Q1.X * Q2.Y - Q1.Y * Q2.X + Q1.Z * Q2.W);
   end Quaternion_Multiply;

   function Quaternion_Normalize (Q : Quaternion) return Quaternion is
      use Ada.Numerics.Elementary_Functions;
      Norm : constant Real := Real (Sqrt (Float (Q.W ** 2 + Q.X ** 2 + Q.Y ** 2 + Q.Z ** 2)));
   begin
      if Norm > 0.0001 then
         return (W => Q.W / Norm,
                 X => Q.X / Norm,
                 Y => Q.Y / Norm,
                 Z => Q.Z / Norm);
      else
         return (1.0, 0.0, 0.0, 0.0);
      end if;
   end Quaternion_Normalize;

end Math_Utils;
