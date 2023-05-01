package alternativa.tanks.vehicles.tank.weapons.railgun
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Object3DContainer;
   import alternativa.math.Vector3;
   import alternativa.tanks.display.GameCamera;
   import alternativa.tanks.sfx.AnimatedPlane;
   import alternativa.tanks.sfx.GraphicEffect;
   import alternativa.tanks.sfx.SFXUtils;
   import alternativa.tanks.sfx.TextureAnimation;
   import alternativa.tanks.utils.objectpool.Pool;
   import alternativa.tanks.utils.objectpool.PooledObject;
   
   use namespace alternativa3d;
   
   public class FixedBeamEffect extends PooledObject implements GraphicEffect
   {
      
      public static const BASE_WIDTH:Number = 10;
       
      
      private var startPoint:Vector3;
      
      private var direction:Vector3;
      
      private var scaleSpeed:Number;
      
      private var alphaSpeed:Number;
      
      private var currScale:Number;
      
      private var timeToLive:int;
      
      private var currentTime:int;
      
      private var maxTime:int;
      
      private var plane:AnimatedPlane;
      
      public function FixedBeamEffect(objectPool:Pool)
      {
         this.startPoint = new Vector3();
         this.direction = new Vector3();
         super(objectPool);
         this.plane = new AnimatedPlane(100);
      }
      
      public function init(startPoint:Vector3, endPoint:Vector3, fps:Number, animationData:TextureAnimation) : void
      {
         this.startPoint = endPoint;
         this.plane.init(animationData,0.001 * fps);
         this.maxTime = this.plane.getOneLoopTime();
         this.currentTime = 0;
         this.scaleSpeed = 0.001 * this.scaleSpeed;
         this.direction.diff(endPoint,startPoint);
         var length:Number = this.direction.length();
         this.direction.scale(1 / length);
         trace("dir",this.direction);
         this.plane.x = endPoint.x;
         this.plane.y = endPoint.y;
         this.plane.z = endPoint.z;
         this.plane.scaleX = 0.4;
         this.plane.scaleY = 6;
      }
      
      public function play(millis:int, camera:GameCamera) : Boolean
      {
         if(this.currentTime >= this.maxTime)
         {
            return false;
         }
         this.plane.setTime(this.currentTime);
         this.currentTime += millis;
         SFXUtils.alignObjectPlaneToView(this.plane,this.startPoint,this.direction,camera.position);
         return true;
      }
      
      public function addedToScene(container:Object3DContainer) : void
      {
         container.addChild(this.plane);
      }
      
      public function destroy() : void
      {
         this.plane.removeFromParent();
         this.plane.clear();
         recycle();
      }
      
      public function kill() : void
      {
         this.currentTime = this.maxTime;
      }
   }
}
