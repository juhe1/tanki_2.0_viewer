package tanki2.display
{
   import alternativa.engine3d.core.View;
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.display.Stage3D;
   import flash.events.Event;
   
   public class Viewport extends Sprite
   {
       
      
      private var screenSize:Number = 1.0;
      
      private var screenMask:Sprite;
      
      private var _width:int = 400;
      
      private var _height:int = 300;
      
      private var view:View;
      
      private var camera:GameCamera;
      
      public var debugPanel:DebugPanel;
      
      private var axisIndicator:AxisIndicator;
      
      private var overlay:Sprite;
      
      private var stage3D:Stage3D;
      
      public function Viewport(camera:GameCamera, debugPanel:DebugPanel, stage3D:Stage3D, stage:Stage)
      {
         super();
         this.stage3D = stage3D;
         this.camera = camera;
         
         this.camera.x = 0
         this.camera.y = 0
         this.camera.z = 2000
         
         this.view = new View(stage.stageWidth, stage.stageHeight, false, 0, 0, 4);
         camera.view = this.view;
         stage.addChild(this.view);
         stage.addChild(camera.diagram);
         addChild(this.overlay = new Sprite());
         addChild(this.screenMask = new Sprite());
         addChild(this.axisIndicator = new AxisIndicator(50));
         this.debugPanel = debugPanel;
         addChild(debugPanel);
      }
      
      public function getOverlay() : Sprite
      {
         return this.overlay;
      }
      
      public function update() : void
      {
         this.axisIndicator.update(this.camera);
         this.camera.render(this.stage3D);
      }
      
      public function resize(w:int, h:int) : void
      {
         this.camera.view.width = stage.stageWidth;
			this.camera.view.height = stage.stageHeight;
      }
   }
}
