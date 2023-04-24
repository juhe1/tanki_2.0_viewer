package alternativa.physics
{
   import alternativa.math.Quaternion;
   import alternativa.math.Vector3;
   
   public class BodyState
   {
       
      
      public var velocity:Vector3;
      
      public var orientation:Quaternion;
      
      public var angularVelocity:Vector3;
      
      public var position:Vector3;
      
      public function BodyState()
      {
         this.velocity = new Vector3();
         this.orientation = new Quaternion();
         this.angularVelocity = new Vector3();
         this.position = new Vector3();
         super();
      }
      
      public function copy(state:BodyState) : void
      {
         this.position.copy(state.position);
         this.orientation.copy(state.orientation);
         this.velocity.copy(state.velocity);
         this.angularVelocity.copy(state.angularVelocity);
      }
   }
}
