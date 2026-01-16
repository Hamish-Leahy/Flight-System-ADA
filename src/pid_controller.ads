--  PID Controller Package
--  Generic PID controller for flight control systems
--  Defense-grade with integral windup protection and derivative filtering

generic
   type Real is digits <>;
package PID_Controller is

   type PID_Config is record
      Kp          : Real;  --  Proportional gain
      Ki          : Real;  --  Integral gain
      Kd          : Real;  --  Derivative gain
      Integral_Max : Real;  --  Maximum integral value (anti-windup)
      Output_Min  : Real;  --  Minimum output
      Output_Max  : Real;  --  Maximum output
      Derivative_Filter_Alpha : Real;  --  Low-pass filter for derivative (0.0-1.0)
   end record;

   type PID_State is private;

   --  Initialize PID controller
   function Create (Config : PID_Config) return PID_State;

   --  Update PID controller and compute output
   function Update (Controller : in out PID_State;
                    Setpoint   : Real;
                    Feedback   : Real;
                    Delta_Time : Real) return Real;

   --  Reset controller state
   procedure Reset (Controller : in out PID_State);

   --  Get current error
   function Get_Error (Controller : PID_State) return Real;

   --  Get current integral value
   function Get_Integral (Controller : PID_State) return Real;

private

   type PID_State is record
      Config           : PID_Config;
      Previous_Error   : Real;
      Integral         : Real;
      Previous_Derivative : Real;
      Initialized      : Boolean;
   end record;

end PID_Controller;
