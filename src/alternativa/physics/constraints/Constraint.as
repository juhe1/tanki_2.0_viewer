package alternativa.physics.constraints
{
   import alternativa.physics.PhysicsScene;
   
   public class Constraint
   {
       
      
      public var satisfied:Boolean;
      
      public var world:PhysicsScene;
      
      public function Constraint()
      {
         super();
      }
      
      public function preProcess(dt:Number) : void
      {
      }
      
      public function apply(dt:Number) : void
      {
      }
   }
}
