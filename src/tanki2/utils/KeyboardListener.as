package tanki2.utils
{
   import flash.display.InteractiveObject;
   import flash.events.KeyboardEvent;
   import flash.utils.Dictionary;
   
   public class KeyboardListener
   {
      
      public static const BIT_CTRL:uint = 1 << 31;
      
      public static const BIT_SHIFT:uint = 1 << 30;
       
      
      private const handlers:Dictionary = new Dictionary();
      
      public function KeyboardListener(eventSource:InteractiveObject)
      {
         super();
         eventSource.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
      }
      
      public static function getKeysCombinationCode(event:KeyboardEvent) : uint
      {
         return BIT_CTRL * uint(event.ctrlKey) | BIT_SHIFT * uint(event.shiftKey) | event.keyCode;
      }
      
      public function addHandler(keyCombinationCode:uint, handler:Function) : void
      {
         this.handlers[keyCombinationCode] = handler;
      }
      
      private function onKeyDown(event:KeyboardEvent) : void
      {
         var handler:Function = this.handlers[getKeysCombinationCode(event)];
         if(handler != null)
         {
            handler();
         }
      }
   }
}
