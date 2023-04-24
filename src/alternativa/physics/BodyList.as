package alternativa.physics
{
   public class BodyList
   {
       
      
      public var head:BodyListItem;
      
      public var tail:BodyListItem;
      
      public var size:int;
      
      public function BodyList()
      {
         super();
      }
      
      public function append(body:Body) : void
      {
         var item:BodyListItem = BodyListItem.create(body);
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
      
      public function remove(body:Body) : Boolean
      {
         var item:BodyListItem = this.findItem(body);
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
               this.head = item.next;
               this.head.prev = null;
            }
         }
         else if(item == this.tail)
         {
            this.tail = item.prev;
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
      
      public function findItem(body:Body) : BodyListItem
      {
         var item:BodyListItem = this.head;
         while(item != null && item.body != body)
         {
            item = item.next;
         }
         return item;
      }
   }
}
