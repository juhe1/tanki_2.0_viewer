package alternativa.tanks.utils
{
   import alternativa.tanks.GameObject;
   
   public class GOListItem
   {
      
      private static var poolTop:GOListItem;
       
      
      public var gameObject:GameObject;
      
      public var next:GOListItem;
      
      public var prev:GOListItem;
      
      public function GOListItem(gameObject:GameObject)
      {
         super();
         this.gameObject = gameObject;
      }
      
      public static function create(gameObject:GameObject) : GOListItem
      {
         var item:GOListItem = null;
         if(poolTop == null)
         {
            return new GOListItem(gameObject);
         }
         item = poolTop;
         poolTop = poolTop.next;
         item.next = null;
         item.gameObject = gameObject;
         return item;
      }
      
      public function dispose() : void
      {
         this.gameObject = null;
         this.prev = null;
         this.next = poolTop;
         poolTop = this;
      }
   }
}
