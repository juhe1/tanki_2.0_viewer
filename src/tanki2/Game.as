package tanki2 
{
	/**
    * ...
    * @author juhe
    */
   
   import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.alternativa3d;
   import alternativa.physics.collision.CollisionDetector;
   import flash.display.Stage;
   import flash.display.Stage3D;
   import flash.events.EventDispatcher;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   import tanki2.systems.objectcontrollers.ObjectControllersSystem;
   import tanki2.taskmanager.TaskManager;
   import tanki2.utils.GOListItem;
   import tanki2.utils.KeyboardListener;
   import tanki2.utils.objectpool.ObjectPool;
   import tanki2.maploader.MapLoader;
   import tanki2.maploader.MapObject;
   import tanki2.systems.gameobjectssystem.GameObjectsSystem;
   import tanki2.systems.physicssystem.PhysicsSystem;
   import tanki2.display.DebugPanel;
   import tanki2.systems.timesystem.TimeSystem;
   import tanki2.utils.GOList;
   import tanki2.vehicles.tank.Tank;
   import tanki2.vehicles.tank.TankResourcesLoader;
   import tanki2.vehicles.tank.TanksManager;
   import tanki2.systems.SystemTags;
   import tanki2.systems.SystemPriority;
   import tanki2.systems.rendersystem.RenderSystem;
   
	import flash.display.Sprite;
	import flash.events.Event;
   import flash.utils.setTimeout;
   
   use namespace alternativa3d;
    
   [Event(name="initComplete",type="tanki2.GameEvent")]
   public class Game extends EventDispatcher
   {
      private static var instance:Game;
      
      public var physicsSystem:PhysicsSystem;
      
      public var gameObjects:GOList;
      
      private var objectPool:ObjectPool;
      
      public var gameObjectById:Dictionary;
      
      public var tanksManager:TanksManager;
      
      public var renderSystem:RenderSystem;
      
      public var stage:Stage;
      
      var debugPanel:DebugPanel;
      
      private const taskManager:TaskManager = new TaskManager();
      
      private var stage3D:Stage3D;
      
      private var keyboardListener:KeyboardListener;
      
      private var mapObject:MapObject;
      
      public function Game(stage:Stage, stage3D:Stage3D)
      {
         this.stage3D = stage3D;
         this.gameObjects = new GOList();
         this.gameObjectById = new Dictionary();
         this.objectPool = new ObjectPool();
         this.stage = stage;
         this.debugPanel = new DebugPanel();
         instance = this;
         
         // Load map
         this.loadMap("resources/maps/arena-a3d.tara");
      }
      
      public static function getInstance() : Game
      {
         return instance;
      }
      
      public function getCollisionDetector() : CollisionDetector
      {
         return this.physicsSystem.physicsScene.collisionDetector;
      }
      
      public function tick() : void
      {
         this.taskManager.runTasks();
      }
      
      private function initKeyboardListeners() : void
      {
         this.keyboardListener.addHandler(Keyboard.F,this.renderSystem.toggleCameraController);
      }
      
      public function getObjectPool() : ObjectPool
      {
         return this.objectPool;
      }
      
      public function getObjectFromPool(objectClass:Class) : Object
      {
         return this.objectPool.getObject(objectClass);
      }
      
      public function addGameObject(gameObject:GameObject) : void
      {
         if(this.gameObjectById[gameObject.id] != null)
         {
            throw new Error("Object already exists");
         }
         this.gameObjectById[gameObject.id] = new GOListItem(gameObject);
         this.gameObjects.append(gameObject);
         gameObject.addToGame(this);
      }
      
      public function removeGameObject(gameObject:GameObject) : void
      {
         if(this.gameObjects.remove(gameObject))
         {
            gameObject.removeFromGame();
            delete this.gameObjectById[gameObject.id];
         }
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
         this.mapObject = new MapObject(mapLoader);
         
         this.createPhysicsSystem(mapLoader);
         
         this.loadTankResources();
      }
      
      public function currentTankChanged(tank:Tank) : void
      {
         this.renderSystem.followCameraController.setTarget(tank);
         this.physicsSystem.getCollisionDetector().trackedBody = tank.chassis;
      }
      
      private function loadTankResources():void 
      {
         var tankAndTurretsTestJson:Object = JSON.parse('{\
         "hulls":[{\
            "name":"viking m1",\
            "path":"resources/hulls/viking/m1",\
            "textureNames":["diffuse", "normalmap", "shadow", "surface", "tracks_diffuse", "tracks_normalmap"]\
         }],\
         "turrets":[{\
            "name":"thunder m3",\
            "path":"resources/turrets/thunder/m3",\
            "textureNames":["diffuse", "normalmap", "surface"]\
         }],\
         "colormaps":[{\
            "name":"flora",\
            "path":"resources/colormaps/flora.jpg"\
         }]\
         }');
         
         var tankResourcesLoader:TankResourcesLoader = new TankResourcesLoader(tankAndTurretsTestJson);
         tankResourcesLoader.addEventListener(Event.COMPLETE, this.onTankResourcesLoaded);
         tankResourcesLoader.load();
      }
      
      private function onTankResourcesLoaded(e:Event):void
      {
         var tankResourcesLoader:TankResourcesLoader = TankResourcesLoader(e.target);
         this.tanksManager = new TanksManager(tankResourcesLoader, this, this.debugPanel);
         
         this.createTasks();
         this.renderSystem.scene3D.setMapObject(this.mapObject);
      }
      
      private function createPhysicsSystem(mapLoader:MapLoader):void 
      {
         var gravity:Number = -1000;
         this.physicsSystem = new PhysicsSystem(gravity, mapLoader.collisionPrimitives, this.debugPanel);
      }
      
      private function createTasks():void 
      {
         this.keyboardListener = new KeyboardListener(this.stage);
         this.taskManager.addTask(new TimeSystem());
         this.taskManager.addTask(new ObjectControllersSystem(SystemPriority.OBJECT_CONTROLLERS,SystemTags.OBJECT_CONTROLLERS,this.gameObjects));
         this.taskManager.addTask(this.physicsSystem);
         this.taskManager.addTask(new GameObjectsSystem(this.gameObjects));
         this.renderSystem = new RenderSystem(this.stage, this.stage3D, this.debugPanel, this.tanksManager);
         this.taskManager.addTask(this.renderSystem);
         this.initKeyboardListeners();
         
         this.keyboardListener.addHandler(Keyboard.P,this.addTank);
         
         setTimeout(this.completeInit,0);
      }
      
      private function addTank():void 
      {
         this.tanksManager.loadTanksFromJson('{"tanks":[{\
            "name":"test123",\
            "hullName":"viking m1",\
            "turretName":"thunder m3",\
            "colormapName":"flora",\
            "physicsData":{\
               "mass":1600,\
               "power":309900,\
               "maxForwardSpeed":1000,\
               "maxBackwardSpeed":1000,\
               "maxTurnSpeed":0.001,\
               "springDamping":1000,\
               "dynamicFriction":0.5,\
               "brakeFriction":4,\
               "sideFriction":2\
            }\
         }]}');
         
         this.tanksManager.setOwnTank("test123");
      }
      
      private function completeInit() : void
      {
         dispatchEvent(new GameEvent(GameEvent.INIT_COMPLETE));
      }
      
   }

}