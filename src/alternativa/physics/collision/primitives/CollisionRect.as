package alternativa.physics.collision.primitives
{
   import alternativa.math.Matrix4;
   import alternativa.math.Vector3;
   import alternativa.physics.PhysicsMaterial;
   import alternativa.physics.collision.CollisionPrimitive;
   import alternativa.physics.collision.types.AABB;
   
   public class CollisionRect extends CollisionPrimitive
   {
      
      private static const EPSILON:Number = 0.005;
       
      
      public var hs:Vector3;
      
      public function CollisionRect(hs:Vector3, collisionGroup:int, material:PhysicsMaterial)
      {
         this.hs = new Vector3();
         super(RECT,collisionGroup,material);
         this.hs.copy(hs);
      }
      
      override public function calculateAABB() : AABB
      {
         var t:Matrix4 = null;
         t = transform;
         var xx:Number = t.a < 0 ? Number(-t.a) : Number(t.a);
         var yy:Number = t.b < 0 ? Number(-t.b) : Number(t.b);
         var zz:Number = t.c < 0 ? Number(-t.c) : Number(t.c);
         var aabb:AABB = this.aabb;
         aabb.maxX = this.hs.x * xx + this.hs.y * yy + EPSILON * zz;
         aabb.minX = -aabb.maxX;
         xx = t.e < 0 ? Number(-t.e) : Number(t.e);
         yy = t.f < 0 ? Number(-t.f) : Number(t.f);
         zz = t.g < 0 ? Number(-t.g) : Number(t.g);
         aabb.maxY = this.hs.x * xx + this.hs.y * yy + EPSILON * zz;
         aabb.minY = -aabb.maxY;
         xx = t.i < 0 ? Number(-t.i) : Number(t.i);
         yy = t.j < 0 ? Number(-t.j) : Number(t.j);
         zz = t.k < 0 ? Number(-t.k) : Number(t.k);
         aabb.maxZ = this.hs.x * xx + this.hs.y * yy + EPSILON * zz;
         aabb.minZ = -aabb.maxZ;
         aabb.minX += t.d;
         aabb.maxX += t.d;
         aabb.minY += t.h;
         aabb.maxY += t.h;
         aabb.minZ += t.l;
         aabb.maxZ += t.l;
         return aabb;
      }
      
      override public function copyFrom(source:CollisionPrimitive) : CollisionPrimitive
      {
         var rect:CollisionRect = source as CollisionRect;
         if(rect == null)
         {
            return this;
         }
         super.copyFrom(rect);
         this.hs.copy(rect.hs);
         return this;
      }
      
      override protected function createPrimitive() : CollisionPrimitive
      {
         return new CollisionRect(this.hs,collisionGroup,material);
      }
      
      override public function raycast(origin:Vector3, vector:Vector3, threshold:Number, normal:Vector3) : Number
      {
         var transform:Matrix4 = null;
         transform = this.transform;
         var vx:Number = origin.x - transform.d;
         var vy:Number = origin.y - transform.h;
         var vz:Number = origin.z - transform.l;
         var ox:Number = transform.a * vx + transform.e * vy + transform.i * vz;
         var oy:Number = transform.b * vx + transform.f * vy + transform.j * vz;
         var oz:Number = transform.c * vx + transform.g * vy + transform.k * vz;
         vx = transform.a * vector.x + transform.e * vector.y + transform.i * vector.z;
         vy = transform.b * vector.x + transform.f * vector.y + transform.j * vector.z;
         vz = transform.c * vector.x + transform.g * vector.y + transform.k * vector.z;
         if(vz > -threshold && vz < threshold)
         {
            return -1;
         }
         var t:Number = -oz / vz;
         if(t < 0)
         {
            return -1;
         }
         ox += vx * t;
         oy += vy * t;
         oz = 0;
         if(ox < -this.hs.x - threshold || ox > this.hs.x + threshold || oy < -this.hs.y - threshold || oy > this.hs.y + threshold)
         {
            return -1;
         }
         if(vector.x * transform.c + vector.y * transform.g + vector.z * transform.k > 0)
         {
            normal.x = -transform.c;
            normal.y = -transform.g;
            normal.z = -transform.k;
         }
         else
         {
            normal.x = transform.c;
            normal.y = transform.g;
            normal.z = transform.k;
         }
         return t;
      }
   }
}
