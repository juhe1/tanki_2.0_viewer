package tanki2.vehicles.tank.weapons.sfx
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.math.Vector3;
   import alternativa.physics.collision.CollisionDetector;
   import alternativa.physics.collision.types.RayHit;
   import alternativa.tanks.Game;
   import alternativa.tanks.LogicUnit;
   import alternativa.tanks.display.GameCamera;
   import alternativa.tanks.physics.CollisionGroup;
   import alternativa.tanks.sfx.AnimatedSpriteEffect;
   import alternativa.tanks.sfx.Object3DPositionProvider;
   import alternativa.tanks.sfx.TextureAnimation;
   import alternativa.tanks.utils.objectpool.Pool;
   import alternativa.tanks.utils.objectpool.PooledObject;
   import alternativa.tanks.vehicles.tank.weapons.IPlasmaShotListener;
   import alternativa.tanks.vehicles.tank.weapons.PlasmaGunData;
   
   public class PlasmaShot extends PooledObject implements LogicUnit, Object3DPositionProvider
   {
      
      private static const rayHit:RayHit = new RayHit();
       
      
      public var totalDistance:Number = 0;
      
      private var currPosition:Vector3;
      
      private var direction:Vector3;
      
      private var collisionDetector:CollisionDetector;
      
      private var plasmaShotListener:IPlasmaShotListener;
      
      private var plasmaData:PlasmaGunData;
      
      private var effect:AnimatedSpriteEffect;
      
      public function PlasmaShot(pool:Pool)
      {
         super(pool);
      }
      
      public function init(plasmaData:PlasmaGunData, startPos:Vector3, direction:Vector3, collisionDetector:CollisionDetector, chargeListener:IPlasmaShotListener) : void
      {
         this.plasmaData = plasmaData;
         this.currPosition = startPos.clone();
         this.direction = direction.clone();
         this.plasmaShotListener = chargeListener;
         this.collisionDetector = collisionDetector;
         this.createShot(300,300);
      }
      
      public function tick(time:uint, deltaMs:uint) : void
      {
         var i:int = 0;
         var p:Vector3 = null;
         var dz:Number = NaN;
         if(this.totalDistance > this.plasmaData.maxRange)
         {
            this.plasmaShotListener.shotDissolved(this);
            this.effect.kill();
            return;
         }
         var distance:Number = this.plasmaData.shotSpeed * deltaMs / 1000;
         this.totalDistance += distance;
         if(this.collisionDetector.raycast(this.currPosition,this.direction,CollisionGroup.WEAPON,distance,null,rayHit))
         {
            this.plasmaShotListener.shotHit(this,rayHit.position,this.direction,null,1);
            this.effect.kill();
            return;
         }
         var dx:Number = distance * this.direction.x;
         var dy:Number = distance * this.direction.y;
         dz = distance * this.direction.z;
         this.currPosition.x += dx;
         this.currPosition.y += dy;
         this.currPosition.z += dz;
      }
      
      public function destroy() : void
      {
         Game.getInstance().logicUnitsSystem.remove(this);
      }
      
      private function createShot(width:Number, height:Number) : void
      {
         var game:Game = Game.getInstance();
         var animation:TextureAnimation = game.config.textureAnimations.getAnimation("plasma/shot");
         this.effect = AnimatedSpriteEffect(Game.getInstance().getObjectFromPool(AnimatedSpriteEffect));
         this.effect.initLooped(width,height,animation,2 * Math.PI * Math.random(),this);
         game.getBattleService().getBattleScene3D().addGraphicEffect(this.effect);
      }
      
      public function initPosition(object:Object3D) : void
      {
         object.x = this.currPosition.x;
         object.y = this.currPosition.y;
         object.z = this.currPosition.z;
      }
      
      public function updateObjectPosition(object:Object3D, camera:GameCamera, timeDeltaMs:int) : void
      {
         object.x = this.currPosition.x;
         object.y = this.currPosition.y;
         object.z = this.currPosition.z;
      }
   }
}
