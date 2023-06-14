package tanki2.vehicles.tank 
{
   import alternativa.engine3d.materials.TextureMaterial;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.resources.ATFTextureResource;
   import alternativa.engine3d.resources.ExternalTextureResource;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.net.URLRequest;
	/**
    * ...
    * @author juhe
    */
   public class TankResourcesLoader extends EventDispatcher
   {
      
      private var hullCount:int = 0;
      
      private var loadedHullsCount:int = 0;
      
      private var turretCount:int = 0;
      
      private var loadedTurretsCount:int = 0;
      
      private var colormapCount:int = 0;
      
      private var loadedColorMapsCount:int = 0;
      
      private var json:Object;
      
      private var hulls:Object = {};
      
      private var turrets:Object = {};
      
      private var colormaps:Object = {};
      
      public function TankResourcesLoader(json:Object) 
      {
         this.json = json;
      }
      
      public function getHullByName(name:String):TankHull
      {
         return this.hulls[name];
      }
      
      public function getTurretByName(name:String):TankTurret
      {
         return this.turrets[name];
      }
      
      public function getColormapByName(name:String):BitmapData
      {
         return this.colormaps[name];
      }
      
      public function load():void 
      {
         this.loadHullsFromJson(json);
         this.loadTurretsFromJson(json);
         this.loadColormaps(json);
      }
      
      private function loadColormaps(json):void 
      {
         this.colormapCount = json.colormaps.length;
         
         for each (var colorMapData in json.colormaps) 
         {
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:Event):void 
            {
               onBitmapLoaded(e, colorMapData.name);
            });
            loader.load(new URLRequest(colorMapData.path));
         }
      }

      private function onBitmapLoaded(event:Event, colormapName:String):void
      {
          var bitmapData:BitmapData = Bitmap(event.target.content).bitmapData;
          this.colormaps[colormapName] = bitmapData;
          
          this.loadedColorMapsCount++;
          this.allLoadedCheck();
      }
      
      private function getTurretLoadedEventFunction(turretName:String):Function
      {
         return function (e:Event):void {
            onTurretTankPartLoaded(e, turretName);
         };
      }
      
      private function loadTurretsFromJson(json:Object):void 
      {
         var turrets:Object = json.turrets;
         this.turretCount = turrets.length;
         
         for each (var turretObject in turrets) 
         {
            var turretTextureNames:Vector.<String> = this.stringArrayToVector(turretObject.textureNames);
            var turretLoader:PartLoader = new PartLoader(turretObject.path, turretTextureNames, "turret.a3d");
            turretLoader.addEventListener(Event.COMPLETE, this.getTurretLoadedEventFunction(turretObject.name));
            turretLoader.load();
         }
      }
      
      private function onTurretTankPartLoaded(e:Event, turretName):void 
      {
         var partLoader:PartLoader = PartLoader(e.target);
         var part:Part = partLoader.part;
         
         var turret:TankTurret = new TankTurret(part);
         this.turrets[turretName] = turret;
         
         this.loadedTurretsCount++;
         this.allLoadedCheck();
      }
      
      private function getHullLoadedEventFunction(hullName:String):Function
      {
         return function (e:Event):void {
            onHullTankPartLoaded(e, hullName);
         };
      }
      
      private function loadHullsFromJson(json:Object):void 
      {
         var hulls:Object = json.hulls;
         this.hullCount = hulls.length;
         
         for each (var hullObject:Object in hulls) 
         {
            var hullTextureNames:Vector.<String> = this.stringArrayToVector(hullObject.textureNames);
            
            var hullLoader:PartLoader = new PartLoader(hullObject.path, hullTextureNames, "main.dae");
            hullLoader.addEventListener(Event.COMPLETE, this.getHullLoadedEventFunction(hullObject.name));
            hullLoader.load();
         }
      }
      
      private function onHullTankPartLoaded(e:Event, hullName:String):void 
      {
         trace(hullName, " loaded!");
         var partLoader:PartLoader = PartLoader(e.target);
         var part:Part = partLoader.part;
         
         var hull:TankHull = new TankHull(part);
         this.hulls[hullName] = hull;
         
         this.loadedHullsCount++;
         this.allLoadedCheck();
      }
      
      private function allLoadedCheck():void 
      {
         if (this.loadedHullsCount == this.hullCount && this.loadedTurretsCount == this.turretCount && this.loadedColorMapsCount == this.colormapCount)
         {
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      private function stringArrayToVector(array:Array):Vector.<String>
      {
         var strings:Vector.<String> = new Vector.<String>();
         for each (var string in array) 
         {
            strings.push(string);
         }
         return strings;
      }
      
   }

}