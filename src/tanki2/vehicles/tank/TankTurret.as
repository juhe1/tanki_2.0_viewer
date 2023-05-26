package tanki2.vehicles.tank
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.math.Vector3;
   import alternativa.engine3d.alternativa3d;
   import tanki2.utils.Utils3D;
   
   public class TankTurret extends TankPart
   {
      public var muzzlePoints:Vector.<Vector3>;
      
      public var flagMountPoint:Vector3;
      
      public function TankTurret(part:Part)
      {
         var muzzlePointObjects:Vector.<Object3D> = Utils3D.findChildsWithNameBeginning(part.object, "buzzle");
         this.muzzlePoints = this.objectsToPositions(muzzlePointObjects);
         
         var flagMountPointObject:Object3D = part.object.getChildByName("fmnt");
         this.flagMountPoint = new Vector3(flagMountPointObject.matrix.position.x, flagMountPointObject.matrix.position.y, flagMountPointObject.matrix.position.z)
         
         this.mainMesh = Mesh(part.object)
         this.mainMesh.geometry.calculateTangents(0);
         super(part);
      }
      
      private function objectsToPositions(objects:Vector.<Object3D>):Vector.<Vector3> 
      {
         var positions:Vector.<Vector3> = new Vector.<Vector3>();
         for each (var object:Object3D in objects) 
         {
            positions.push(new Vector3(object.matrix.position.x, object.matrix.position.y, object.matrix.position.z));
         }
         return positions;
      }
   }
}
