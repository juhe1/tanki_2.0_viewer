package alternativa.physics
{
   public class BodyListItem
   {
      
      private static var poolTop:BodyListItem;
       
      
      public var body:Body;
      
      public var next:BodyListItem;
      
      public var prev:BodyListItem;
      
      public function BodyListItem(body:Body)
      {
         super();
         this.body = body;
      }
      
      public static function create(body:Body) : BodyListItem
      {
         var item:BodyListItem = null;
         if(poolTop == null)
         {
            item = new BodyListItem(body);
         }
         else
         {
            item = poolTop;
            poolTop = item.next;
            item.next = null;
            item.body = body;
         }
         return item;
      }
      
      public static function clearPool() : void
      {
         var item:BodyListItem = poolTop;
         while(item != null)
         {
            poolTop = item.next;
            item.next = null;
            item = poolTop;
         }
      }
      
      public function dispose() : void
      {
         this.body = null;
         this.prev = null;
         this.next = poolTop;
         poolTop = this;
      }
   }
}
