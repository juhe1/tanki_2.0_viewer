package tanki2.maploader 
{
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Resource;
   import alternativa.engine3d.lights.AmbientLight;
   import alternativa.engine3d.lights.DirectionalLight;
   import alternativa.engine3d.lights.OmniLight;
   import alternativa.engine3d.lights.SpotLight;
   import flash.display3D.Context3D;
   import flash.events.Event;
   
	/**
    * ...
    * @author juhe
    */
   
   public class MapObject extends Object3D
   {
      
      private var mapLoader:MapLoader;
      
      public function MapObject(mapLoader:MapLoader)
      {
         this.mapLoader = mapLoader;
         
         this.addObjectsToScene();
         this.addLightsToScene();
      }
      
      private function addLightsToScene():void
      {
         var staticShadowLight:DirectionalLight = null;
         var light:Light3D = null;
         
         for each(light in this.mapLoader.lights)
         {
            if(light is DirectionalLight)
            {
               if(staticShadowLight == null)
               {
                  staticShadowLight = DirectionalLight(light);
               }
               addChild(staticShadowLight);
            }
            else if(light is AmbientLight)
            {
               addChild(AmbientLight(light));
            }
            else if(light is SpotLight)
            {
               addChild(SpotLight(light));
            }
            else if(light is OmniLight)
            {
               addChild(OmniLight(light));
            }
            if(light is AmbientLight || light is DirectionalLight)
            {
               light.intensity *= 2;
            }
            if(light is DirectionalLight || light is AmbientLight)
            {
               light.boundBox = null;
            }
            else
            {
               light.calculateBoundBox();
            }
         }
      }
      
      private function addObjectsToScene() : void
      {
         var object:Object3D = null;
         for each(object in this.mapLoader.objects)
         {
            addChild(object);
         }
      }
      
   }

}