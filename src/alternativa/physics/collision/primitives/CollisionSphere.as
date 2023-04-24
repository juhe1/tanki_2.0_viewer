package alternativa.physics.collision.primitives
{
   import alternativa.math.Matrix4;
   import alternativa.math.Vector3;
   import alternativa.physics.PhysicsMaterial;
   import alternativa.physics.collision.CollisionPrimitive;
   import alternativa.physics.collision.types.AABB;
   
   public class CollisionSphere extends CollisionPrimitive
   {
       
      
      public var r:Number = 0;
      
      public function CollisionSphere(r:Number, collisionGroup:int, material:PhysicsMaterial)
      {
         super(SPHERE,collisionGroup,material);
         this.r = r;
      }
      
      override public function calculateAABB() : AABB
      {
         var aabb:AABB = null;
         var transform:Matrix4 = null;
         aabb = this.aabb;
         transform = this.transform;
         aabb.maxX = transform.d + this.r;
         aabb.minX = transform.d - this.r;
         aabb.maxY = transform.h + this.r;
         aabb.minY = transform.h - this.r;
         aabb.maxZ = transform.l + this.r;
         aabb.minZ = transform.l - this.r;
         return aabb;
      }
      
      override public function raycast(origin:Vector3, vector:Vector3, threshold:Number, normal:Vector3) : Number
      {
         var transform:Matrix4 = this.transform;
         var px:Number = origin.x - transform.d;
         var py:Number = origin.y - transform.h;
         var pz:Number = origin.z - transform.l;
         var k:Number = vector.x * px + vector.y * py + vector.z * pz;
         if(k > 0)
         {
            return -1;
         }
         var a:Number = vector.x * vector.x + vector.y * vector.y + vector.z * vector.z;
         var D:Number = k * k - a * (px * px + py * py + pz * pz - this.r * this.r);
         if(D < 0)
         {
            return -1;
         }
         return -(k + Math.sqrt(D)) / a;
      }
      
      override public function copyFrom(source:CollisionPrimitive) : CollisionPrimitive
      {
         var sphere:CollisionSphere = source as CollisionSphere;
         if(sphere == null)
         {
            return this;
         }
         super.copyFrom(sphere);
         this.r = sphere.r;
         return this;
      }
      
      override protected function createPrimitive() : CollisionPrimitive
      {
         return new CollisionSphere(this.r,collisionGroup,material);
      }
   }
}
