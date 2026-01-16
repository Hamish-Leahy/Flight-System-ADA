--  Mathematical Utilities Package
--  Provides common mathematical operations for flight control

generic
   type Real is digits <>;
package Math_Utils is

   --  Clamp value to range
   function Clamp (Value, Min, Max : Real) return Real;

   --  Linear interpolation
   function Lerp (A, B, T : Real) return Real;

   --  Smooth step interpolation
   function Smooth_Step (Edge0, Edge1, X : Real) return Real;

   --  Dead zone (returns 0 if value is within threshold)
   function Dead_Zone (Value, Threshold : Real) return Real;

   --  Exponential moving average
   function EMA (Current, Previous, Alpha : Real) return Real;

   --  Matrix operations (3x3)
   type Matrix_3x3 is array (1 .. 3, 1 .. 3) of Real;

   function Matrix_Multiply (A, B : Matrix_3x3) return Matrix_3x3;
   function Matrix_Vector_Multiply (M : Matrix_3x3; V : Real) return Real;
   function Identity_Matrix return Matrix_3x3;
   function Rotation_Matrix_X (Angle : Real) return Matrix_3x3;
   function Rotation_Matrix_Y (Angle : Real) return Matrix_3x3;
   function Rotation_Matrix_Z (Angle : Real) return Matrix_3x3;

   --  Quaternion operations for attitude representation
   type Quaternion is record
      W, X, Y, Z : Real;
   end record;

   function Quaternion_From_Euler (Roll, Pitch, Yaw : Real) return Quaternion;
   function Quaternion_To_Euler (Q : Quaternion) return Real;
   function Quaternion_Multiply (Q1, Q2 : Quaternion) return Quaternion;
   function Quaternion_Normalize (Q : Quaternion) return Quaternion;

end Math_Utils;
