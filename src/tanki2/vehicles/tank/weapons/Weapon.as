package tanki2.vehicles.tank.weapons
{
   import alternativa.math.Vector3;
   import tanki2.vehicles.tank.Tank;
   import flash.geom.Matrix3D;
   
   public class Weapon
   {
      
      private static const vin:Vector.<Number> = Vector.<Number>([0,0,0,1,0,0,0,1,0,0,0,0]);
      
      private static const vout:Vector.<Number> = Vector.<Number>([0,0,0,1,0,0,0,1,0,0,0,0]);
       
      
      public var name:String;
      
      public var tank:Tank;
      
      protected var active:Boolean;
      
      protected var muzzlePosition:Vector3;
      
      protected var barrelDirection:Vector3;
      
      protected var xAxis:Vector3;
      
      public function Weapon(name:String)
      {
         this.muzzlePosition = new Vector3();
         this.barrelDirection = new Vector3();
         this.xAxis = new Vector3();
         super();
         this.name = name;
      }
      
      public function start() : void
      {
         if(this.active)
         {
            return;
         }
         this.active = true;
         this.onStart();
      }
      
      protected function onStart() : void
      {
      }
      
      public function stop() : void
      {
         if(!this.active)
         {
            return;
         }
         this.active = false;
         this.onStop();
      }
      
      protected function onStop() : void
      {
      }
      
      public function update(time:int, delta:int) : void
      {
      }
      
      public function setNextEffects() : void
      {
      }
      
      public function setPrevEffects() : void
      {
      }
      
      public function getEffectsName() : String
      {
         return "";
      }
      
      public function calculateTurretParams() : void
      {
         var m:Matrix3D = this.tank.skin.turretMesh.matrix;
         var v:Vector3 = this.tank.turret.muzzlePoints[0];
         vin[9] = v.x;
         vin[10] = v.y;
         vin[11] = v.z;
         m.transformVectors(vin,vout);
         this.muzzlePosition.x = vout[9];
         this.muzzlePosition.y = vout[10];
         this.muzzlePosition.z = vout[11];
         this.xAxis.x = vout[0];
         this.xAxis.y = vout[1];
         this.xAxis.z = vout[2];
         this.barrelDirection.x = vout[6] - this.xAxis.x;
         this.barrelDirection.y = vout[7] - this.xAxis.y;
         this.barrelDirection.z = vout[8] - this.xAxis.z;
         this.xAxis.x = vout[3] - this.xAxis.x;
         this.xAxis.y = vout[4] - this.xAxis.y;
         this.xAxis.z = vout[5] - this.xAxis.z;
      }
      
      public function getMuzzlePosition() : Vector3
      {
         return this.muzzlePosition;
      }
      
      public function getBarrelDirection() : Vector3
      {
         return this.barrelDirection;
      }
   }
}
