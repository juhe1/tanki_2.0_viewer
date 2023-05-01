package 
{
   import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.loaders.Parser3DS;
	import alternativa.engine3d.loaders.ParserA3D;
	import alternativa.engine3d.loaders.ParserCollada;
	import alternativa.engine3d.loaders.ParserMaterial;
	import alternativa.engine3d.loaders.TexturesLoader;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.resources.ExternalTextureResource;
	import alternativa.engine3d.resources.Geometry;
   import alternativa.engine3d.resources.TextureResource;

	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
   
	/**
    * ...
    * @author juhe
    */
   public class test extends Sprite
   {
      
      private var scene:Object3D = new Object3D();
		
		private var camera:Camera3D;
		private var controller:SimpleObjectController;
		
		private var stage3D:Stage3D;
      
      public function test() 
      {
         stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// Camera and view
			// Создание камеры и вьюпорта
			camera = new Camera3D(1, 1000);
			camera.view = new View(stage.stageWidth, stage.stageHeight, false, 0, 0, 4);
			addChild(camera.view);
			addChild(camera.diagram);
			
			// Initial position
			// Установка начального положения камеры
			camera.rotationX = -130*Math.PI/180;
			camera.y = -30;
			camera.z = 35;
			controller = new SimpleObjectController(stage, camera, 50);
			scene.addChild(camera);
			
			stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
			stage3D.requestContext3D();
      }
      
      private function onContextCreate(e:Event):void {
			stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
         //stage3D.context3D.enableErrorChecking = true;
			
			// Загрузка моделей
			// Models loading
			
			var loaderA3D:URLLoader = new URLLoader();
			loaderA3D.dataFormat = URLLoaderDataFormat.BINARY;
			loaderA3D.load(new URLRequest("resources/turrets/thunder/m3/turret.a3d"));
			loaderA3D.addEventListener(Event.COMPLETE, onA3DLoad);

			// Listeners
			// Подписка на события
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		private function onA3DLoad(e:Event):void {
			// Model parsing
			// Парсинг модели
         var textureName:String;
			var parser:ParserA3D = new ParserA3D();
         var turretObject:Object3D;
			parser.parse((e.target as URLLoader).data);
			trace(parser.objects);
			var mesh:Mesh;
			for each (var object:Object3D in parser.objects) {
            if (object.name == "Box01" || object.name == "Box03" || object.name == "Box02" || object.name == "barrel")
            {
               continue;
            }
            if (object.name == "fmnt" || object.name == "muzzle01")
            {
               textureName = "texTools_checkermap_a.png";
            }
            else 
            {
               textureName = "diffuse.atf";
            }
            
            if (object.name == "turret")
            {
               turretObject = object;
            }
            
            textureName = "diffuse.atf";
            //textureName = "texTools_checkermap_a.png";
            
			   mesh = object as Mesh;
            mesh.x -= 10;
            
            uploadResources(mesh.getResources(false, Geometry));
            
            // Setup materials
            // Собираем текстуры и назначаем материалы
            var textures:Vector.<ExternalTextureResource> = new Vector.<ExternalTextureResource>();
            for (var i:int = 0; i < mesh.numSurfaces; i++) {
               var surface:Surface = mesh.getSurface(i);
               
               var diffuse:ExternalTextureResource = new ExternalTextureResource("resources/turrets/thunder/m3/" + textureName);
               textures.push(diffuse);
               surface.material = new TextureMaterial(diffuse);
            }
            
            // Loading of textures
            // Загрузка текстур
            var texturesLoader:TexturesLoader = new TexturesLoader(stage3D.context3D);
            texturesLoader.loadResources(textures);
			}
         
         scene.addChild(turretObject);
		}

		private function uploadResources(resources:Vector.<Resource>):void {
			for each (var resource:Resource in resources) {
				resource.upload(stage3D.context3D);
			}
		}

		private function onEnterFrame(e:Event):void {
			controller.update();
			camera.render(stage3D);
		}
		
		private function onResize(e:Event = null):void {
			camera.view.width = stage.stageWidth;
			camera.view.height = stage.stageHeight;
		}
   }

}