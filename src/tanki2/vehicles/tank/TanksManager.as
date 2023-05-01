package tanki2.vehicles.tank 
{
   import alternativa.engine3d.resources.BitmapTextureResource;
   import alternativa.math.Vector3;
   import tanki2.vehicles.tank.weapons.Smoky;
   import tanki2.vehicles.tank.controllers.UserTankController;
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import tanki2.Game;
   import tanki2.display.DebugPanel;
   import tanki2.vehicles.tank.physics.TankPhysicsData;
   import tanki2.vehicles.tank.physics.TankPhysicsVisualizer;
	/**
    * ...
    * @author juhe
    */
   public class TanksManager
   {
      
      private var tanks:Vector.<Tank>;
      
      private var tanksByName:Object = {};
      
      private var tankResourcesLoader:TankResourcesLoader;
      
      private var game:Game;
      
      private var ownTank:Tank;
      
      private var debugPanel:DebugPanel
      
      private var userTankController:UserTankController;
      
      public function TanksManager(tankResourcesLoader:TankResourcesLoader, game:Game, debugPanel:DebugPanel)
      {
         this.debugPanel = debugPanel;
         this.tankResourcesLoader = tankResourcesLoader;
         this.game = game;
         this.tanks = new Vector.<Tank>();
         this.userTankController = new UserTankController(game.stage);
      }
      
      public function numTanks():int
      {
         return this.tanks.length;
      }
      
      public function currentTank():Tank
      {
         return this.ownTank;
      }
      
      public function setOwnTank(tankName:String) : void
      {
         if(this.ownTank != null)
         {
            this.ownTank.controller = null;
         }
         this.ownTank = this.tanksByName[tankName];
         this.ownTank.controller = this.userTankController;
         this.game.currentTankChanged(this.currentTank());
         this.printWeaponName();
         this.printWeaponEffectsName();
      }
      
      private function printWeaponName() : void
      {
         this.debugPanel.printValue("Тип пушек",this.currentTank().getWeapon().name);
      }
      
      private function printWeaponEffectsName() : void
      {
         this.debugPanel.printValue("Пушка",this.currentTank().getWeapon().getEffectsName());
      }
      
      public function loadTanksFromJson(jsonString:String):void 
      {
         var json:Object = JSON.parse(jsonString);
         
         for each (var tankData in json.tanks) 
         {
            var tankPhysicsData:TankPhysicsData = new TankPhysicsData();
            tankPhysicsData.setDataFromJsonObject(tankData.physicsData);
            
            var tankHull:TankHull = this.tankResourcesLoader.getHullByName(tankData.hullName);
            tankHull.physicsProfiles.push(tankPhysicsData);
            
            var tankTurret:TankTurret = this.tankResourcesLoader.getTurretByName(tankData.turretName);
            var colormap:BitmapData = this.tankResourcesLoader.getColormapByName(tankData.colormapName)
            
            this.createTank(tankData.name, tankHull, tankTurret, colormap);
         }
      }
      
      private function createTankHullFromJsonObject():TankHull
      {
         return null;
      }
      
      public function createTank(tankName:String, hull:TankHull, turret:TankTurret, colormap:BitmapData):Tank
      {
         var colormapTexture:BitmapTextureResource = new BitmapTextureResource(colormap);
         var tank:Tank = new Tank(hull, turret, colormapTexture);
         tank.setWeapon(new Smoky());
         this.tanks.push(tank);
         this.tanksByName[tankName] = tank;
         
         var position:Vector3 = new Vector3(0, 0, 1000);
         tank.chassis.setPosition(position);
         this.game.addGameObject(tank);
         
         return tank;
      }
      
   }

}