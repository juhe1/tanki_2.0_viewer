package tanki2.vehicles.tank 
{
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.loaders.ParserA3D;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.resources.ATFTextureResource;
   import flash.events.EventDispatcher;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.events.Event;
   import flash.net.URLRequest;
   import alternativa.engine3d.loaders.ParserCollada;
   import flash.utils.ByteArray;
   
	/**
    * ...
    * @author juhe
    */
   public class PartLoader extends EventDispatcher
   {
      private var textureNames:Vector.<String>;
      
      public var part:Part = new Part();
      
      private var path:String;
      
      private var objectLoaded:Boolean = false;
      
      private var textureLoadedCount:int = 0;
      
      private var objectName:String;
      
      public function PartLoader(path:String, textureNames:Vector.<String>, objectName:String)
      {
         this.path = path;
         this.textureNames = textureNames;
         this.objectName = objectName;
      }
      
      public function load():void 
      {
         if (this.objectLoaded)
         {
            throw new Error("This part is already loaded! Please make new partLoader object and use it.")
         }
         
         this.load3DObject(this.path, this.objectName);
         this.loadTextures(this.path, this.textureNames);
      }
      
      private function loadTextures(path, textureNames):void 
      {
         // TODO: maybe start using ExternalTextureResource, because it supports every type, not only atf
         
         for each (var textureName:String in textureNames) 
         {
            var loaderTexture:URLLoader = new URLLoader();
            loaderTexture.dataFormat = URLLoaderDataFormat.BINARY;
            loaderTexture.load(new URLRequest(path + "/" + textureName + ".atf"));
            loaderTexture.addEventListener(Event.COMPLETE, this.createTextureLoadedHandler(textureName));
         }
      }
      
      private function createTextureLoadedHandler(textureName:String):Function 
      {
          return function(e:Event):void 
          {
              onTextureLoaded(e, textureName);
          };
      }

      private function onTextureLoaded(e:Event, textureName:String):void 
      {
         var data:ByteArray = (e.target as URLLoader).data;
         this.part.addTexture(textureName, new ATFTextureResource(data));
         
         this.textureLoadedCount++;
         this.loadingDoneCheck();
      }
      
      private function loadingDoneCheck():void 
      {
         if (this.textureLoadedCount == this.textureNames.length && this.objectLoaded)
         {
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      private function load3DObject(path:String, objectName:String):void 
      {
         var objectPath:String = path + "/" + objectName;
         var objectFileNameSplitted:Array = objectName.split(".");
         var objectFileType:String = String(objectFileNameSplitted[objectFileNameSplitted.length-1]).toLowerCase();
         
         if (objectFileType == "dae")
         {
            var loaderCollada:URLLoader = new URLLoader();
            loaderCollada.dataFormat = URLLoaderDataFormat.TEXT;
            loaderCollada.load(new URLRequest(objectPath));
            loaderCollada.addEventListener(Event.COMPLETE, onColladaLoad);
            return;
         }
         
         if (objectFileType == "a3d")
         {
            var loaderA3D:URLLoader = new URLLoader();
            loaderA3D.dataFormat = URLLoaderDataFormat.BINARY;
            loaderA3D.load(new URLRequest(objectPath));
            loaderA3D.addEventListener(Event.COMPLETE, onA3DLoad);
         }
      }
      
      private function onColladaLoad(e:Event):void
      {
			var parser:ParserCollada = new ParserCollada();
			parser.parse(XML((e.target as URLLoader).data));
         
         this.part.object = this.findMainObject(parser.objects);
         this.objectLoaded = true;
         this.loadingDoneCheck();
		}
      
      private function onA3DLoad(e:Event):void
      {
			var parser:ParserA3D = new ParserA3D();
			parser.parse((e.target as URLLoader).data);
         
         this.part.object = this.findMainObject(parser.objects);
         this.objectLoaded = true;
         this.loadingDoneCheck();
		}
      
      private function findMainObject(objects:Vector.<Object3D>):Object3D 
      {
         for each(var object:Object3D in objects)
         {
            if (object.parent == null && object is Mesh)
            {
               return object;
            }
         }
         return null
      }
      
   }

}