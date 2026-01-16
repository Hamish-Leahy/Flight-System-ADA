--  System Manager Package Implementation

with Ada.Real_Time;
use Ada.Real_Time;

package body System_Manager is

   --  Shared State Protected Object Implementation
   protected body Shared_State is

      procedure Set_Nav_State (State : Flight_Types.Navigation_State) is
      begin
         Nav_State := State;
      end Set_Nav_State;

      function Get_Nav_State return Flight_Types.Navigation_State is
      begin
         return Nav_State;
      end Get_Nav_State;

      procedure Set_Control_Output (Output : Flight_Types.Control_Surfaces) is
      begin
         Control_Output := Output;
      end Set_Control_Output;

      function Get_Control_Output return Flight_Types.Control_Surfaces is
      begin
         return Control_Output;
      end Get_Control_Output;

      procedure Set_Status (Status : Flight_Types.System_Status) is
      begin
         System_Manager.Status := Status;
      end Set_Status;

      function Get_Status return Flight_Types.System_Status is
      begin
         return System_Manager.Status;
      end Get_Status;

   end Shared_State;

   --  Sensor Task Implementation
   task body Sensor_Task is
      Manager_Ref : access System_Manager_Type;
      Running     : Boolean := False;
      Last_Time   : Time;
      Period      : constant Time_Span := Milliseconds (10);  --  100 Hz
   begin
      accept Start (Manager_Ref : access System_Manager_Type) do
         Sensor_Task.Manager_Ref := Manager_Ref;
      end Start;
      Running := True;
      Last_Time := Clock;

      while Running loop
         --  Simulate sensor data acquisition
         declare
            Now        : constant Time := Clock;
            Delta_Time : constant Float :=
              Float (To_Duration (Now - Last_Time));
            IMU_Data   : Flight_Types.IMU_Data;
            GPS_Data   : Flight_Types.GPS_Data;
         begin
            --  Generate simulated IMU data
            IMU_Data := (
               Acceleration => (X => 0.0, Y => 0.0, Z => 9.81),
               Angular_Rate => (Roll_Rate => 0.0,
                               Pitch_Rate => 0.0,
                               Yaw_Rate => 0.0),
               Timestamp => Float (To_Duration (Now))
            );

            --  Generate simulated GPS data
            GPS_Data := (
               Position => (X => 0.0, Y => 0.0, Z => 100.0),
               Velocity => (Vx => 0.0, Vy => 0.0, Vz => 0.0),
               Timestamp => Float (To_Duration (Now)),
               Valid => True
            );

            --  Update navigation system
            Navigation_System.Update_IMU (Manager_Ref.Nav_System,
                                          IMU_Data,
                                          Delta_Time);
            Navigation_System.Update_GPS (Manager_Ref.Nav_System, GPS_Data);

            --  Update shared state
            Manager_Ref.Shared.Set_Nav_State (
               Navigation_System.Get_State (Manager_Ref.Nav_System)
            );

            Last_Time := Now;
         end;

         --  Wait for next period
         delay until Last_Time + Period;
      end loop;

      accept Stop;
   end Sensor_Task;

   --  Control Task Implementation
   task body Control_Task is
      Manager_Ref : access System_Manager_Type;
      Running     : Boolean := False;
      Last_Time   : Time;
      Period      : constant Time_Span := Milliseconds (20);  --  50 Hz
   begin
      accept Start (Manager_Ref : access System_Manager_Type) do
         Control_Task.Manager_Ref := Manager_Ref;
      end Start;
      Running := True;
      Last_Time := Clock;

      while Running loop
         declare
            Now        : constant Time := Clock;
            Delta_Time : constant Float :=
              Float (To_Duration (Now - Last_Time));
            Nav_State  : Flight_Types.Navigation_State;
            Control_Out : Flight_Types.Control_Surfaces;
         begin
            --  Get navigation state from shared memory
            Nav_State := Manager_Ref.Shared.Get_Nav_State;

            --  Update flight control
            Flight_Control.Update (Manager_Ref.Flight_Control,
                                  Nav_State,
                                  Delta_Time);

            --  Get control output
            Control_Out := Flight_Control.Get_Control_Output (
               Manager_Ref.Flight_Control
            );

            --  Update shared state
            Manager_Ref.Shared.Set_Control_Output (Control_Out);

            --  Update status
            Manager_Ref.Shared.Set_Status (
               Flight_Control.Get_Status (Manager_Ref.Flight_Control)
            );

            Last_Time := Now;
         end;

         delay until Last_Time + Period;
      end loop;

      accept Stop;
   end Control_Task;

   --  Monitor Task Implementation
   task body Monitor_Task is
      Manager_Ref : access System_Manager_Type;
      Running     : Boolean := False;
      Last_Time   : Time;
      Period      : constant Time_Span := Milliseconds (100);  --  10 Hz
   begin
      accept Start (Manager_Ref : access System_Manager_Type) do
         Monitor_Task.Manager_Ref := Manager_Ref;
      end Start;
      Running := True;
      Last_Time := Clock;

      while Running loop
         declare
            Status : Flight_Types.System_Status;
            Nav_State : Flight_Types.Navigation_State;
         begin
            Status := Manager_Ref.Shared.Get_Status;
            Nav_State := Manager_Ref.Shared.Get_Nav_State;

            --  Health monitoring logic
            --  Check if navigation system is healthy
            if not Navigation_System.Is_Healthy (Manager_Ref.Nav_System) then
               --  Set emergency mode
               Flight_Control.Set_Mode (Manager_Ref.Flight_Control,
                                       Flight_Types.Emergency);
            end if;

            Last_Time := Clock;
         end;

         delay until Last_Time + Period;
      end loop;

      accept Stop;
   end Monitor_Task;

   --  System Manager Implementation
   procedure Initialize (Manager : in out System_Manager_Type) is
   begin
      Navigation_System.Initialize (Manager.Nav_System);
      Flight_Control.Initialize (Manager.Flight_Control);
      Manager.Running := False;
   end Initialize;

   procedure Start (Manager : in out System_Manager_Type) is
   begin
      if not Manager.Running then
         Manager.Sensor_Worker.Start (Manager'Access);
         Manager.Control_Worker.Start (Manager'Access);
         Manager.Monitor_Worker.Start (Manager'Access);
         Manager.Running := True;
      end if;
   end Start;

   procedure Stop (Manager : in out System_Manager_Type) is
   begin
      if Manager.Running then
         Manager.Sensor_Worker.Stop;
         Manager.Control_Worker.Stop;
         Manager.Monitor_Worker.Stop;
         Manager.Running := False;
      end if;
   end Stop;

   procedure Shutdown (Manager : in out System_Manager_Type) is
   begin
      Stop (Manager);
   end Shutdown;

   procedure Set_Target_Attitude (Manager : in out System_Manager_Type;
                                  Attitude : Flight_Types.Attitude) is
   begin
      Flight_Control.Set_Target_Attitude (Manager.Flight_Control, Attitude);
   end Set_Target_Attitude;

   procedure Set_Target_Altitude (Manager : in out System_Manager_Type;
                                  Altitude : Flight_Types.Meters) is
   begin
      Flight_Control.Set_Target_Altitude (Manager.Flight_Control, Altitude);
   end Set_Target_Altitude;

   procedure Set_Mode (Manager : in out System_Manager_Type;
                       Mode : Flight_Types.Flight_Mode) is
   begin
      Flight_Control.Set_Mode (Manager.Flight_Control, Mode);
   end Set_Mode;

end System_Manager;
