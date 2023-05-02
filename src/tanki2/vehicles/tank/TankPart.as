package tanki2.vehicles.tank 
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.resources.ATFTextureResource;
	/**
    * ...
    * @author juhe
    */
   public class TankPart 
   {
      public var mainMesh:Mesh;
      
      public var diffuseMap:ATFTextureResource;
      
      public var normalMap:ATFTextureResource;
      
      public var surfaceMap:ATFTextureResource;
      
      public function TankPart(part:Part)
      {
         this.diffuseMap = part.getTextureByName("diffuse");
         this.normalMap = part.getTextureByName("normalmap");
         this.surfaceMap = part.getTextureByName("surface");
         super();
      }
      
   }

}