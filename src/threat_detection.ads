--  Threat Detection and Countermeasures Package
--  Advanced threat detection system for defense applications
--  Implements radar warning, missile detection, and countermeasure deployment

package Threat_Detection is

   type Threat_Type is (
      Radar_Lock,
      Missile_Launch,
      Jamming,
      Cyber_Attack,
      Unknown
   );

   type Threat_Severity is (Low, Medium, High, Critical);

   type Threat_Data is record
      Threat_Type     : Threat_Detection.Threat_Type;
      Severity        : Threat_Severity;
      Bearing         : Float;  --  Degrees
      Range           : Float;   --  Meters
      Velocity        : Float;   --  m/s
      Confidence      : Float range 0.0 .. 1.0;
      Timestamp       : Float;
      Threat_ID       : Natural;
   end record;

   type Countermeasure_Type is (
      Flare,
      Chaff,
      ECM,           --  Electronic Countermeasures
      Evasive_Maneuver,
      None
   );

   type Threat_System is limited private;

   --  Initialize threat detection system
   procedure Initialize (System : in out Threat_System);

   --  Process sensor data and detect threats
   procedure Process_Sensor_Data (System : in out Threat_System;
                                 Sensor_Data : String);

   --  Get current threats
   function Get_Active_Threats (System : Threat_System) return Threat_Data;

   --  Assess threat and recommend countermeasure
   function Assess_Threat (System : Threat_System;
                          Threat  : Threat_Data) return Countermeasure_Type;

   --  Deploy countermeasure
   procedure Deploy_Countermeasure (System : in out Threat_System;
                                   Countermeasure : Countermeasure_Type);

   --  Get threat statistics
   type Threat_Stats is record
      Total_Threats_Detected : Natural;
      Active_Threats         : Natural;
      Countermeasures_Used   : Natural;
      False_Positives        : Natural;
   end record;

   function Get_Statistics (System : Threat_System) return Threat_Stats;

private

   type Threat_System is limited record
      Active_Threats : Threat_Data;
      Stats          : Threat_Stats;
      Initialized    : Boolean;
   end record;

end Threat_Detection;
