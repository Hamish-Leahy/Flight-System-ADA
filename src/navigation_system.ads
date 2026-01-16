--  Navigation System Package
--  Sensor fusion using Kalman filter to combine IMU and GPS data
--  Provides accurate position, velocity, and attitude estimates

with Flight_Types;
with Kalman_Filter;

package Navigation_System is

   --  Navigation system state
   type Navigation_System_Type is limited private;

   --  Initialize navigation system
   procedure Initialize (System : in out Navigation_System_Type);

   --  Update with IMU data
   procedure Update_IMU (System : in out Navigation_System_Type;
                         Data   : Flight_Types.IMU_Data;
                         Delta_Time : Float);

   --  Update with GPS data
   procedure Update_GPS (System : in out Navigation_System_Type;
                         Data   : Flight_Types.GPS_Data);

   --  Get current navigation state
   function Get_State (System : Navigation_System_Type)
                      return Flight_Types.Navigation_State;

   --  Check if navigation system is healthy
   function Is_Healthy (System : Navigation_System_Type) return Boolean;

   --  Reset navigation system
   procedure Reset (System : in out Navigation_System_Type);

private

   package Float_Kalman is new Kalman_Filter (Real => Float, State_Dimension => 9);

   type Navigation_System_Type is limited record
      State           : Flight_Types.Navigation_State;
      Kalman_Filter   : Float_Kalman.Kalman_State;
      Initialized     : Boolean;
      Last_Update_Time : Float;
      Health_Status    : Boolean;
   end record;

end Navigation_System;
