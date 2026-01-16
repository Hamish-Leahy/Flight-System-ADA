--  System Manager Package
--  Coordinates all subsystems using protected objects and tasks
--  Demonstrates concurrent programming in Ada

with Flight_Types;
with Navigation_System;
with Flight_Control;

package System_Manager is

   --  Protected object for thread-safe data sharing
   protected type Shared_State is
      --  Write navigation state
      procedure Set_Nav_State (State : Flight_Types.Navigation_State);
      
      --  Read navigation state
      function Get_Nav_State return Flight_Types.Navigation_State;
      
      --  Write control output
      procedure Set_Control_Output (Output : Flight_Types.Control_Surfaces);
      
      --  Read control output
      function Get_Control_Output return Flight_Types.Control_Surfaces;
      
      --  Set system status
      procedure Set_Status (Status : Flight_Types.System_Status);
      
      --  Get system status
      function Get_Status return Flight_Types.System_Status;
      
   private
      Nav_State      : Flight_Types.Navigation_State;
      Control_Output : Flight_Types.Control_Surfaces;
      Status         : Flight_Types.System_Status;
   end Shared_State;

   --  Task for sensor processing
   task type Sensor_Task is
      entry Start (Manager_Ref : access System_Manager_Type);
      entry Stop;
   end Sensor_Task;

   --  Task for control loop
   task type Control_Task is
      entry Start (Manager_Ref : access System_Manager_Type);
      entry Stop;
   end Control_Task;

   --  Task for monitoring
   task type Monitor_Task is
      entry Start (Manager_Ref : access System_Manager_Type);
      entry Stop;
   end Monitor_Task;

   --  Main system manager type
   type System_Manager_Type is limited private;

   --  Initialize system manager
   procedure Initialize (Manager : in out System_Manager_Type);

   --  Start all tasks
   procedure Start (Manager : in out System_Manager_Type);

   --  Stop all tasks
   procedure Stop (Manager : in out System_Manager_Type);

   --  Shutdown system
   procedure Shutdown (Manager : in out System_Manager_Type);

   --  Accessor functions for flight control
   procedure Set_Target_Attitude (Manager : in out System_Manager_Type;
                                  Attitude : Flight_Types.Attitude);
   procedure Set_Target_Altitude (Manager : in out System_Manager_Type;
                                  Altitude : Flight_Types.Meters);
   procedure Set_Mode (Manager : in out System_Manager_Type;
                       Mode : Flight_Types.Flight_Mode);

private

   type System_Manager_Type is limited record
      Shared          : Shared_State;
      Nav_System      : Navigation_System.Navigation_System_Type;
      Flight_Control  : Flight_Control.Flight_Control_System;
      Sensor_Worker   : Sensor_Task;
      Control_Worker  : Control_Task;
      Monitor_Worker  : Monitor_Task;
      Running         : Boolean := False;
   end record;

end System_Manager;
