--  Flight Control System Package Implementation

package body Flight_Control is

   procedure Initialize (System : in out Flight_Control_System) is
      Roll_Config   : Float_PID.PID_Config;
      Pitch_Config  : Float_PID.PID_Config;
      Yaw_Config    : Float_PID.PID_Config;
      Alt_Config    : Float_PID.PID_Config;
   begin
      --  Configure roll PID
      Roll_Config := (Kp => 1.5,
                      Ki => 0.1,
                      Kd => 0.3,
                      Integral_Max => 10.0,
                      Output_Min => -1.0,
                      Output_Max => 1.0,
                      Derivative_Filter_Alpha => 0.7);
      System.Roll_PID := Float_PID.Create (Roll_Config);

      --  Configure pitch PID
      Pitch_Config := (Kp => 1.2,
                       Ki => 0.08,
                       Kd => 0.25,
                       Integral_Max => 10.0,
                       Output_Min => -1.0,
                       Output_Max => 1.0,
                       Derivative_Filter_Alpha => 0.7);
      System.Pitch_PID := Float_PID.Create (Pitch_Config);

      --  Configure yaw PID
      Yaw_Config := (Kp => 0.8,
                     Ki => 0.05,
                     Kd => 0.2,
                     Integral_Max => 8.0,
                     Output_Min => -1.0,
                     Output_Max => 1.0,
                     Derivative_Filter_Alpha => 0.7);
      System.Yaw_PID := Float_PID.Create (Yaw_Config);

      --  Configure altitude PID
      Alt_Config := (Kp => 0.5,
                     Ki => 0.02,
                     Kd => 0.1,
                     Integral_Max => 5.0,
                     Output_Min => 0.0,
                     Output_Max => 1.0,
                     Derivative_Filter_Alpha => 0.8);
      System.Altitude_PID := Float_PID.Create (Alt_Config);

      System.Mode := Flight_Types.Stabilized;
      System.Target_Attitude := (Roll => 0.0, Pitch => 0.0, Yaw => 0.0);
      System.Target_Altitude := 100.0;
      System.Initialized := True;
      System.Health_Status := True;
   end Initialize;

   procedure Set_Mode (System : in out Flight_Control_System;
                       Mode   : Flight_Types.Flight_Mode) is
   begin
      System.Mode := Mode;
      
      --  Reset PID controllers when changing modes
      if Mode = Flight_Types.Manual then
         Float_PID.Reset (System.Roll_PID);
         Float_PID.Reset (System.Pitch_PID);
         Float_PID.Reset (System.Yaw_PID);
         Float_PID.Reset (System.Altitude_PID);
      end if;
   end Set_Mode;

   procedure Set_Target_Attitude (System : in out Flight_Control_System;
                                  Attitude : Flight_Types.Attitude) is
   begin
      System.Target_Attitude := Attitude;
   end Set_Target_Attitude;

   procedure Set_Target_Altitude (System : in out Flight_Control_System;
                                  Altitude : Flight_Types.Meters) is
   begin
      System.Target_Altitude := Altitude;
   end Set_Target_Altitude;

   procedure Update (System     : in out Flight_Control_System;
                     Nav_State  : Flight_Types.Navigation_State;
                     Delta_Time : Float) is
      Roll_Error  : Float;
      Pitch_Error : Float;
      Yaw_Error   : Float;
      Alt_Error   : Float;
      Roll_Cmd    : Float;
      Pitch_Cmd   : Float;
      Yaw_Cmd     : Float;
      Alt_Cmd     : Float;
   begin
      if not System.Initialized then
         Initialize (System);
      end if;

      case System.Mode is
         when Flight_Types.Manual =>
            --  Manual mode - no automatic control
            System.Control_Output := (Aileron => 0.0,
                                     Elevator => 0.0,
                                     Rudder => 0.0,
                                     Throttle => 0.5);
            
         when Flight_Types.Stabilized | Flight_Types.Auto_Pilot |
              Flight_Types.Navigation | Flight_Types.Landing =>
            --  Calculate attitude errors
            Roll_Error := Float (System.Target_Attitude.Roll -
                                Nav_State.Attitude.Roll);
            Pitch_Error := Float (System.Target_Attitude.Pitch -
                                 Nav_State.Attitude.Pitch);
            Yaw_Error := Float (System.Target_Attitude.Yaw -
                               Nav_State.Attitude.Yaw);

            --  Update PID controllers
            Roll_Cmd := Float_PID.Update (System.Roll_PID,
                                          Float (System.Target_Attitude.Roll),
                                          Float (Nav_State.Attitude.Roll),
                                          Delta_Time);
            Pitch_Cmd := Float_PID.Update (System.Pitch_PID,
                                           Float (System.Target_Attitude.Pitch),
                                           Float (Nav_State.Attitude.Pitch),
                                           Delta_Time);
            Yaw_Cmd := Float_PID.Update (System.Yaw_PID,
                                         Float (System.Target_Attitude.Yaw),
                                         Float (Nav_State.Attitude.Yaw),
                                         Delta_Time);

            --  Altitude control
            Alt_Error := Float (System.Target_Altitude - Nav_State.Position.Z);
            Alt_Cmd := Float_PID.Update (System.Altitude_PID,
                                         Float (System.Target_Altitude),
                                         Float (Nav_State.Position.Z),
                                         Delta_Time);

            --  Convert PID outputs to control surfaces
            System.Control_Output := (
               Aileron  => Float'Max (-1.0, Float'Min (1.0, Roll_Cmd)),
               Elevator => Float'Max (-1.0, Float'Min (1.0, Pitch_Cmd)),
               Rudder   => Float'Max (-1.0, Float'Min (1.0, Yaw_Cmd)),
               Throttle => Float'Max (0.0, Float'Min (1.0, 0.5 + Alt_Cmd * 0.3))
            );

         when Flight_Types.Emergency =>
            --  Emergency mode - attempt to stabilize
            System.Control_Output := (Aileron => 0.0,
                                     Elevator => 0.0,
                                     Rudder => 0.0,
                                     Throttle => 0.3);
      end case;

      System.Health_Status := True;
   end Update;

   function Get_Control_Output (System : Flight_Control_System)
                               return Flight_Types.Control_Surfaces is
   begin
      return System.Control_Output;
   end Get_Control_Output;

   function Get_Status (System : Flight_Control_System)
                      return Flight_Types.System_Status is
   begin
      return (Mode => System.Mode,
              Health => System.Health_Status,
              Error_Code => 0,
              Sensor_Status => True,
              Control_Status => System.Initialized);
   end Get_Status;

end Flight_Control;
