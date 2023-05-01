package tanki2.vehicles.tank.weapons
{
   import alternativa.engine3d.materials.TextureMaterial;
   import alternativa.math.Vector3;
   import tanki2.Game;
   
   public class Smoky extends Weapon
   {
      
      private static const SHOT_GRAPHIC_EFFECT_LIFE_TIME:int = 100;
      
      private static const RELOAD_TIME:uint = 500;
      
      private static const UP_ANGLE:Number = 10 * Math.PI / 180;
      
      private static const DOWN_ANGLE:Number = 10 * Math.PI / 180;
      
      private static const UP_RAYS:int = 10;
      
      private static const DOWN_RAYS:int = 10;
      
      private static var muzzleFlashMateial:TextureMaterial;
       
      
      private var readyTime:uint;
      
      private const targetingSystem:CommonTargetingSystem = new CommonTargetingSystem();
      
      private const hitInfo:HitInfo = new HitInfo();
      
      public function Smoky()
      {
         super("Средне-дальнобойные");
      }
      
      override public function update(time:int, delta:int) : void
      {
         if(active && time >= this.readyTime)
         {
            this.readyTime = time + RELOAD_TIME;
            this.fire();
         }
      }

      private function fire() : void
      {
         var game:Game = Game.getInstance();
         calculateTurretParams();
         if(this.targetingSystem.getTarget(10000000000,muzzlePosition,barrelDirection,xAxis,UP_ANGLE,UP_RAYS,DOWN_ANGLE,DOWN_RAYS,game.getCollisionDetector(),tank,this.hitInfo))
         {
            
         }
         barrelDirection.scale(-20000000);
         tank.chassis.addWorldForce(muzzlePosition,barrelDirection);
      }
      
   }
}
