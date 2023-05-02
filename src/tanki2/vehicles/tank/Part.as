package tanki2.vehicles.tank
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.resources.ATFTextureResource;
   import alternativa.math.Vector3;
   import flash.display.BitmapData;
   import alternativa.engine3d.objects.Mesh;
   
   public class Part
   {
       
      
      public var name:String;
      
      public var object:Object3D;
      
      public var texturesByName:Object = {};
      
      public function Part()
      {
         super();
      }
      
      public function getTextureByName(textureName:String):ATFTextureResource
      {
         return this.texturesByName[textureName];
      }
      
      public function addTexture(textureName:String, texture:ATFTextureResource):void
      {
         this.texturesByName[textureName] = texture;
      }
      
   }
}
