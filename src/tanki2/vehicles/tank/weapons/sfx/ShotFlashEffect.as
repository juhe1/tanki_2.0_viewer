package tanki2.vehicles.tank.weapons.sfx
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Object3DContainer;
   import alternativa.engine3d.materials.Material;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.math.Matrix4;
   import alternativa.math.Vector3;
   import alternativa.tanks.display.GameCamera;
   import alternativa.tanks.sfx.GraphicEffect;
   import alternativa.tanks.sfx.SFXUtils;
   import alternativa.tanks.utils.objectpool.Pool;
   import alternativa.tanks.utils.objectpool.PooledObject;
   
   use namespace alternativa3d;
   
   public class ShotFlashEffect extends PooledObject implements GraphicEffect
   {
      
      public static const PLANE_WIDTH:Number = 60;
      
      public static const PLANE_LENGTH:Number = 205;
      
      private static const gunDirection:Vector3 = new Vector3();
      
      private static const globalMuzzlePosition:Vector3 = new Vector3();
      
      private static const turretMatrix:Matrix4 = new Matrix4();
       
      
      private var mesh:Mesh;
      
      private var timetoLive:int;
      
      private var turret:Object3D;
      
      private var localMuzzlePosition:Vector3;
      
      public function ShotFlashEffect(objectPool:Pool)
      {
         this.localMuzzlePosition = new Vector3();
         super(objectPool);
      }
      
      public function init(localMuzzlePosition:Vector3, turret:Object3D, material:Material, timetoLive:int, planeWidth:Number, planeLength:Number) : void
      {
         this.mesh = new FlashPlane(planeWidth,planeLength);
         this.localMuzzlePosition.copy(localMuzzlePosition);
         this.turret = turret;
         this.timetoLive = timetoLive;
         this.mesh.setMaterialToAllFaces(material);
      }
      
      public function play(millis:int, camera:GameCamera) : Boolean
      {
         if(this.timetoLive < 0)
         {
            return false;
         }
         this.timetoLive -= millis;
         turretMatrix.setMatrix(this.turret.x,this.turret.y,this.turret.z,this.turret.rotationX,this.turret.rotationY,this.turret.rotationZ);
         turretMatrix.transformVector(this.localMuzzlePosition,globalMuzzlePosition);
         turretMatrix.getAxis(1,gunDirection);
         SFXUtils.alignObjectPlaneToView(this.mesh,globalMuzzlePosition,gunDirection,camera.position);
         return true;
      }
      
      public function destroy() : void
      {
         this.mesh.removeFromParent();
         this.turret = null;
         recycle();
      }
      
      public function kill() : void
      {
         this.timetoLive = -1;
      }
      
      public function addedToScene(container:Object3DContainer) : void
      {
         container.addChild(this.mesh);
      }
   }
}
