package alternativa.physics.collision.colliders
{
   import alternativa.math.Matrix4;
   import alternativa.math.Vector3;
   import alternativa.physics.Contact;
   import alternativa.physics.ContactPoint;
   import alternativa.physics.collision.CollisionPrimitive;
   import alternativa.physics.collision.ICollider;
   import alternativa.physics.collision.primitives.CollisionBox;
   import alternativa.physics.collision.primitives.CollisionSphere;
   
   public class BoxSphereCollider implements ICollider
   {
       
      
      private var center:Vector3;
      
      private var closestPt:Vector3;
      
      private var bPos:Vector3;
      
      private var sPos:Vector3;
      
      public function BoxSphereCollider()
      {
         this.center = new Vector3();
         this.closestPt = new Vector3();
         this.bPos = new Vector3();
         this.sPos = new Vector3();
         super();
      }
      
      public function getContact(prim1:CollisionPrimitive, prim2:CollisionPrimitive, contact:Contact) : Boolean
      {
         var box:CollisionBox = null;
         var contactPoint:ContactPoint = null;
         var sphere:CollisionSphere = prim1 as CollisionSphere;
         if(sphere == null)
         {
            sphere = prim2 as CollisionSphere;
            box = prim1 as CollisionBox;
         }
         else
         {
            box = prim2 as CollisionBox;
         }
         var sphereTransform:Matrix4 = sphere.transform;
         sphereTransform.getAxis(3,this.sPos);
         var boxTransform:Matrix4 = box.transform;
         boxTransform.getAxis(3,this.bPos);
         boxTransform.transformVectorInverse(this.sPos,this.center);
         var hs:Vector3 = box.hs;
         var sx:Number = hs.x + sphere.r;
         var sy:Number = hs.y + sphere.r;
         var sz:Number = hs.z + sphere.r;
         if(this.center.x > sx || this.center.x < -sx || this.center.y > sy || this.center.y < -sy || this.center.z > sz || this.center.z < -sz)
         {
            return false;
         }
         if(this.center.x > hs.x)
         {
            this.closestPt.x = hs.x;
         }
         else if(this.center.x < -hs.x)
         {
            this.closestPt.x = -hs.x;
         }
         else
         {
            this.closestPt.x = this.center.x;
         }
         if(this.center.y > hs.y)
         {
            this.closestPt.y = hs.y;
         }
         else if(this.center.y < -hs.y)
         {
            this.closestPt.y = -hs.y;
         }
         else
         {
            this.closestPt.y = this.center.y;
         }
         if(this.center.z > hs.z)
         {
            this.closestPt.z = hs.z;
         }
         else if(this.center.z < -hs.z)
         {
            this.closestPt.z = -hs.z;
         }
         else
         {
            this.closestPt.z = this.center.z;
         }
         var distSqr:Number = this.center.subtract(this.closestPt).lengthSqr();
         if(distSqr > sphere.r * sphere.r)
         {
            return false;
         }
         for(var i:int = 0; i < contact.pcount; i++)
         {
            contactPoint = contact.points[i];
            contactPoint.primitive1 = sphere;
            contactPoint.primitive2 = box;
         }
         contact.body1 = sphere.body;
         contact.body2 = box.body;
         contact.normal.copy(this.closestPt).transform4(boxTransform).subtract(this.sPos).normalize().reverse();
         contact.pcount = 1;
         var cp:ContactPoint = contact.points[0];
         cp.penetration = sphere.r - Math.sqrt(distSqr);
         cp.position.copy(contact.normal).scale(-sphere.r).add(this.sPos);
         cp.r1.diff(cp.position,this.sPos);
         cp.r2.diff(cp.position,this.bPos);
         return true;
      }
      
      public function haveCollision(prim1:CollisionPrimitive, prim2:CollisionPrimitive) : Boolean
      {
         var box:CollisionBox = null;
         var sphere:CollisionSphere = prim1 as CollisionSphere;
         if(sphere == null)
         {
            sphere = prim2 as CollisionSphere;
            box = prim1 as CollisionBox;
         }
         else
         {
            box = prim2 as CollisionBox;
         }
         var sphereTransform:Matrix4 = sphere.transform;
         sphereTransform.getAxis(3,this.sPos);
         var boxTransform:Matrix4 = box.transform;
         boxTransform.getAxis(3,this.bPos);
         boxTransform.transformVectorInverse(this.sPos,this.center);
         var hs:Vector3 = box.hs;
         var sx:Number = hs.x + sphere.r;
         var sy:Number = hs.y + sphere.r;
         var sz:Number = hs.z + sphere.r;
         if(this.center.x > sx || this.center.x < -sx || this.center.y > sy || this.center.y < -sy || this.center.z > sz || this.center.z < -sz)
         {
            return false;
         }
         if(this.center.x > hs.x)
         {
            this.closestPt.x = hs.x;
         }
         else if(this.center.x < -hs.x)
         {
            this.closestPt.x = -hs.x;
         }
         else
         {
            this.closestPt.x = this.center.x;
         }
         if(this.center.y > hs.y)
         {
            this.closestPt.y = hs.y;
         }
         else if(this.center.y < -hs.y)
         {
            this.closestPt.y = -hs.y;
         }
         else
         {
            this.closestPt.y = this.center.y;
         }
         if(this.center.z > hs.z)
         {
            this.closestPt.z = hs.z;
         }
         else if(this.center.z < -hs.z)
         {
            this.closestPt.z = -hs.z;
         }
         else
         {
            this.closestPt.z = this.center.z;
         }
         var distSqr:Number = this.center.subtract(this.closestPt).lengthSqr();
         return distSqr <= sphere.r * sphere.r;
      }
   }
}
