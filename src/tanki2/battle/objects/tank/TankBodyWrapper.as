package tanki2.battle.objects.tank
{
   import alternativa.physics.Body;
   import alternativa.physics.collision.CollisionPrimitive;
   import alternativa.physics.collision.primitives.CollisionBox;
   
   public class TankBodyWrapper
   {
       
      
      public var id:int;
      
      public var body:Body;
      
      public var tankCollisionBox:CollisionBox;
      
      public const staticCollisionPrimitives:Vector.<CollisionPrimitive> = new Vector.<CollisionPrimitive>();
      
      public function TankBodyWrapper(body:Body)
      {
         super();
         this.body = body;
      }
   }
}
