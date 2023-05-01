package tanki2
{
   import alternativa.engine3d.core.Debug;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Resource;
   import alternativa.engine3d.materials.FillMaterial;
   import alternativa.engine3d.primitives.Box;
   import alternativa.math.Vector3;
   import flash.display.Stage3D;
   import tanki2.battle.BattleScene3D;
   import tanki2.battle.Renderer;
   import tanki2.display.GameCamera;
   import tanki2.display.ICameraController;
   
   public class Scene3D implements BattleScene3D
   {
       
      
      private const rootContainer:Object3D = new Object3D();
      
      private var skyBoxContainer:Object3D;
      
      private var mapContainer:Object3D;
      
      private var frontContainer:Object3D;
      
      private var camera:GameCamera;
      
      private var skyBox:Object3D;
      
      private var map:Object3D;
      
      public const renderers:Renderers = new Renderers();
      
      private var cameraController:ICameraController;
      
      private var stage3D:Stage3D;
      
      public function Scene3D(stage3D:Stage3D)
      {
         this.stage3D = stage3D;
         super();
         this.skyBoxContainer = new Object3D();
         this.rootContainer.addChild(this.skyBoxContainer);
         this.mapContainer = new Object3D();
         this.rootContainer.addChild(this.mapContainer);
         this.frontContainer = new Object3D();
         this.rootContainer.addChild(this.frontContainer);
         this.camera = new GameCamera();
         this.camera.nearClipping = 1;
         this.camera.farClipping = 300000;
         this.rootContainer.addChild(this.camera);
      }
      
      public function setCameraController(controller:ICameraController) : void
      {
         this.cameraController = controller;
      }
      
      public function addRenderer(renderer:Renderer, groupIndex:int) : void
      {
         this.renderers.add(renderer);
      }
      
      public function removeRenderer(renderer:Renderer, groupIndex:int) : void
      {
         this.renderers.remove(renderer);
      }
      
      public function addObject(object:Object3D) : void
      {
         this.map.addChild(object);
      }
      
      public function removeObject(object:Object3D) : void
      {
         this.map.removeChild(object);
      }
      
      public function getCamera() : GameCamera
      {
         return this.camera;
      }
      
      public function setSkyBox(skyBox:Object3D) : void
      {
         this.removeSkyBox();
         this.skyBox = skyBox;
         this.skyBoxContainer.addChild(skyBox);
      }
      
      private function removeSkyBox() : void
      {
         if(this.skyBox != null)
         {
            this.skyBoxContainer.removeChild(this.skyBox);
         }
      }
      
      public function toggleDebugMode() : void
      {
         this.camera.debug = !this.camera.debug;
      }
      
      public function setMapObject(map:Object3D) : void
      {
         this.removeMap();
         this.map = map;
         this.mapContainer.addChild(map);
         this.uploadResources(map.getResources(true));
      }
      
      public function getMap() : Object3D
      {
         return this.map;
      }
      
      public function getFrontContainer() : Object3D
      {
         return this.frontContainer;
      }
      
      private function removeMap() : void
      {
         if(this.map != null)
         {
            this.mapContainer.removeChild(this.map);
         }
      }
      
      public function update(time:int, deltaTimeMs:int) : void
      {
         this.renderers.run(time,deltaTimeMs);
         this.updateCamera(time,deltaTimeMs);
      }
      
      private function updateCamera(time:int, deltaTimeMs:uint) : void
      {
         this.cameraController.updateCamera(time,deltaTimeMs,deltaTimeMs / 1000);
         this.camera.recalculate();
      }
      
      public function createBox(size:Number, color:uint, position:Vector3) : void
      {
         
      }
      
      public function uploadResources(resources:Vector.<Resource>):void
      {
			for each (var resource:Resource in resources)
         {
				resource.upload(stage3D.context3D);
			}
		}
      
   }
}
