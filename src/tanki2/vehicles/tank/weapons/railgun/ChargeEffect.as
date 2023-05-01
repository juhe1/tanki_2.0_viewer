package alternativa.tanks.vehicles.tank.weapons.railgun
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Object3DContainer;
   import alternativa.engine3d.materials.TextureMaterial;
   import alternativa.engine3d.objects.Sprite3D;
   import alternativa.math.Matrix4;
   import alternativa.math.Vector3;
   import alternativa.tanks.display.GameCamera;
   import alternativa.tanks.sfx.GraphicEffect;
   import alternativa.tanks.sfx.SFXUtils;
   import alternativa.tanks.sfx.TextureAnimation;
   import alternativa.tanks.sfx.UVFrame;
   import alternativa.tanks.utils.objectpool.Pool;
   import alternativa.tanks.utils.objectpool.PooledObject;
   import flash.geom.ColorTransform;
   
   use namespace alternativa3d;
   
   public class ChargeEffect extends PooledObject implements GraphicEffect
   {
      
      private static const globalPosition:Vector3 = new Vector3();
      
      private static const matrix:Matrix4 = new Matrix4();
       
      
      protected var sprite:Sprite3D;
      
      private var framesPerMillisecond:Number;
      
      private var currFrame:Number;
      
      private var frames:Vector.<UVFrame>;
      
      private var numFrames:int;
      
      private var localMuzzlePosition:Vector3;
      
      private var turret:Object3D;
      
      public function ChargeEffect(objectPool:Pool)
      {
         this.localMuzzlePosition = new Vector3();
         super(objectPool);
         this.sprite = new Sprite3D(1,1);
      }
      
      public function init(width:Number, height:Number, sequence:TextureAnimation, localMuzzlePosition:Vector3, turret:Object3D, rotation:Number, colorTransform:ColorTransform) : void
      {
         this.initSprite(width,height,rotation,colorTransform,sequence.material);
         this.frames = sequence.frames;
         this.framesPerMillisecond = 0.001 * sequence.fps;
         this.localMuzzlePosition.copy(localMuzzlePosition);
         this.localMuzzlePosition.y += 10;
         this.turret = turret;
         this.numFrames = this.frames.length;
         this.currFrame = 0;
      }
      
      public function addedToScene(container:Object3DContainer) : void
      {
         container.addChild(this.sprite);
      }
      
      public function play(timeDelta:int, camera:GameCamera) : Boolean
      {
         if(this.currFrame >= this.numFrames)
         {
            return false;
         }
         matrix.setMatrix(this.turret.x,this.turret.y,this.turret.z,this.turret.rotationX,this.turret.rotationY,this.turret.rotationZ);
         matrix.transformVector(this.localMuzzlePosition,globalPosition);
         this.sprite.x = globalPosition.x;
         this.sprite.y = globalPosition.y;
         this.sprite.z = globalPosition.z;
         this.setFrame(this.frames[int(this.currFrame)]);
         this.currFrame += this.framesPerMillisecond * timeDelta;
         return true;
      }
      
      private function setFrame(uvRegion:UVFrame) : void
      {
         this.sprite.topLeftU = uvRegion.topLeftU;
         this.sprite.topLeftV = uvRegion.topLeftV;
         this.sprite.bottomRightU = uvRegion.bottomRightU;
         this.sprite.bottomRightV = uvRegion.bottomRightV;
      }
      
      public function destroy() : void
      {
         this.sprite.removeFromParent();
         this.sprite.material = null;
         this.frames = null;
         recycle();
      }
      
      public function kill() : void
      {
         this.currFrame = this.numFrames + 1;
      }
      
      private function initSprite(width:Number, height:Number, rotation:Number, colorTransform:ColorTransform, material:TextureMaterial) : void
      {
         this.sprite.width = width;
         this.sprite.height = height;
         this.sprite.rotation = rotation;
         this.sprite.material = material;
         this.setSpriteColorTransform(colorTransform);
      }
      
      private function setSpriteColorTransform(colorTransform:ColorTransform) : void
      {
         if(colorTransform == null)
         {
            this.sprite.colorTransform = null;
         }
         else
         {
            if(this.sprite.colorTransform == null)
            {
               this.sprite.colorTransform = new ColorTransform();
            }
            SFXUtils.copyColorTransform(colorTransform,this.sprite.colorTransform);
         }
      }
   }
}
