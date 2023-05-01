package {
	/**
    * ...
    * @author juhe
    */
   
   import flash.display.Sprite;
   import flash.display.Stage3D;
   import flash.display.StageAlign;
   import flash.display.StageQuality;
   import flash.display.StageScaleMode;
   import flash.events.Event;
   import tanki2.Game;
   import tanki2.GameEvent;
    
   public class Main extends Sprite
   {
      
      private var game:Game;
      
      private var stage3D:Stage3D;
      
      public function Main():void
      {
         super();
         
         stage.scaleMode = StageScaleMode.NO_SCALE;
         stage.align = StageAlign.TOP_LEFT;
         stage.quality = StageQuality.HIGH;
         
         this.stage3D = stage.stage3Ds[0];
			this.stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
			this.stage3D.requestContext3D();
      }
      
      private function onContextCreate(e:Event):void 
      {
         stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
         stage3D.context3D.enableErrorChecking = true;
         this.game = new Game(stage, this.stage3D);
         this.game.addEventListener(GameEvent.INIT_COMPLETE,this.onGameInitComplete);
      }
      
      private function onGameInitComplete(e:Event) : void
      {
         trace("Game init complete");
         stage.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function onEnterFrame(e:Event) : void
      {
         this.game.tick();
      }
      
   }

}
