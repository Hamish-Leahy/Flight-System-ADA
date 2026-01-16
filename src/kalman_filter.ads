--  Kalman Filter Package
--  Generic Kalman filter for sensor fusion and state estimation
--  Used for combining IMU and GPS data in navigation systems

generic
   type Real is digits <>;
   State_Dimension : Positive;
package Kalman_Filter is

   type State_Vector is array (1 .. State_Dimension) of Real;
   type Covariance_Matrix is array (1 .. State_Dimension, 1 .. State_Dimension) of Real;
   type Measurement_Vector is array (1 .. State_Dimension) of Real;

   type Kalman_Config is record
      Process_Noise_Covariance  : Covariance_Matrix;
      Measurement_Noise_Covariance : Covariance_Matrix;
      Initial_State_Covariance  : Covariance_Matrix;
   end record;

   type Kalman_State is private;

   --  Initialize Kalman filter
   function Create (Config      : Kalman_Config;
                    Initial_State : State_Vector) return Kalman_State;

   --  Predict step (time update)
   procedure Predict (Filter     : in out Kalman_State;
                      State_Transition : Covariance_Matrix;
                      Process_Noise    : Covariance_Matrix);

   --  Update step (measurement update)
   procedure Update (Filter      : in out Kalman_State;
                     Measurement : Measurement_Vector;
                     Measurement_Matrix : Covariance_Matrix);

   --  Get current state estimate
   function Get_State (Filter : Kalman_State) return State_Vector;

   --  Get current covariance
   function Get_Covariance (Filter : Kalman_State) return Covariance_Matrix;

private

   type Kalman_State is record
      Config      : Kalman_Config;
      State       : State_Vector;
      Covariance  : Covariance_Matrix;
   end record;

end Kalman_Filter;
