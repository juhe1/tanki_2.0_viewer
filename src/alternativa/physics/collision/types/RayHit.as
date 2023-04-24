package alternativa.physics.collision.types
{
   import alternativa.math.Vector3;
   import alternativa.physics.collision.CollisionPrimitive;
   
   public class RayHit
   {
       
      
      public var primitive:CollisionPrimitive;
      
      public var position:Vector3;
      
      public var normal:Vector3;
      
      public var t:Number = 0;
      
      public function RayHit()
      {
         this.position = new Vector3();
         this.normal = new Vector3();
         super();
      }
      
      public function copy(source:RayHit) : void
      {
         this.primitive = source.primitive;
         this.position.copy(source.position);
         this.normal.copy(source.normal);
         this.t = source.t;
      }
   }
}
