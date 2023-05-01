package tanki2.systems.rendersystem
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.materials.TextureMaterial;
   import flash.display.Stage3D;
   import tanki2.Scene3D;
   import tanki2.vehicles.tank.TanksManager;
   import tanki2.display.DebugPanel;
   import tanki2.display.ICameraController;
   import tanki2.display.Viewport;
   import tanki2.display.controllers.FollowCameraController;
   import tanki2.display.controllers.FreeCameraController;
   import tanki2.systems.SystemPriority;
   import tanki2.systems.SystemTags;
   import tanki2.systems.physicssystem.PhysicsSystem;
   import tanki2.systems.timesystem.TimeSystem;
   import tanki2.taskmanager.GameTask;
   import tanki2.utils.KeyboardListener;
   import tanki2.vehicles.tank.Tank;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   
   public class RenderSystem extends GameTask
   {
       
      
      public var keyboardListener:KeyboardListener;
      
      public var viewport:Viewport;
      
      public var scene3D:Scene3D;
      
      private var currCameraController:ICameraController;
      
      public var freeCameraController:FreeCameraController;
      
      public var followCameraController:FollowCameraController;
      
      private var stage:Stage;
      
      private var collisionFilter:Dictionary;
      
      private var timeSystem:TimeSystem;
      
      private var physicsSystem:PhysicsSystem;
      
      private var currMapObjectIndex:int;
      
      private var debugPanel:DebugPanel;
      
      private var tanksManager:TanksManager;
      
      public function RenderSystem(param1:Stage, stage3D:Stage3D, param2:DebugPanel, param4:TanksManager)
      {
         this.collisionFilter = new Dictionary();
         super(SystemPriority.RENDER,SystemTags.RENDER);
         this.stage = param1;
         this.debugPanel = param2;
         this.tanksManager = param4;
         this.scene3D = new Scene3D(stage3D);
         this.viewport = new Viewport(this.scene3D.getCamera(),param2, stage3D, this.stage);
         param1.addChild(this.viewport);
         param1.addEventListener(Event.RESIZE,this.onResize);
         this.freeCameraController = new FreeCameraController(param1,this.scene3D.getCamera(),1000);
         this.freeCameraController.setObjectPosXYZ(3767.506103515625,-2806.43115234375,1313.4146728515625);
         this.freeCameraController.lookAtXYZ(0,0,0);
         this.setCameraController(this.freeCameraController);
         param1.addChild(this.scene3D.getCamera().diagram);
         this.onResize(null);
         this.keyboardListener = new KeyboardListener(param1);
      }
      
      override public function onStart() : void
      {
         this.timeSystem = TimeSystem(taskManager.getTaskByTag(SystemTags.TIME));
         this.physicsSystem = PhysicsSystem(taskManager.getTaskByTag(SystemTags.PHYSICS));
         this.followCameraController = new FollowCameraController(this.stage,this.physicsSystem.getCollisionDetector(),this.scene3D.getCamera(),1 << 4,this.scene3D.getMap(),this.collisionFilter);
      }
      
      override public function run() : void
      {
         this.scene3D.update(this.timeSystem.time,this.timeSystem.deltaTimeMs);
         this.viewport.update();
      }
      
      private function onResize(param1:Event) : void
      {
         this.viewport.resize(this.stage.stageWidth,this.stage.stageHeight);
      }
      
      private function setCameraController(param1:ICameraController) : void
      {
         this.currCameraController = param1;
         this.scene3D.setCameraController(param1);
      }
      
      public function toggleGraphicsDebugMode() : void
      {
         this.scene3D.toggleDebugMode();
      }
      
      public function toggleAABBResolving() : void
      {
         this.debugPanel.printText("TanksTestingTool [ruslan_g02 mod]");
      }
      
      public function addTankToCollisionFilter(param1:Tank) : void
      {
         this.collisionFilter[param1.skin.hullMesh] = true;
         this.collisionFilter[param1.skin.turretMesh] = true;
      }
      
      public function removeTankFromCollisionFilter(param1:Tank) : void
      {
         delete this.collisionFilter[param1.skin.hullMesh];
         delete this.collisionFilter[param1.skin.turretMesh];
      }
      
      public function toggleCameraController() : void
      {
         if(this.currCameraController is FreeCameraController)
         {
            if(this.tanksManager.numTanks() > 0)
            {
               this.followCameraController.setTarget(this.tanksManager.currentTank());
               this.followCameraController.initCameraComponents();
               this.followCameraController.activate();
               this.setCameraController(this.followCameraController);
               this.viewport.debugPanel.printValue("Режим камеры","следующий");
            }
         }
         else
         {
            this.followCameraController.deactivate();
            this.followCameraController.setTarget(null);
            this.freeCameraController.updateObjectTransform();
            this.setCameraController(this.freeCameraController);
            this.viewport.debugPanel.printValue("Режим камеры","свободный");
         }
      }
   }
}
