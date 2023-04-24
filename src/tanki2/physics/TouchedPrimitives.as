package tanki2.physics
{
   import alternativa.physics.collision.CollisionPrimitive;
   import flash.utils.Dictionary;
   
   public class TouchedPrimitives
   {
       
      
      public var trackingEnabled:Boolean;
      
      public const primitives:Vector.<CollisionPrimitive> = new Vector.<CollisionPrimitive>();
      
      private const cache:Dictionary = new Dictionary();
      
      public function TouchedPrimitives()
      {
         super();
      }
      
      public function touch(primitive:CollisionPrimitive) : void
      {
         if(this.trackingEnabled)
         {
            if(this.cache[primitive] == null)
            {
               this.cache[primitive] = true;
               this.primitives.push(primitive);
            }
         }
      }
      
      public function clear() : void
      {
         var p:CollisionPrimitive = null;
         for each(p in this.primitives)
         {
            delete this.cache[p];
         }
         this.primitives.length = 0;
      }
   }
}
