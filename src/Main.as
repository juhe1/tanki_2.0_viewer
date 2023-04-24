package {
	/**
    * ...
    * @author juhe
    */
   
   import flash.display.Sprite;
   import flash.events.Event;
   import tanki2.Tanki2;
   import tanki2.GameLoop;
    
   public class Main extends Sprite
   {
      
      private var gameLoop:GameLoop;
      
      public function Main():void
      {
         super();
         
         this.gameLoop = new GameLoop();
         this.gameLoop.initDoneEvent.addEventListener(Event.COMPLETE, this.gameLoopCreationDone);
         addChild(this.gameLoop);
      }
      
      private function gameLoopCreationDone(e:Event):void 
      {
         new Tanki2(this.gameLoop);
      }
      
   }

}
