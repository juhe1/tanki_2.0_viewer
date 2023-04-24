package tanki2.maploader 
{
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.loaders.ParserCollada;
   import alternativa.engine3d.loaders.ParserMaterial;
   import alternativa.engine3d.loaders.TexturesLoader;
   import alternativa.engine3d.materials.LightMapMaterial;
   import alternativa.engine3d.materials.StandardMaterial;
   import alternativa.engine3d.objects.Decal;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.objects.Surface;
   import alternativa.engine3d.resources.ATFTextureResource;
   import alternativa.engine3d.resources.BitmapTextureResource;
   import alternativa.engine3d.resources.ExternalTextureResource;
   import alternativa.engine3d.resources.TextureResource;
   import alternativa.physics.collision.CollisionPrimitive;
   import alternativa.physics.PhysicsMaterial;
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import alternativa.utils.TARAParser;
   import alternativa.engine3d.loaders.ParserA3D;
   import flash.net.URLLoaderDataFormat;
   import alternativa.engine3d.alternativa3d;
   import tanki2.physics.CollisionGroup;
   import tanki2.physics.MeshToCollisionPrimitive;
   
	/**
    * ...
    * @author juhe
    */
   
   use namespace alternativa3d;
   
   public class MapLoader extends EventDispatcher
   {
      
      public static const MAIN_FILE:String = "main.a3d";
      
      public static const ADDITIONAL_FILES_START:String = "part";
      
      public static const TREES_FILE:String = "trees.a3d";
      
      public static const MARKET_FILE:String = "market.a3d";
      
      public static const PHYSICS_FILE:String = "physics.a3d";
      
      public static const BEAMS_FILE:String = "beams.a3d";
      
      public static const LIGHTS_FILE:String = "lights.dae";
      
      private static const COLLISION_MASK:int = 255;
      
      private static var fakeEmissionTextureResource:BitmapTextureResource = new BitmapTextureResource(new BitmapData(1,1,false,8355711));
      
      private static var fakeBumpTextureResource:BitmapTextureResource = new BitmapTextureResource(new BitmapData(1, 1, false, 8355839));
      
      private static var nullTexture:BitmapTextureResource = new BitmapTextureResource(new BitmapData(1,1,true,0));
      
      public var decals:Vector.<Decal>;
      
      public var objects:Vector.<Object3D>;
      
      public var lights:Vector.<Light3D>;
      
      public var collisionPrimitives:Vector.<CollisionPrimitive>;
      
      private var mapFiles:MapData;
      
      public function MapLoader():void
      {
         this.decals = new Vector.<Decal>();
         this.objects = new Vector.<Object3D>();
         this.lights = new Vector.<Light3D>();
         this.collisionPrimitives = new Vector.<CollisionPrimitive>();
      }
      
      public function loadMap(mapFilePath:String):void 
      {  
         var mapTaraLoader:URLLoader = new URLLoader();
			mapTaraLoader.dataFormat = URLLoaderDataFormat.BINARY;
			mapTaraLoader.load(new URLRequest(mapFilePath));
			mapTaraLoader.addEventListener(Event.COMPLETE, onMapTaraLoaded);
      }
      
      private function onMapTaraLoaded(e:Event):void 
      {
         var mapTaraBuffer:ByteArray = (e.target as URLLoader).data;
         var taraParser:TARAParser = new TARAParser(mapTaraBuffer);
         this.mapFiles = new MapData(taraParser.data);
         
         this.LoadMap3DStuff();
      }
      
      private function LoadMap3DStuff():void 
      {
         var surface:Surface = null;
         var mesh:Mesh = null;
         var meshName:String = null;
         var decal:Decal = null;
         var resourceCache:Object = {};
         
         var mapGeometryFileNames:Vector.<String> = this.getMapGeometryFileNames();
         var objects:Vector.<Object3D> = this.parseA3DFiles(mapGeometryFileNames);
         
         for each(var object:Object3D in objects)
         {
            mesh = object as Mesh;
            if(mesh != null)
            {
               meshName = mesh.name.toLowerCase();
               if(meshName.indexOf("decal") >= 0)
               {
                  decal = new Decal();
                  decal.name = meshName;
                  decal.useShadow = true;
                  decal.geometry = mesh.geometry;
                  decal._surfaces = mesh._surfaces;
                  decal._surfacesLength = mesh._surfacesLength;
                  for each(surface in decal._surfaces)
                  {
                     surface.object = decal;
                  }
                  decal.boundBox = mesh.boundBox;
                  decal.matrix = mesh.matrix;
                  mesh = decal;
                  this.decals.push(decal);
               }
               mesh.calculateBoundBox();
               this.createMaterialForMesh(mesh,resourceCache);
               this.objects.push(mesh);
            }
         }
         
         //this.§_-gU§(this.mapFiles.§_-HG§(TREES_FILE));
         //this.§_-hj§(this.mapFiles.§_-HG§(MARKET_FILE));
         this.loadBeams(this.mapFiles.getFileByName(BEAMS_FILE));
         this.loadLights(this.mapFiles.getFileByName(LIGHTS_FILE));
         this.loadCollisionPrimitive(this.mapFiles.getFileByName(PHYSICS_FILE));
         
         dispatchEvent(new Event(Event.COMPLETE));
         
      }
      
      private function loadCollisionPrimitive(data:ByteArray):void 
      {
         var object:Object3D = null;
         var objectName:String = null;
         
         var parser:ParserA3D = new ParserA3D();
         parser.parse(data);
         var resourceCache:Object = {};
         
         for each(object in parser.objects)
         {
            if(object is Mesh)
            {
               objectName = object.name.toLowerCase();
               if(objectName.indexOf("tri") == 0)
               {
                  MeshToCollisionPrimitive.triangleMeshToCollisionPrimitive(Mesh(object), this.collisionPrimitives, CollisionGroup.STATIC, PhysicsMaterial.DEFAULT_MATERIAL);
               }
               else if(objectName.indexOf("box") == 0)
               {
                  MeshToCollisionPrimitive.boxMeshToCollisionPrimitive(Mesh(object), this.collisionPrimitives, CollisionGroup.STATIC, PhysicsMaterial.DEFAULT_MATERIAL);
               }
               else if(objectName.indexOf("plane") == 0)
               {
                  MeshToCollisionPrimitive.planeMeshToCollisionPrimitive(Mesh(object), this.collisionPrimitives, CollisionGroup.STATIC, PhysicsMaterial.DEFAULT_MATERIAL);
               }
            }
         }
      }
      
      private function loadLights(lightsData:ByteArray) : void
      {         
         var parserCollada:ParserCollada = null;
         var numLights:uint = 0;
         var i:int = 0;
         if(lightsData != null)
         {
            parserCollada = new ParserCollada();
            parserCollada.parse(XML(lightsData.toString()));
            numLights = parserCollada.lights.length;
            this.lights = new Vector.<Light3D>(numLights);
            for(i = 0; i < numLights; i++)
            {
               this.lights[i] = parserCollada.lights[i];
               Light3D(this.lights[i]).removeFromParent();
            }
         }
      }
      
      private function loadBeams(data:ByteArray):void 
      {
         var object:Object3D = null;
         var mesh:Mesh = null;
         var i:int = 0;
         var surface:Surface = null;
         var material:ParserMaterial = null;
         var diffuse:TextureResource = null;
         var opacity:TextureResource = null;
         if(data == null)
         {
            return;
         }
         
         var parser:ParserA3D = new ParserA3D();
         parser.parse(data);
         var resourceCache:Object = {};
         
         for each(object in parser.objects)
         {
            mesh = object as Mesh;
            if(mesh != null)
            {
               for(i = 0; i < mesh.numSurfaces; )
               {
                  surface = mesh.getSurface(i);
                  if(surface.material != null)
                  {
                     material = ParserMaterial(surface.material);
                     diffuse = this.getATFTTextureResource(material.textures["diffuse"],resourceCache,this.mapFiles);
                     opacity = this.getATFTTextureResource(material.textures["transparent"],resourceCache,this.mapFiles);
                     surface.material = new BeamMaterial(opacity);
                  }
                  i++;
               }
               this.objects.push(mesh);
            }
         }
      }
      
      private function createMaterialForMesh(mesh:Mesh, resourceCache:Object):void 
      {
         var surface:Surface = null;
         var parserMaterial:ParserMaterial = null;
         var diffuseTextureResource:TextureResource = null;
         var emissionTextureResource:TextureResource = null;
         var opacityTextureResource:TextureResource = null;
         var material:LightMapMaterial = null;
         
         for each(surface in mesh._surfaces)
         {
            parserMaterial = surface.material as ParserMaterial;
            
            if(parserMaterial != null)
            {  
               diffuseTextureResource = this.getATFTTextureResource(parserMaterial.textures["diffuse"],resourceCache,this.mapFiles);
               emissionTextureResource = this.getATFTTextureResource(parserMaterial.textures["emission"],resourceCache,this.mapFiles);
               opacityTextureResource = this.getATFTTextureResource(parserMaterial.textures["transparent"], resourceCache, this.mapFiles);
               
               if(emissionTextureResource == null)
               {
                  material = new LightMapMaterial(diffuseTextureResource, fakeEmissionTextureResource, 0, opacityTextureResource);
               }
               else
               {
                  material = new LightMapMaterial(diffuseTextureResource, emissionTextureResource, 1, opacityTextureResource);
               }
               surface.material = material;
            }
         }
      }
      
      private function getATFTTextureResource(fileTextureResource:ExternalTextureResource, resourceCache:Object, mapFiles:Object):ATFTextureResource
      {
         var textureName:String = null;
         var resource:ATFTextureResource = null;
         var textureData:ByteArray = null;
         if(fileTextureResource != null && fileTextureResource.url)
         {
            textureName = fileTextureResource.url.toLowerCase();
            
            textureName = textureName.replace(".png",".atf");
            textureName = textureName.replace(".jpg", ".atf");
            if(this.mapFiles.getFileByName(textureName) != null)
            {
               resource = resourceCache[textureName];
               if(resource == null)
               {
                  textureData = mapFiles.getFileByName(textureName);
                  resource = new ATFTextureResource(textureData);
                  resourceCache[textureName] = resource;
               }
               return resource;
            }
            trace("[WARN] texture not found:",fileTextureResource.url.toLowerCase());
         }
         return null;
      }
      
      private function parseA3DFiles(fileNames:Vector.<String>):Vector.<Object3D>
      {
         var objects:Vector.<Object3D> = new Vector.<Object3D>();
         
         for each (var fileName:String in fileNames)
         {  
            var fileByteArray:ByteArray = this.mapFiles.getFileByName(fileName);
            
            var parser:ParserA3D = new ParserA3D();
            parser.parse(fileByteArray);
            
            for each (var object:Object3D in parser.objects)
            {
               objects.push(object)
            }
         }
         
         return objects;
      }
      
      private function getMapGeometryFileNames():Vector.<String>
      {
         var name:* = null;
         var names:Vector.<String> = new Vector.<String>();
         names.push(MAIN_FILE);
         for(name in this.mapFiles.data)
         {
            if(name.indexOf(ADDITIONAL_FILES_START) == 0 && name.indexOf(".a3d") > 0)
            {
               names.push(name);
            }
         }
         return names;
      }
      
      //private function createPoint(radius:Number, color:int, target:Object3D):void {
		//	var box:Mesh = new Box(radius, radius, radius, 5, 5, 5) as Mesh;
		//	var material:FillMaterial = new FillMaterial(color);
      //   box.setMaterialToAllSurfaces(material);
		//	target.addChild(box);
      //   this.uploadResources(scene.getResources(true));
		//}
      
   }

}