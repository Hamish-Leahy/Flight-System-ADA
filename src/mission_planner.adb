--  Mission Planning Package Implementation

with Flight_Types;

package body Mission_Planner is

   procedure Initialize (Planner : in out Mission_Plan) is
   begin
      Planner.Current_Index := 0;
      Planner.Total_Waypoints := 0;
      Planner.Current_Phase := Pre_Flight;
      Planner.Initialized := True;
   end Initialize;

   procedure Load_Waypoints (Planner : in out Mission_Plan;
                            Waypoints : Waypoint_Array_Type) is
   begin
      Planner.Total_Waypoints := Waypoints'Length;
      for I in Waypoints'Range loop
         if I <= Max_Waypoints then
            Planner.Waypoints (I) := Waypoints (I);
         end if;
      end loop;
      Planner.Current_Index := 1;
   end Load_Waypoints;

   function Get_Current_Waypoint (Planner : Mission_Plan) return Waypoint is
   begin
      if Planner.Current_Index > 0 and
         Planner.Current_Index <= Planner.Total_Waypoints then
         return Planner.Waypoints (Planner.Current_Index);
      else
         return (Position => (0.0, 0.0, 0.0),
                Altitude => 0.0,
                Speed => 0.0,
                Heading => 0.0,
                Waypoint_ID => 0,
                Action => (others => ' '));
      end if;
   end Get_Current_Waypoint;

   function Get_Next_Waypoint (Planner : Mission_Plan) return Waypoint is
   begin
      if Planner.Current_Index < Planner.Total_Waypoints then
         return Planner.Waypoints (Planner.Current_Index + 1);
      else
         return Get_Current_Waypoint (Planner);
      end if;
   end Get_Next_Waypoint;

   procedure Advance_Waypoint (Planner : in out Mission_Plan) is
   begin
      if Planner.Current_Index < Planner.Total_Waypoints then
         Planner.Current_Index := Planner.Current_Index + 1;
      end if;
   end Advance_Waypoint;

   function Waypoint_Reached (Planner : Mission_Plan;
                             Current_Position : Flight_Types.Position_3D;
                             Threshold : Flight_Types.Meters) return Boolean is
      Current_WP : constant Waypoint := Get_Current_Waypoint (Planner);
      Distance : Flight_Types.Meters;
      use type Float;
   begin
      Distance := Flight_Types.Magnitude (
         Current_Position - Current_WP.Position
      );
      return Distance <= Threshold;
   end Waypoint_Reached;

   function Get_Mission_Phase (Planner : Mission_Plan) return Mission_Phase is
   begin
      return Planner.Current_Phase;
   end Get_Mission_Phase;

   procedure Set_Mission_Phase (Planner : in out Mission_Plan;
                               Phase : Mission_Phase) is
   begin
      Planner.Current_Phase := Phase;
   end Set_Mission_Phase;

   function Calculate_Route (From : Flight_Types.Position_3D;
                            To   : Waypoint) return Flight_Types.Position_3D is
   begin
      return To.Position - From;
   end Calculate_Route;

   function Get_Mission_Progress (Planner : Mission_Plan) return Float is
   begin
      if Planner.Total_Waypoints > 0 then
         return Float (Planner.Current_Index) / Float (Planner.Total_Waypoints);
      else
         return 0.0;
      end if;
   end Get_Mission_Progress;

end Mission_Planner;
