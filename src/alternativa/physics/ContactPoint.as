package alternativa.physics
{
   import alternativa.math.Vector3;
   import alternativa.physics.collision.CollisionPrimitive;
   
   public class ContactPoint
   {
       
      
      public var position:Vector3;
      
      public var penetration:Number;
      
      public var feature1:int;
      
      public var feature2:int;
      
      public var normalVel:Number;
      
      public var minSepVel:Number;
      
      public var velByUnitImpulseN:Number;
      
      public var angularInertia1:Number;
      
      public var angularInertia2:Number;
      
      public var r1:Vector3;
      
      public var r2:Vector3;
      
      public var accumImpulseN:Number;
      
      public var satisfied:Boolean;
      
      public var restitution:Number;
      
      public var friction:Number;
      
      public var primitive1:CollisionPrimitive;
      
      public var primitive2:CollisionPrimitive;
      
      public function ContactPoint()
      {
         this.position = new Vector3();
         this.r1 = new Vector3();
         this.r2 = new Vector3();
         super();
      }
      
      public function precalculcate() : void
      {
         this.restitution = this.primitive1.material.restitution;
         var r:Number = this.primitive2.material.restitution;
         if(r < this.restitution)
         {
            this.restitution = r;
         }
         this.friction = this.primitive1.material.friction;
         var f:Number = this.primitive2.material.friction;
         if(f < this.friction)
         {
            this.friction = f;
         }
      }
      
      public function copyFrom(cp:ContactPoint) : void
      {
         this.position.copy(cp.position);
         this.penetration = cp.penetration;
         this.feature1 = cp.feature1;
         this.feature2 = cp.feature2;
         this.r1.copy(cp.r1);
         this.r2.copy(cp.r2);
         this.restitution = cp.restitution;
         this.friction = cp.friction;
      }
   }
}
