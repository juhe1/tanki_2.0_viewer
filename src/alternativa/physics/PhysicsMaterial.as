package alternativa.physics
{
   public class PhysicsMaterial
   {
      
      public static const DEFAULT_MATERIAL:PhysicsMaterial = new PhysicsMaterial();
       
      
      public var restitution:Number;
      
      public var friction:Number;
      
      public function PhysicsMaterial(restitution:Number = 0, friction:Number = 0.1)
      {
         super();
         this.restitution = restitution;
         this.friction = friction;
      }
   }
}
