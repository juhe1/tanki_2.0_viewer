package tanki2.vehicles.tank.weapons.sfx
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Object3DContainer;
   import alternativa.math.Matrix4;
   import alternativa.math.Vector3;
   import alternativa.tanks.display.GameCamera;
   import alternativa.tanks.sfx.GraphicEffect;
   import alternativa.tanks.sfx.SFXUtils;
   import alternativa.tanks.sfx.TextureAnimation;
   import alternativa.tanks.utils.objectpool.Pool;
   import alternativa.tanks.utils.objectpool.PooledObject;
   
   use namespace alternativa3d;
   
   public class MuzzleStreamEffect extends PooledObject implements GraphicEffect
   {
      
      private static const m:Matrix4 = new Matrix4();
      
      private static const globalMuzzlePosition:Vector3 = new Vector3();
      
      private static const gunDirection:Vector3 = new Vector3();
       
      
      private var plane:FreezeMuzzlePlane;
      
      private var alive:Boolean;
      
      private var localMuzzlePosition:Vector3;
      
      private var turretMesh:Object3D;
      
      public function MuzzleStreamEffect(pool:Pool)
      {
         this.localMuzzlePosition = new Vector3();
         super(pool);
      }
      
      public function init(width:Number, length:Number, animation:TextureAnimation, turretMesh:Object3D, localMuzzlePositon:Vector3) : void
      {
         this.plane = new FreezeMuzzlePlane(width,length);
         this.plane.init(animation);
         this.alive = true;
         animation.material.mipMapping = 0;
         this.turretMesh = turretMesh;
         this.localMuzzlePosition.copy(localMuzzlePositon);
      }
      
      public function addedToScene(container:Object3DContainer) : void
      {
         container.addChild(this.plane);
      }
      
      public function play(timeDeltaMs:int, camera:GameCamera) : Boolean
      {
         m.setMatrix(this.turretMesh.x,this.turretMesh.y,this.turretMesh.z,this.turretMesh.rotationX,this.turretMesh.rotationY,this.turretMesh.rotationZ);
         m.transformVector(this.localMuzzlePosition,globalMuzzlePosition);
         m.getAxis(1,gunDirection);
         SFXUtils.alignObjectPlaneToView(this.plane,globalMuzzlePosition,gunDirection,camera.position);
         this.plane.update(timeDeltaMs / 1000);
         return this.alive;
      }
      
      public function destroy() : void
      {
         this.plane.removeFromParent();
         this.plane = null;
         this.turretMesh = null;
      }
      
      public function kill() : void
      {
         this.alive = false;
      }
   }
}
