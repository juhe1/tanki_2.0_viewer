package tanki2.display
{
   import alternativa.engine3d.core.View;
   import flash.display.Graphics;
   import flash.display.Sprite;
   
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
      
      public function Viewport(camera:GameCamera, debugPanel:DebugPanel)
      {
         super();
         this.camera = camera;
         this.view = new View(0,0);
         camera.view = this.view;
         addChild(this.view);
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
         this.camera.render();
      }
      
      public function resize(w:int, h:int) : void
      {
         this._width = w;
         this._height = h;
         this.view.width = w * this.screenSize;
         this.view.height = h * this.screenSize;
         var viewX:int = w * (1 - this.screenSize) >> 1;
         var viewY:int = h * (1 - this.screenSize) >> 1;
         this.overlay.x = this.camera.view.x = viewX;
         this.overlay.y = this.camera.view.y = viewY;
         var gfx:Graphics = this.screenMask.graphics;
         gfx.clear();
         gfx.beginFill(0,0.75);
         gfx.drawRect(0,0,w,h);
         gfx.lineStyle(0,8355711);
         gfx.drawRect(viewX,viewY,this.view.width,this.view.height);
         gfx.endFill();
         this.axisIndicator.y = stage.stageHeight - 2 * this.axisIndicator.size;
      }
      
      public function setScreenSize(value:Number) : void
      {
         this.screenSize = value;
         if(this.screenSize < 0.1)
         {
            this.screenSize = 0.1;
         }
         if(this.screenSize > 1)
         {
            this.screenSize = 1;
         }
         this.resize(this._width,this._height);
      }
   }
}
