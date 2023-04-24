package alternativa.tanks.utils
{
   import alternativa.tanks.GameObject;
   
   public class GOList
   {
       
      
      public var head:GOListItem;
      
      public var tail:GOListItem;
      
      public var size:int;
      
      public function GOList()
      {
         super();
      }
      
      public function append(gameObject:GameObject) : void
      {
         var item:GOListItem = GOListItem.create(gameObject);
         if(this.head == null)
         {
            this.head = this.tail = item;
         }
         else
         {
            this.tail.next = item;
            item.prev = this.tail;
            this.tail = item;
         }
         ++this.size;
      }
      
      public function remove(gameObject:GameObject) : Boolean
      {
         var item:GOListItem = this.findItemFromHead(gameObject);
         if(item == null)
         {
            return false;
         }
         if(item == this.head)
         {
            if(this.size == 1)
            {
               this.head = this.tail = null;
            }
            else
            {
               this.head = this.head.next;
               this.head.prev = null;
            }
         }
         else if(item == this.tail)
         {
            this.tail = this.tail.prev;
            this.tail.next = null;
         }
         else
         {
            item.prev.next = item.next;
            item.next.prev = item.prev;
         }
         item.dispose();
         --this.size;
         return true;
      }
      
      public function clear() : void
      {
         var item:GOListItem = null;
         while(this.head != null)
         {
            item = this.head;
            this.head = this.head.next;
            item.dispose();
         }
         this.tail = null;
         this.size = 0;
      }
      
      public function findItemFromHead(gameObject:GameObject) : GOListItem
      {
         var item:GOListItem = this.head;
         while(item != null)
         {
            if(item.gameObject == gameObject)
            {
               return item;
            }
            item = item.next;
         }
         return null;
      }
   }
}
