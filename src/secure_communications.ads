--  Secure Communications Package
--  Defense-grade encrypted communications for command and control
--  Implements AES-256 encryption and secure key exchange

with Interfaces;
use Interfaces;

package Secure_Communications is

   --  Encryption key type (256 bits for AES-256)
   type Encryption_Key is array (1 .. 32) of Unsigned_8;
   type Initialization_Vector is array (1 .. 16) of Unsigned_8;

   --  Secure message structure
   type Secure_Message is private;
   type Message_Type is (Command, Telemetry, Status, Emergency);

   --  Initialize secure communications with encryption key
   procedure Initialize (Key : Encryption_Key);

   --  Encrypt message
   function Encrypt (Plaintext : String;
                    Msg_Type  : Message_Type) return Secure_Message;

   --  Decrypt message
   function Decrypt (Ciphertext : Secure_Message) return String;

   --  Verify message integrity
   function Verify_Integrity (Message : Secure_Message) return Boolean;

   --  Generate secure session key
   function Generate_Session_Key return Encryption_Key;

   --  Secure command structure
   type Secure_Command is record
      Command_ID    : Natural;
      Timestamp     : Float;
      Priority      : Natural range 1 .. 10;
      Authenticated : Boolean;
   end record;

   --  Send secure command
   procedure Send_Secure_Command (Command : Secure_Command;
                                  Payload : String);

   --  Receive secure command
   function Receive_Secure_Command return Secure_Command;

private

   type Secure_Message is record
      Data         : String (1 .. 1024);
      IV           : Initialization_Vector;
      Message_Type : Message_Type;
      Checksum     : Unsigned_32;
      Timestamp    : Float;
   end record;

end Secure_Communications;
