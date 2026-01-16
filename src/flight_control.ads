--  Flight Control System Package
--  Main flight control system with attitude and altitude control
--  Uses PID controllers for stabilization and navigation

with Flight_Types;
with Navigation_System;
with PID_Controller;

package Flight_Control is

   type Flight_Control_System is limited private;

   --  Initialize flight control system
   procedure Initialize (System : in out Flight_Control_System);

   --  Set flight mode
   procedure Set_Mode (System : in out Flight_Control_System;
                       Mode   : Flight_Types.Flight_Mode);

   --  Set target attitude
   procedure Set_Target_Attitude (System : in out Flight_Control_System;
                                  Attitude : Flight_Types.Attitude);

   --  Set target altitude
   procedure Set_Target_Altitude (System : in out Flight_Control_System;
                                  Altitude : Flight_Types.Meters);

   --  Update flight control (call periodically)
   procedure Update (System     : in out Flight_Control_System;
                     Nav_State  : Flight_Types.Navigation_State;
                     Delta_Time : Float);

   --  Get control surface commands
   function Get_Control_Output (System : Flight_Control_System)
                               return Flight_Types.Control_Surfaces;

   --  Get system status
   function Get_Status (System : Flight_Control_System)
                      return Flight_Types.System_Status;

private

   package Float_PID is new PID_Controller (Real => Float);

   type Flight_Control_System is limited record
      Mode              : Flight_Types.Flight_Mode;
      Target_Attitude   : Flight_Types.Attitude;
      Target_Altitude   : Flight_Types.Meters;
      Control_Output    : Flight_Types.Control_Surfaces;
      
      --  PID controllers for each axis
      Roll_PID          : Float_PID.PID_State;
      Pitch_PID         : Float_PID.PID_State;
      Yaw_PID           : Float_PID.PID_State;
      Altitude_PID      : Float_PID.PID_State;
      
      Initialized       : Boolean;
      Health_Status     : Boolean;
   end record;

end Flight_Control;
