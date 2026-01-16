--  Redundancy Manager Package Implementation

package body Redundancy_Manager is

   procedure Initialize (System : in out Redundancy_System) is
   begin
      for Comp in System_Component loop
         System.Components (Comp) := (
            Component => Comp,
            Status => Unknown,
            Redundancy => Single,
            Primary_Active => True,
            Backup_Count => 0,
            Last_Check => 0.0
         );
      end loop;
      System.Initialized := True;
   end Initialize;

   procedure Register_Component (System     : in out Redundancy_System;
                                 Component  : System_Component;
                                 Redundancy : Redundancy_Level) is
   begin
      System.Components (Component).Redundancy := Redundancy;
      case Redundancy is
         when Single =>
            System.Components (Component).Backup_Count := 0;
         when Dual =>
            System.Components (Component).Backup_Count := 1;
         when Triple =>
            System.Components (Component).Backup_Count := 2;
      end case;
      System.Components (Component).Status := Operational;
   end Register_Component;

   procedure Check_Health (System    : in out Redundancy_System;
                          Component : System_Component) is
   begin
      --  In production, this would check actual component health
      --  For now, assume operational
      System.Components (Component).Status := Operational;
      System.Components (Component).Last_Check := 0.0;  --  Would use actual time
   end Check_Health;

   function Get_Component_Health (System    : Redundancy_System;
                                 Component : System_Component) return Component_Health is
   begin
      return System.Components (Component);
   end Get_Component_Health;

   procedure Switch_To_Backup (System    : in out Redundancy_System;
                               Component : System_Component) is
   begin
      if System.Components (Component).Backup_Count > 0 then
         System.Components (Component).Primary_Active := False;
         System.Components (Component).Backup_Count :=
            System.Components (Component).Backup_Count - 1;
         System.Components (Component).Status := Degraded;
      else
         System.Components (Component).Status := Failed;
      end if;
   end Switch_To_Backup;

   function Get_System_Health (System : Redundancy_System) return Boolean is
   begin
      for Comp in System_Component loop
         if System.Components (Comp).Status = Failed then
            return False;
         end if;
      end loop;
      return True;
   end Get_System_Health;

   function Vote (System    : Redundancy_System;
                 Component : System_Component;
                 Value1    : Float;
                 Value2    : Float;
                 Value3    : Float) return Float is
      pragma Unreferenced (System, Component);
      --  Median voting for triple modular redundancy
      V1, V2, V3 : Float;
   begin
      --  Sort values
      if Value1 <= Value2 then
         if Value2 <= Value3 then
            V1 := Value1; V2 := Value2; V3 := Value3;
         elsif Value1 <= Value3 then
            V1 := Value1; V2 := Value3; V3 := Value2;
         else
            V1 := Value3; V2 := Value1; V3 := Value2;
         end if;
      else
         if Value1 <= Value3 then
            V1 := Value2; V2 := Value1; V3 := Value3;
         elsif Value2 <= Value3 then
            V1 := Value2; V2 := Value3; V3 := Value1;
         else
            V1 := Value3; V2 := Value2; V3 := Value1;
         end if;
      end if;

      --  Return median (middle value)
      return V2;
   end Vote;

end Redundancy_Manager;
