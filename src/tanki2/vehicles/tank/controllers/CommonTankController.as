package tanki2.vehicles.tank.controllers
{
   import tanki2.GameObject;
   import tanki2.IGameObjectController;
   import tanki2.vehicles.tank.Tank;
   import tanki2.vehicles.tank.weapons.Weapon;
   
   public class CommonTankController implements IGameObjectController
   {
      
      public static const BIT_TURRET_LEFT:int = 0;
      
      public static const BIT_TURRET_RIGHT:int = 1;
      
      public static const BIT_FORWARD:int = 2;
      
      public static const BIT_BACKWARD:int = 3;
      
      public static const BIT_TURN_LEFT:int = 4;
      
      public static const BIT_TURN_RIGHT:int = 5;
      
      public static const BIT_FIRE_WEAPON:int = 6;
       
      
      protected var controlBits:int;
      
      public function CommonTankController()
      {
         super();
      }
      
      public function startTurretRotationLeft() : void
      {
         this.controlBits |= 1 << BIT_TURRET_LEFT;
      }
      
      public function stopTurretRotationLeft() : void
      {
         this.controlBits &= ~(1 << BIT_TURRET_LEFT);
      }
      
      public function startTurretRotationRight() : void
      {
         this.controlBits |= 1 << BIT_TURRET_RIGHT;
      }
      
      public function stopTurretRotationRight() : void
      {
         this.controlBits &= ~(1 << BIT_TURRET_RIGHT);
      }
      
      public function startMoveForward() : void
      {
         this.controlBits |= 1 << BIT_FORWARD;
      }
      
      public function stopMoveForward() : void
      {
         this.controlBits &= ~(1 << BIT_FORWARD);
      }
      
      public function startMoveBackward() : void
      {
         this.controlBits |= 1 << BIT_BACKWARD;
      }
      
      public function stopMoveBackward() : void
      {
         this.controlBits &= ~(1 << BIT_BACKWARD);
      }
      
      public function startTurnLeft() : void
      {
         this.controlBits |= 1 << BIT_TURN_LEFT;
      }
      
      public function stopTurnLeft() : void
      {
         this.controlBits &= ~(1 << BIT_TURN_LEFT);
      }
      
      public function startTurnRight() : void
      {
         this.controlBits |= 1 << BIT_TURN_RIGHT;
      }
      
      public function stopTurnRight() : void
      {
         this.controlBits &= ~(1 << BIT_TURN_RIGHT);
      }
      
      public function startAction(actionBit:int) : void
      {
         this.controlBits |= 1 << actionBit;
      }
      
      public function stopAction(actionBit:int) : void
      {
         this.controlBits &= ~(1 << actionBit);
      }
      
      public function update(object:GameObject, time:uint, deltaMsec:uint, deltaSec:Number) : void
      {
         var tank:Tank = Tank(object);
         tank.chassis._turretTurnDirection = this.getInput(BIT_TURRET_RIGHT,BIT_TURRET_LEFT);
         var movingDir:int = this.getInput(BIT_FORWARD,BIT_BACKWARD);
         var turnDir:int = this.getInput(BIT_TURN_RIGHT,BIT_TURN_LEFT);
         if(movingDir < 0)
         {
            turnDir = -turnDir;
         }
         tank.chassis.setControls(movingDir,turnDir,false);
         var weapon:Weapon = tank.getWeapon();
         if(weapon != null)
         {
            if((this.controlBits & 1 << BIT_FIRE_WEAPON) == 0)
            {
               weapon.stop();
            }
            else
            {
               weapon.start();
            }
         }
      }
      
      protected function getInput(bit1:int, bit2:int) : int
      {
         return ((this.controlBits & 1 << bit1) >> bit1) - ((this.controlBits & 1 << bit2) >> bit2);
      }
   }
}
