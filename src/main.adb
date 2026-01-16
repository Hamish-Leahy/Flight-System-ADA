--  Main Program - Flight Control System Demo
--  Demonstrates the complete flight control system

with Ada.Text_IO;
with Ada.Real_Time;
with System_Manager;
with Flight_Types;

procedure Main is
   use Ada.Text_IO;
   use Ada.Real_Time;
   
   Manager : System_Manager.System_Manager_Type;
   Start_Time : Time;
   Run_Duration : constant Time_Span := Seconds (5);
begin
   Put_Line ("========================================");
   Put_Line ("  Flight Control System - Demo");
   Put_Line ("  Defense-Grade Ada Implementation");
   Put_Line ("========================================");
   New_Line;

   --  Initialize system
   Put_Line ("[INFO] Initializing flight control system...");
   System_Manager.Initialize (Manager);
   Put_Line ("[INFO] System initialized successfully.");
   New_Line;

   --  Set initial flight parameters
   Put_Line ("[INFO] Setting flight parameters...");
   System_Manager.Set_Target_Attitude (
      Manager,
      (Roll => 0.0, Pitch => 0.0, Yaw => 0.0)
   );
   System_Manager.Set_Target_Altitude (Manager, 100.0);
   System_Manager.Set_Mode (Manager, Flight_Types.Auto_Pilot);
   Put_Line ("[INFO] Target: Level flight at 100m altitude");
   New_Line;

   --  Start system
   Put_Line ("[INFO] Starting system tasks...");
   System_Manager.Start (Manager);
   Put_Line ("[INFO] System running.");
   Put_Line ("[INFO] Sensor task: 100 Hz");
   Put_Line ("[INFO] Control task: 50 Hz");
   Put_Line ("[INFO] Monitor task: 10 Hz");
   New_Line;

   Start_Time := Clock;
   Put_Line ("[INFO] Running simulation for 5 seconds...");
   New_Line;

   --  Main loop - monitor system
   loop
      delay 1.0;
      
      declare
         Status : constant Flight_Types.System_Status :=
           Manager.Shared.Get_Status;
         Nav_State : constant Flight_Types.Navigation_State :=
           Manager.Shared.Get_Nav_State;
         Control_Out : constant Flight_Types.Control_Surfaces :=
           Manager.Shared.Get_Control_Output;
         Elapsed : constant Time_Span := Clock - Start_Time;
      begin
         Put_Line ("--- System Status ---");
         Put_Line ("Mode: " & Flight_Types.Flight_Mode'Image (Status.Mode));
         Put_Line ("Health: " & Boolean'Image (Status.Health));
         Put_Line ("Position: (" &
                   Float'Image (Float (Nav_State.Position.X)) & ", " &
                   Float'Image (Float (Nav_State.Position.Y)) & ", " &
                   Float'Image (Float (Nav_State.Position.Z)) & ") m");
         Put_Line ("Attitude: Roll=" &
                   Float'Image (Float (Nav_State.Attitude.Roll)) &
                   " Pitch=" &
                   Float'Image (Float (Nav_State.Attitude.Pitch)) &
                   " Yaw=" &
                   Float'Image (Float (Nav_State.Attitude.Yaw)));
         Put_Line ("Control: Aileron=" &
                   Float'Image (Control_Out.Aileron) &
                   " Elevator=" &
                   Float'Image (Control_Out.Elevator) &
                   " Throttle=" &
                   Float'Image (Control_Out.Throttle));
         New_Line;

         if Elapsed >= Run_Duration then
            exit;
         end if;
      end;
   end loop;

   --  Shutdown
   Put_Line ("[INFO] Shutting down system...");
   System_Manager.Shutdown (Manager);
   Put_Line ("[INFO] System shutdown complete.");
   Put_Line ("========================================");
   Put_Line ("Demo completed successfully!");
   Put_Line ("========================================");

end Main;
