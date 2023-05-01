package alternativa.tanks.vehicles.tank.weapons.isis
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Object3DContainer;
   import alternativa.math.Vector3;
   import alternativa.tanks.display.GameCamera;
   import alternativa.tanks.sfx.GraphicEffect;
   import alternativa.tanks.sfx.SFXUtils;
   import alternativa.tanks.utils.objectpool.Pool;
   import alternativa.tanks.utils.objectpool.PooledObject;
   import alternativa.tanks.vehicles.tank.Tank;
   import alternativa.tanks.vehicles.tank.weapons.sfx.PositionProvider;
   
   use namespace alternativa3d;
   
   public class HealingGunShaftEffect extends PooledObject implements GraphicEffect
   {
       
      
      private var shaft:HealingGunShaft;
      
      private var animation:IsisShaftAnimation;
      
      private var tank:Tank;
      
      private var alive:Boolean;
      
      private var startPositionPrivider:PositionProvider;
      
      private var endPositionProvider:PositionProvider;
      
      private const startPosition:Vector3 = new Vector3();
      
      private const endPosition:Vector3 = new Vector3();
      
      private const direction:Vector3 = new Vector3();
      
      public function HealingGunShaftEffect(pool:Pool)
      {
         super(pool);
         this.shaft = new HealingGunShaft();
      }
      
      public function init(isisShaftAnimation:IsisShaftAnimation, startPositionPrivider:PositionProvider, endPositionProvider:PositionProvider) : void
      {
         this.animation = isisShaftAnimation;
         this.startPositionPrivider = startPositionPrivider;
         this.endPositionProvider = endPositionProvider;
         this.tank = this.tank;
         this.shaft.colorTransform = this.animation.colorTransform;
         this.shaft.setAnimationData(this.animation.textureAnimation);
         this.alive = true;
      }
      
      public function addedToScene(container:Object3DContainer) : void
      {
         container.addChild(this.shaft);
      }
      
      public function play(timeDeltaMs:int, camera:GameCamera) : Boolean
      {
         var length:Number = NaN;
         if(this.alive)
         {
            this.startPositionPrivider.readPosition(this.startPosition);
            this.endPositionProvider.readPosition(this.endPosition);
            length = this.startPosition.distanceTo(this.endPosition);
            this.shaft.init(this.animation.shaftWidth,length);
            this.direction.copy(this.endPosition).subtract(this.startPosition).normalize();
            SFXUtils.alignObjectPlaneToView(this.shaft,this.startPosition,this.direction,camera.position);
            this.shaft.setRandomFrame();
            return true;
         }
         return false;
      }
      
      public function destroy() : void
      {
         this.startPositionPrivider = null;
         this.endPositionProvider = null;
         this.animation = null;
         this.tank = null;
         this.shaft.colorTransform = null;
         this.shaft.removeFromParent();
         this.shaft.clear();
         recycle();
      }
      
      public function kill() : void
      {
         this.alive = false;
      }
   }
}
