package alternativa.physics
{
   import alternativa.math.Matrix3;
   import alternativa.math.Vector3;
   
   public class PhysicsUtils
   {
       
      
      public function PhysicsUtils()
      {
         super();
      }
      
      public static function setBoxInvInertia(mass:Number, halfSize:Vector3, result:Matrix3) : void
      {
         if(mass <= 0)
         {
            throw new ArgumentError();
         }
         result.copy(Matrix3.ZERO);
         if(mass == Infinity)
         {
            return;
         }
         var xx:Number = halfSize.x * halfSize.x;
         var yy:Number = halfSize.y * halfSize.y;
         var zz:Number = halfSize.z * halfSize.z;
         result.a = 3 / (mass * (yy + zz));
         result.f = 3 / (mass * (zz + xx));
         result.k = 3 / (mass * (xx + yy));
      }
      
      public static function getCylinderInvInertia(mass:Number, r:Number, h:Number, result:Matrix3) : void
      {
         if(mass <= 0)
         {
            throw new ArgumentError();
         }
         result.copy(Matrix3.ZERO);
         if(mass == Infinity)
         {
            return;
         }
         result.a = result.f = 1 / (mass * (h * h / 12 + r * r / 4));
         result.k = 2 / (mass * r * r);
      }
   }
}
