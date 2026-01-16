--  Navigation System Package Implementation

package body Navigation_System is

   procedure Initialize (System : in out Navigation_System_Type) is
      Initial_State : Float_Kalman.State_Vector := (others => 0.0);
      Config        : Float_Kalman.Kalman_Config;
      Initial_Cov   : Float_Kalman.Covariance_Matrix;
      Process_Noise : Float_Kalman.Covariance_Matrix;
      Meas_Noise    : Float_Kalman.Covariance_Matrix;
   begin
      --  Initialize covariance matrices
      for I in 1 .. 9 loop
         for J in 1 .. 9 loop
            Initial_Cov (I, J) := (if I = J then 1.0 else 0.0);
            Process_Noise (I, J) := (if I = J then 0.1 else 0.0);
            Meas_Noise (I, J) := (if I = J then 0.5 else 0.0);
         end loop;
      end loop;

      Config := (Process_Noise_Covariance  => Process_Noise,
                 Measurement_Noise_Covariance => Meas_Noise,
                 Initial_State_Covariance  => Initial_Cov);

      System.Kalman_Filter := Float_Kalman.Create (Config, Initial_State);
      System.Initialized := True;
      System.Health_Status := True;
      System.Last_Update_Time := 0.0;
   end Initialize;

   procedure Update_IMU (System     : in out Navigation_System_Type;
                         Data       : Flight_Types.IMU_Data;
                         Delta_Time : Float) is
      Measurement : Float_Kalman.Measurement_Vector;
      Meas_Matrix : Float_Kalman.Covariance_Matrix;
   begin
      if not System.Initialized then
         Initialize (System);
      end if;

      --  Convert IMU data to measurement vector
      Measurement (1) := Float (Data.Acceleration.X);
      Measurement (2) := Float (Data.Acceleration.Y);
      Measurement (3) := Float (Data.Acceleration.Z);
      Measurement (4) := Float (Data.Angular_Rate.Roll_Rate);
      Measurement (5) := Float (Data.Angular_Rate.Pitch_Rate);
      Measurement (6) := Float (Data.Angular_Rate.Yaw_Rate);
      --  Keep previous position/velocity estimates
      Measurement (7) := Float (System.State.Position.X);
      Measurement (8) := Float (System.State.Position.Y);
      Measurement (9) := Float (System.State.Position.Z);

      --  Measurement noise matrix
      for I in 1 .. 9 loop
         for J in 1 .. 9 loop
            Meas_Matrix (I, J) := (if I = J then 0.3 else 0.0);
         end loop;
      end loop;

      --  Predict step
      Float_Kalman.Predict (System.Kalman_Filter,
                           (others => (others => 1.0)),  --  Identity transition
                           (others => (others => 0.1))); --  Process noise

      --  Update step
      Float_Kalman.Update (System.Kalman_Filter, Measurement, Meas_Matrix);

      --  Update navigation state from Kalman filter
      declare
         KF_State : constant Float_Kalman.State_Vector :=
           Float_Kalman.Get_State (System.Kalman_Filter);
      begin
         System.State.Position.X := Flight_Types.Meters (KF_State (7));
         System.State.Position.Y := Flight_Types.Meters (KF_State (8));
         System.State.Position.Z := Flight_Types.Meters (KF_State (9));
         System.State.Angular_Rate.Roll_Rate := Flight_Types.Radians (KF_State (4));
         System.State.Angular_Rate.Pitch_Rate := Flight_Types.Radians (KF_State (5));
         System.State.Angular_Rate.Yaw_Rate := Flight_Types.Radians (KF_State (6));
      end;

      System.Last_Update_Time := Data.Timestamp;
   end Update_IMU;

   procedure Update_GPS (System : in out Navigation_System_Type;
                         Data   : Flight_Types.GPS_Data) is
      Measurement : Float_Kalman.Measurement_Vector;
      Meas_Matrix : Float_Kalman.Covariance_Matrix;
   begin
      if not Data.Valid then
         return;
      end if;

      if not System.Initialized then
         Initialize (System);
      end if;

      --  Convert GPS data to measurement vector
      Measurement (1) := 0.0;  --  Acceleration not from GPS
      Measurement (2) := 0.0;
      Measurement (3) := 0.0;
      Measurement (4) := 0.0;  --  Angular rate not from GPS
      Measurement (5) := 0.0;
      Measurement (6) := 0.0;
      Measurement (7) := Float (Data.Position.X);
      Measurement (8) := Float (Data.Position.Y);
      Measurement (9) := Float (Data.Position.Z);

      --  GPS has higher measurement noise for position
      for I in 1 .. 9 loop
         for J in 1 .. 9 loop
            if I >= 7 and I = J then
               Meas_Matrix (I, J) := 1.0;  --  GPS position noise
            else
               Meas_Matrix (I, J) := 0.0;
            end if;
         end loop;
      end loop;

      --  Predict and update
      Float_Kalman.Predict (System.Kalman_Filter,
                           (others => (others => 1.0)),
                           (others => (others => 0.1)));
      Float_Kalman.Update (System.Kalman_Filter, Measurement, Meas_Matrix);

      --  Update state
      declare
         KF_State : constant Float_Kalman.State_Vector :=
           Float_Kalman.Get_State (System.Kalman_Filter);
      begin
         System.State.Position := Data.Position;
         System.State.Velocity := Data.Velocity;
      end;

      System.Health_Status := True;
   end Update_GPS;

   function Get_State (System : Navigation_System_Type)
                      return Flight_Types.Navigation_State is
   begin
      return System.State;
   end Get_State;

   function Is_Healthy (System : Navigation_System_Type) return Boolean is
   begin
      return System.Health_Status and System.Initialized;
   end Is_Healthy;

   procedure Reset (System : in out Navigation_System_Type) is
   begin
      System.Initialized := False;
      System.Health_Status := False;
      Initialize (System);
   end Reset;

end Navigation_System;
