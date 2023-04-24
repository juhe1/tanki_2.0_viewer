package alternativa.tanks.utils
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.math.Matrix4;
   import alternativa.math.Vector3;
   
   public class Utils3D
   {
      
      private static const eulerAngles:Vector3 = new Vector3();
       
      
      public function Utils3D()
      {
         super();
      }
      
      public static function setObjectTransform(object:Object3D, transform:Matrix4) : void
      {
         transform.getEulerAngles(eulerAngles);
         object.x = transform.d;
         object.y = transform.h;
         object.z = transform.l;
         object.rotationX = eulerAngles.x;
         object.rotationY = eulerAngles.y;
         object.rotationZ = eulerAngles.z;
      }
   }
}
