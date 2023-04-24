package tanki2.utils.list
{
   public interface ListIterator
   {
       
      
      function add(param1:Object) : void;
      
      function hasNext() : Boolean;
      
      function hasPrevious() : Boolean;
      
      function next() : Object;
      
      function previous() : Object;
   }
}
