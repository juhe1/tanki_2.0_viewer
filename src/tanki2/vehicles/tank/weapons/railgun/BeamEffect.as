package alternativa.tanks.vehicles.tank.weapons.railgun
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Object3DContainer;
   import alternativa.engine3d.materials.Material;
   import alternativa.math.Vector3;
   import alternativa.tanks.display.GameCamera;
   import alternativa.tanks.sfx.GraphicEffect;
   import alternativa.tanks.sfx.SFXUtils;
   import alternativa.tanks.utils.objectpool.Pool;
   import alternativa.tanks.utils.objectpool.PooledObject;
   import flash.geom.ColorTransform;
   
   use namespace alternativa3d;
   
   public class BeamEffect extends PooledObject implements GraphicEffect
   {
      
      public static const BASE_WIDTH:Number = 10;
       
      
      private var startPoint:Vector3;
      
      private var direction:Vector3;
      
      private var scaleSpeed:Number;
      
      private var alphaSpeed:Number;
      
      private var currScale:Number;
      
      private var timeToLive:int;
      
      private var beam:Beam;
      
      public function BeamEffect(objectPool:Pool)
      {
         this.startPoint = new Vector3();
         this.direction = new Vector3();
         super(objectPool);
         this.beam = new Beam();
      }
      
      public function init(startPoint:Vector3, endPoint:Vector3, material:Material, maxScale:Number, timeToLive:int, colorTransform:ColorTransform) : void
      {
         this.startPoint.copy(startPoint);
         this.timeToLive = timeToLive;
         this.currScale = 1;
         this.scaleSpeed = (maxScale - this.currScale) / timeToLive;
         this.alphaSpeed = 1 / timeToLive;
         this.direction.diff(endPoint,startPoint);
         var length:Number = this.direction.length();
         this.direction.scale(1 / length);
         var textureSpeed:Number = 1;
         var textureAcceleration:Number = 5 * (0 - textureSpeed) / timeToLive * 1000;
         this.beam.init(BASE_WIDTH,length,material,colorTransform,textureSpeed,textureAcceleration);
      }
      
      public function play(millis:int, camera:GameCamera) : Boolean
      {
         if(this.timeToLive < 0)
         {
            return false;
         }
         this.timeToLive -= millis;
         this.currScale += this.scaleSpeed * millis;
         this.beam.alpha -= this.alphaSpeed * millis;
         this.beam.width = BASE_WIDTH * this.currScale;
         this.beam.update(millis);
         SFXUtils.alignObjectPlaneToView(this.beam,this.startPoint,this.direction,camera.position);
         return true;
      }
      
      public function addedToScene(container:Object3DContainer) : void
      {
         container.addChild(this.beam);
      }
      
      public function destroy() : void
      {
         this.beam.removeFromParent();
         recycle();
      }
      
      public function kill() : void
      {
         this.timeToLive = -1;
      }
   }
}
