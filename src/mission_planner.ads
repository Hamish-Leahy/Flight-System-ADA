--  Mission Planning Package
--  Advanced mission planning and waypoint management
--  Supports complex flight paths, loiter patterns, and mission objectives

with Flight_Types;

package Mission_Planner is

   type Waypoint is record
      Position    : Flight_Types.Position_3D;
      Altitude    : Flight_Types.Meters;
      Speed       : Flight_Types.Meters_Per_Second;
      Heading     : Flight_Types.Radians;
      Waypoint_ID : Natural;
      Action      : String (1 .. 50);
   end record;

   type Mission_Phase is (
      Pre_Flight,
      Takeoff,
      Transit,
      Loiter,
      Target_Acquisition,
      Engagement,
      Egress,
      Landing,
      Complete
   );

   type Mission_Plan is limited private;

   --  Initialize mission planner
   procedure Initialize (Planner : in out Mission_Plan);

   --  Load mission waypoints
   type Waypoint_Array_Type is array (Positive range <>) of Waypoint;
   procedure Load_Waypoints (Planner : in out Mission_Plan;
                            Waypoints : Waypoint_Array_Type);

   --  Get current waypoint
   function Get_Current_Waypoint (Planner : Mission_Plan) return Waypoint;

   --  Get next waypoint
   function Get_Next_Waypoint (Planner : Mission_Plan) return Waypoint;

   --  Advance to next waypoint
   procedure Advance_Waypoint (Planner : in out Mission_Plan);

   --  Check if waypoint reached
   function Waypoint_Reached (Planner : Mission_Plan;
                            Current_Position : Flight_Types.Position_3D;
                            Threshold : Flight_Types.Meters) return Boolean;

   --  Get mission phase
   function Get_Mission_Phase (Planner : Mission_Plan) return Mission_Phase;

   --  Set mission phase
   procedure Set_Mission_Phase (Planner : in out Mission_Plan;
                               Phase : Mission_Phase);

   --  Calculate route to waypoint
   function Calculate_Route (From : Flight_Types.Position_3D;
                           To   : Waypoint) return Flight_Types.Position_3D;

   --  Get mission progress (0.0 to 1.0)
   function Get_Mission_Progress (Planner : Mission_Plan) return Float;

private

   Max_Waypoints : constant := 100;

   type Waypoint_Array is array (1 .. Max_Waypoints) of Waypoint;

   type Mission_Plan is limited record
      Waypoints        : Waypoint_Array;
      Current_Index    : Natural range 0 .. Max_Waypoints;
      Total_Waypoints  : Natural range 0 .. Max_Waypoints;
      Current_Phase    : Mission_Phase;
      Initialized      : Boolean;
   end record;

end Mission_Planner;
