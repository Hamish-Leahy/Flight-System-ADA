--  Flight Control System - Type Definitions
--  Defense-grade type system with strong typing and range constraints

package Flight_Types is

   --  Physical Units
   type Meters is new Float;
   type Meters_Per_Second is new Float;
   type Radians is new Float;
   type Degrees is new Float;
   type G_Force is new Float;
   type Kilograms is new Float;

   --  Position in 3D space
   type Position_3D is record
      X, Y, Z : Meters;
   end record;

   --  Velocity vector
   type Velocity_3D is record
      Vx, Vy, Vz : Meters_Per_Second;
   end record;

   --  Attitude (orientation)
   type Attitude is record
      Roll  : Radians;  --  Rotation around X-axis
      Pitch : Radians;  --  Rotation around Y-axis
      Yaw   : Radians;  --  Rotation around Z-axis
   end record;

   --  Angular velocity
   type Angular_Velocity is record
      Roll_Rate  : Radians;
      Pitch_Rate : Radians;
      Yaw_Rate   : Radians;
   end record;

   --  Control surface deflections (normalized -1.0 to 1.0)
   type Control_Surfaces is record
      Aileron  : Float range -1.0 .. 1.0;
      Elevator : Float range -1.0 .. 1.0;
      Rudder   : Float range -1.0 .. 1.0;
      Throttle : Float range 0.0 .. 1.0;
   end record;

   --  Sensor data
   type IMU_Data is record
      Acceleration : Position_3D;  --  m/s²
      Angular_Rate : Angular_Velocity;
      Timestamp    : Float;
   end record;

   type GPS_Data is record
      Position  : Position_3D;
      Velocity  : Velocity_3D;
      Timestamp : Float;
      Valid     : Boolean;
   end record;

   --  Navigation state
   type Navigation_State is record
      Position      : Position_3D;
      Velocity      : Velocity_3D;
      Attitude      : Attitude;
      Angular_Rate  : Angular_Velocity;
      Timestamp     : Float;
   end record;

   --  Flight mode enumeration
   type Flight_Mode is (
      Manual,
      Stabilized,
      Auto_Pilot,
      Navigation,
      Landing,
      Emergency
   );

   --  System status
   type System_Status is record
      Mode            : Flight_Mode;
      Health          : Boolean;
      Error_Code      : Natural;
      Sensor_Status   : Boolean;
      Control_Status  : Boolean;
   end record;

   --  Conversion functions
   function To_Radians (Deg : Degrees) return Radians;
   function To_Degrees (Rad : Radians) return Degrees;

   --  Vector operations
   function "+" (Left, Right : Position_3D) return Position_3D;
   function "-" (Left, Right : Position_3D) return Position_3D;
   function "*" (Scalar : Float; Vec : Position_3D) return Position_3D;
   function Magnitude (Vec : Position_3D) return Meters;
   function Normalize (Vec : Position_3D) return Position_3D;

end Flight_Types;
