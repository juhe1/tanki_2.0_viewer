package {
	/**
    * ...
    * @author juhe
    */
   
   import flash.display.Sprite;
   import flash.display.Stage;
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
      
      private var _stage:Stage;
      
      public function Main():void
      {
         this._stage = stage;
         stage.scaleMode = StageScaleMode.NO_SCALE;
         stage.align = StageAlign.TOP_LEFT;
         stage.quality = StageQuality.HIGH;
         
         addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
         super();
      }
      
      private function onAddedToStage(event:Event):void 
      {
         this.stage3D = stage.stage3Ds[0];
			this.stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
			this.stage3D.requestContext3D();
      }
      
      private function onContext3DCreate(e:Event):void 
      {
         stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
         stage3D.context3D.enableErrorChecking = true;
         this.game = new Game(this._stage, this.stage3D);
         this.game.addEventListener(GameEvent.INIT_COMPLETE,this.onGameInitComplete);
      }
      
      private function onGameInitComplete(e:Event) : void
      {
         trace("Game init complete");
         this._stage.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function onEnterFrame(e:Event) : void
      {
         this.game.tick();
      }
      
   }

}
