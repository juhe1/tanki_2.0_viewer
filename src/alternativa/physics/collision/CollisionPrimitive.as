package alternativa.physics.collision
{
   import alternativa.math.Matrix4;
   import alternativa.math.Vector3;
   import alternativa.physics.Body;
   import alternativa.physics.PhysicsMaterial;
   import alternativa.physics.collision.types.AABB;
   
   public class CollisionPrimitive
   {
      
      public static const BOX:int = 1;
      
      public static const SPHERE:int = 2;
      
      public static const RECT:int = 4;
      
      public static const TRIANGLE:int = 8;
       
      
      public var type:int;
      
      public var collisionGroup:int;
      
      public var postCollisionFilter:ICollisionFilter;
      
      public var body:Body;
      
      public var localTransform:Matrix4;
      
      public var transform:Matrix4;
      
      public var aabb:AABB;
      
      public var material:PhysicsMaterial;
      
      public function CollisionPrimitive(type:int, collisionGroup:int, material:PhysicsMaterial)
      {
         this.transform = new Matrix4();
         this.aabb = new AABB();
         super();
         this.type = type;
         this.collisionGroup = collisionGroup;
         this.material = material;
      }
      
      public function setBody(body:Body, localTransform:Matrix4 = null) : void
      {
         if(this.body == body)
         {
            return;
         }
         this.body = body;
         if(body != null)
         {
            if(localTransform != null)
            {
               if(this.localTransform == null)
               {
                  this.localTransform = new Matrix4();
               }
               this.localTransform.copy(localTransform);
            }
            else
            {
               this.localTransform = null;
            }
         }
      }
      
      public function calculateAABB() : AABB
      {
         return this.aabb;
      }
      
      public function raycast(origin:Vector3, vector:Vector3, epsilon:Number, normal:Vector3) : Number
      {
         return -1;
      }
      
      public function clone() : CollisionPrimitive
      {
         var p:CollisionPrimitive = this.createPrimitive();
         return p.copyFrom(this);
      }
      
      public function copyFrom(source:CollisionPrimitive) : CollisionPrimitive
      {
         if(source == null)
         {
            throw new ArgumentError("Parameter source cannot be null");
         }
         this.type = source.type;
         this.transform.copy(source.transform);
         this.collisionGroup = source.collisionGroup;
         this.setBody(source.body,source.localTransform);
         this.aabb.copyFrom(source.aabb);
         return this;
      }
      
      protected function createPrimitive() : CollisionPrimitive
      {
         return new CollisionPrimitive(this.type,this.collisionGroup,this.material);
      }
   }
}
