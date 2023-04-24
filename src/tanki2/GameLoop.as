package tanki2 
{
   import alternativa.engine3d.core.Camera3D;
   import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.core.View;
   import tanki2.taskmanager.TaskManager;
   
   import flash.events.EventDispatcher;
   import flash.display.Sprite;
   import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
   import flash.events.Event;
   
	/**
    * ...
    * @author juhe
    */
   
   public class GameLoop extends Sprite
   {
      
      public var stage3D:Stage3D;
      
      private var camera:Camera3D;
      
      public var taskManager:TaskManager;
      
      public var initDoneEvent:EventDispatcher;
      
      public function GameLoop() 
      {
         this.taskManager = new TaskManager();
         this.initDoneEvent = new EventDispatcher();
         addEventListener(Event.ADDED_TO_STAGE, this.init);
      }
      
      private function init(e:Event):void 
      {
         removeEventListener(Event.ADDED_TO_STAGE, this.init);
         stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
         
         stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
			stage3D.requestContext3D();
      }
      
      private function onContextCreate(e:Event):void
	   {
         stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
         stage3D.context3D.enableErrorChecking = true;
         
			// Listeners
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
         
         // Dispatch done event
         this.initDoneEvent.dispatchEvent(new Event(Event.COMPLETE));
		}
      
      private function onEnterFrame(e:Event):void {
         //controller.update();
			
         if (this.camera != null)
         {
            // Width and height of view
            camera.view.width = stage.stageWidth;
            camera.view.height = stage.stageHeight;
            
            this.taskManager.runTasks();
            
            // Render
            camera.render(stage3D);
         }
		}
      
      public function setCamera(camera:Camera3D):void 
      {
         camera.view = new View(stage.stageWidth, stage.stageHeight, false, 0, 0, 4);
			addChild(camera.view);
			addChild(camera.diagram);
         this.camera = camera;
      }
      
      public function uploadResources(resources:Vector.<Resource>):void
      {
			for each (var resource:Resource in resources) {
				resource.upload(stage3D.context3D);
			}
		}
      
   }

}