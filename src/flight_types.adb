--  Flight Control System - Type Definitions Implementation

package body Flight_Types is

   Pi : constant := 3.14159265358979323846;
   Pi_Over_180 : constant := Pi / 180.0;

   function To_Radians (Deg : Degrees) return Radians is
   begin
      return Radians (Deg * Pi_Over_180);
   end To_Radians;

   function To_Degrees (Rad : Radians) return Degrees is
   begin
      return Degrees (Rad / Pi_Over_180);
   end To_Degrees;

   function "+" (Left, Right : Position_3D) return Position_3D is
   begin
      return (X => Left.X + Right.X,
              Y => Left.Y + Right.Y,
              Z => Left.Z + Right.Z);
   end "+";

   function "-" (Left, Right : Position_3D) return Position_3D is
   begin
      return (X => Left.X - Right.X,
              Y => Left.Y - Right.Y,
              Z => Left.Z - Right.Z);
   end "-";

   function "*" (Scalar : Float; Vec : Position_3D) return Position_3D is
   begin
      return (X => Meters (Scalar * Float (Vec.X)),
              Y => Meters (Scalar * Float (Vec.Y)),
              Z => Meters (Scalar * Float (Vec.Z)));
   end "*";

   function Magnitude (Vec : Position_3D) return Meters is
      use type Float;
      use Ada.Numerics.Elementary_Functions;
      Sum_Sq : Float := Float (Vec.X) ** 2 + Float (Vec.Y) ** 2 + Float (Vec.Z) ** 2;
   begin
      return Meters (Sqrt (Sum_Sq));
   end Magnitude;

   function Normalize (Vec : Position_3D) return Position_3D is
      Mag : constant Meters := Magnitude (Vec);
   begin
      if Mag > 0.001 then
         return (1.0 / Float (Mag)) * Vec;
      else
         return (X => 0.0, Y => 0.0, Z => 0.0);
      end if;
   end Normalize;

end Flight_Types;
