package alternativa.physics.collision
{
   import alternativa.physics.Contact;
   
   public interface ICollider
   {
       
      
      function getContact(param1:CollisionPrimitive, param2:CollisionPrimitive, param3:Contact) : Boolean;
      
      function haveCollision(param1:CollisionPrimitive, param2:CollisionPrimitive) : Boolean;
   }
}
