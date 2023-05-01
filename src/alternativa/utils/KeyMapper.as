package alternativa.utils
{
   import flash.events.IEventDispatcher;
   import flash.events.KeyboardEvent;
   
   public class KeyMapper
   {
       
      
      private const MAX_KEYS:int = 31;
      
      private var keys:int;
      
      private var map:Vector.<int>;
      
      private var _dispatcher:IEventDispatcher;
      
      public function KeyMapper(dispatcher:IEventDispatcher = null)
      {
         this.map = new Vector.<int>(this.MAX_KEYS);
         super();
         if(dispatcher != null)
         {
            this.startListening(dispatcher);
         }
      }
      
      private function checkKey(keyNum:int) : void
      {
         if(keyNum < 0 || keyNum > this.MAX_KEYS - 1)
         {
            throw new ArgumentError("keyNum is out of range");
         }
      }
      
      public function mapKey(keyNum:int, keyCode:int) : void
      {
         this.checkKey(keyNum);
         this.map[keyNum] = keyCode;
      }
      
      public function unmapKey(keyNum:int) : void
      {
         this.checkKey(keyNum);
         this.map[keyNum] = 0;
         this.keys &= ~(1 << keyNum);
      }
      
      public function checkEvent(e:KeyboardEvent) : void
      {
         var idx:int = this.map.indexOf(e.keyCode);
         if(idx > -1)
         {
            if(e.type == KeyboardEvent.KEY_DOWN)
            {
               this.keys |= 1 << idx;
            }
            else
            {
               this.keys &= ~(1 << idx);
            }
         }
      }
      
      public function getKeyState(keyNum:int) : int
      {
         return this.keys >> keyNum & 1;
      }
      
      public function keyPressed(keyNum:int) : Boolean
      {
         return this.getKeyState(keyNum) == 1;
      }
      
      public function startListening(dispatcher:IEventDispatcher) : void
      {
         if(this._dispatcher == dispatcher)
         {
            return;
         }
         if(this._dispatcher != null)
         {
            this.unregisterListeners();
         }
         this._dispatcher = dispatcher;
         if(this._dispatcher != null)
         {
            this.registerListeners();
         }
      }
      
      public function stopListening() : void
      {
         if(this._dispatcher != null)
         {
            this.unregisterListeners();
         }
         this._dispatcher = null;
         this.keys = 0;
      }
      
      private function registerListeners() : void
      {
         this._dispatcher.addEventListener(KeyboardEvent.KEY_DOWN,this.onKey);
         this._dispatcher.addEventListener(KeyboardEvent.KEY_UP,this.onKey);
      }
      
      private function unregisterListeners() : void
      {
         this._dispatcher.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKey);
         this._dispatcher.removeEventListener(KeyboardEvent.KEY_UP,this.onKey);
      }
      
      private function onKey(e:KeyboardEvent) : void
      {
         this.checkEvent(e);
      }
   }
}
