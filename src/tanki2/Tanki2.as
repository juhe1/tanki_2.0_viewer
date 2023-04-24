package tanki2 
{
	/**
    * ...
    * @author juhe
    */
   
   import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.controllers.SimpleObjectController;
   import alternativa.engine3d.alternativa3d;
   import tanki2.maploader.MapLoader;
   import tanki2.maploader.MapObject;
   import tanki2.systems.physicssystem.PhysicsSystem;
   import tanki2.display.DebugPanel;
   import tanki2.systems.timesystem.TimeSystem;
   
	import flash.display.Sprite;
	import flash.events.Event;
   
   use namespace alternativa3d;
    
   public class Tanki2
   {
      private var scene:Object3D = new Object3D();
      
      private var controller:SimpleObjectController;
      
      private var gameLoop:GameLoop;
      
      var debugPanel:DebugPanel;
      
      public var physicsSystem:PhysicsSystem;
      
      public function Tanki2(gameLoop:GameLoop)
      {
         this.gameLoop = gameLoop;
         
         // Camera
			var camera:Camera3D = new Camera3D(1, 30000);
			camera.rotationX = -130 * Math.PI / 180;
         camera.z = 2000
         controller = new SimpleObjectController(this.gameLoop.stage, camera, 600);
			scene.addChild(camera);
         this.gameLoop.setCamera(camera);
         
         // Load map
         this.loadMap("resources/maps/arena-a3d.tara");
         
         // ...
         this.debugPanel = new DebugPanel();
         this.gameLoop.addChild(this.debugPanel);
      }
      
      private function loadMap(mapUrl:String):void 
      {  
         var mapLoader:MapLoader = new MapLoader();
         mapLoader.addEventListener(Event.COMPLETE, this.mapLoaded);
         mapLoader.loadMap(mapUrl);
      }
      
      private function mapLoaded(e:Event):void 
      {
         var mapLoader:MapLoader = MapLoader(e.target);
         var mapObject:MapObject = new MapObject(mapLoader, this.gameLoop.stage3D.context3D);
         scene.addChild(mapObject);
         this.gameLoop.uploadResources(mapObject.getResources(true));
         
         this.createPhysics(mapLoader);
      }
      
      private function createPhysics(mapLoader:MapLoader):void 
      {
         var gravity:Number = 1000;
         this.gameLoop.taskManager.addTask(new TimeSystem());
         this.physicsSystem = new PhysicsSystem(gravity, mapLoader.collisionPrimitives, this.debugPanel);
         this.gameLoop.taskManager.addTask(this.physicsSystem);
      }
      
   }

}