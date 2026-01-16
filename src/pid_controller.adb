--  PID Controller Package Implementation

package body PID_Controller is

   function Create (Config : PID_Config) return PID_State is
   begin
      return (Config              => Config,
              Previous_Error      => 0.0,
              Integral            => 0.0,
              Previous_Derivative => 0.0,
              Initialized         => False);
   end Create;

   function Update (Controller : in out PID_State;
                    Setpoint   : Real;
                    Feedback   : Real;
                    Delta_Time : Real) return Real is
      Error        : Real;
      Proportional : Real;
      Derivative   : Real;
      Output       : Real;
      use type Real;
   begin
      --  Calculate error
      Error := Setpoint - Feedback;

      --  Proportional term
      Proportional := Controller.Config.Kp * Error;

      --  Integral term with anti-windup
      if Delta_Time > 0.0 then
         Controller.Integral := Controller.Integral + Error * Delta_Time;
         --  Clamp integral to prevent windup
         if Controller.Integral > Controller.Config.Integral_Max then
            Controller.Integral := Controller.Config.Integral_Max;
         elsif Controller.Integral < -Controller.Config.Integral_Max then
            Controller.Integral := -Controller.Config.Integral_Max;
         end if;
      end if;

      --  Derivative term with filtering
      if Controller.Initialized and Delta_Time > 0.0 then
         Derivative := (Error - Controller.Previous_Error) / Delta_Time;
         --  Low-pass filter on derivative to reduce noise
         Derivative := Controller.Config.Derivative_Filter_Alpha * Derivative +
                      (1.0 - Controller.Config.Derivative_Filter_Alpha) *
                      Controller.Previous_Derivative;
         Controller.Previous_Derivative := Derivative;
      else
         Derivative := 0.0;
         Controller.Initialized := True;
      end if;

      --  Compute output
      Output := Proportional +
                Controller.Config.Ki * Controller.Integral +
                Controller.Config.Kd * Derivative;

      --  Clamp output
      if Output > Controller.Config.Output_Max then
         Output := Controller.Config.Output_Max;
      elsif Output < Controller.Config.Output_Min then
         Output := Controller.Config.Output_Min;
      end if;

      Controller.Previous_Error := Error;

      return Output;
   end Update;

   procedure Reset (Controller : in out PID_State) is
   begin
      Controller.Previous_Error := 0.0;
      Controller.Integral := 0.0;
      Controller.Previous_Derivative := 0.0;
      Controller.Initialized := False;
   end Reset;

   function Get_Error (Controller : PID_State) return Real is
   begin
      return Controller.Previous_Error;
   end Get_Error;

   function Get_Integral (Controller : PID_State) return Real is
   begin
      return Controller.Integral;
   end Get_Integral;

end PID_Controller;
