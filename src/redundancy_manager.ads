--  Redundancy and Fault Tolerance Manager
--  Implements triple modular redundancy and graceful degradation
--  Critical for defense systems requiring high availability

package Redundancy_Manager is

   type System_Component is (
      Navigation_System,
      Flight_Control,
      Communications,
      Sensors,
      Actuators
   );

   type Component_Status is (Operational, Degraded, Failed, Unknown);

   type Redundancy_Level is (Single, Dual, Triple);

   type Component_Health is record
      Component      : System_Component;
      Status         : Component_Status;
      Redundancy     : Redundancy_Level;
      Primary_Active : Boolean;
      Backup_Count   : Natural;
      Last_Check     : Float;
   end record;

   type Redundancy_System is limited private;

   --  Initialize redundancy manager
   procedure Initialize (System : in out Redundancy_System);

   --  Register component with redundancy level
   procedure Register_Component (System     : in out Redundancy_System;
                                 Component  : System_Component;
                                 Redundancy : Redundancy_Level);

   --  Check component health
   procedure Check_Health (System    : in out Redundancy_System;
                          Component : System_Component);

   --  Get component health status
   function Get_Component_Health (System    : Redundancy_System;
                                 Component : System_Component) return Component_Health;

   --  Switch to backup component
   procedure Switch_To_Backup (System    : in out Redundancy_System;
                               Component : System_Component);

   --  Get system-wide health status
   function Get_System_Health (System : Redundancy_System) return Boolean;

   --  Perform voting (for triple modular redundancy)
   function Vote (System    : Redundancy_System;
                 Component : System_Component;
                 Value1    : Float;
                 Value2    : Float;
                 Value3    : Float) return Float;

private

   Max_Components : constant := 10;

   type Component_Health_Array is array (System_Component) of Component_Health;

   type Redundancy_System is limited record
      Components : Component_Health_Array;
      Initialized : Boolean;
   end record;

end Redundancy_Manager;
