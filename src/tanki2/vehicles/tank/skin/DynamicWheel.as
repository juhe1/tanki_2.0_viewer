package tanki2.vehicles.tank.skin 
{
   import alternativa.engine3d.objects.Joint;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.objects.Skin;
   import flash.geom.Vector3D;
	/**
    * ...
    * @author juhe
    */
   public class DynamicWheel 
   {
      private static var ADDITIONAL_Z_OFFSET:Number = 3;
      
      public var mesh:Mesh;
      
      public var originalPosition:Vector3D;
      
      public var wheelZOffset:Number;
      
      public var joint:Joint;
      
      public function DynamicWheel(mesh:Mesh, joint:Joint) 
      {
         this.mesh = mesh;
         this.joint = joint;
         this.originalPosition = new Vector3D(mesh.x, mesh.y, mesh.z);
         
         this.wheelZOffset = (Math.abs(mesh.boundBox.minZ) + mesh.boundBox.maxZ) / 2 + ADDITIONAL_Z_OFFSET;
      }
      
   }

}