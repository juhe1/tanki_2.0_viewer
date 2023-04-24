package tanki2.utils.list
{
   import tanki2.utils.list.errors.ConcurrentModificationError;
   import tanki2.utils.list.errors.NoSuchElementError;
   
   class ListIteratorImpl implements ListIterator
   {
       
      
      private var list:List;
      
      private var changeCounter:int;
      
      private var nextItem:ListItem;
      
      private var prevItem:ListItem;
      
      function ListIteratorImpl(list:List)
      {
         super();
         this.list = list;
         this.changeCounter = list.changeCounter;
         this.prevItem = list.head;
         this.nextItem = this.prevItem.next;
      }
      
      public function add(data:Object) : void
      {
         this.validateList();
         var item:ListItem = new ListItem();
         item.data = data;
         item.prev = this.prevItem;
         item.next = this.nextItem;
         this.prevItem.next = item;
         this.nextItem.prev = item;
         this.prevItem = item;
         this.incChangeCounter();
      }
      
      public function hasNext() : Boolean
      {
         this.validateList();
         return this.nextItem != this.list.tail;
      }
      
      public function hasPrevious() : Boolean
      {
         this.validateList();
         return this.prevItem != this.list.head;
      }
      
      public function next() : Object
      {
         this.validateList();
         if(this.nextItem == this.list.tail)
         {
            throw new NoSuchElementError();
         }
         this.prevItem = this.nextItem;
         this.nextItem = this.nextItem.next;
         return this.prevItem.data;
      }
      
      public function previous() : Object
      {
         this.validateList();
         if(this.prevItem == this.list.head)
         {
            throw new NoSuchElementError();
         }
         this.nextItem = this.prevItem;
         this.prevItem = this.prevItem.prev;
         return this.nextItem.data;
      }
      
      private function validateList() : void
      {
         if(this.changeCounter != this.list.changeCounter)
         {
            throw new ConcurrentModificationError();
         }
      }
      
      private function incChangeCounter() : void
      {
         ++this.changeCounter;
         this.list.changeCounter = this.changeCounter;
      }
   }
}
