package tanki2.vehicles.tank
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.loaders.ParserMaterial;
   import alternativa.engine3d.materials.TextureMaterial;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.objects.Skin;
   import alternativa.engine3d.objects.Surface;
   import alternativa.engine3d.resources.ATFTextureResource;
   import alternativa.engine3d.resources.ExternalTextureResource;
   import alternativa.math.Vector3;
   import alternativa.engine3d.alternativa3d;
   import tanki2.utils.Utils3D;
   import tanki2.vehicles.tank.physics.TankPhysicsData;
   
   use namespace alternativa3d;
   
   public class TankHull extends TankPart
   {
      public var turretSkinMountPoint:Vector3;
      
      public var physicsProfiles:Vector.<TankPhysicsData>;
      
      public var shadowPlane:Mesh;
      
      public var rightWheels:Vector.<Mesh>;
      
      public var leftWheels:Vector.<Mesh>;
      
      public var leftTrack:Skin;
      
      public var rightTrack:Skin;
      
      public var trackDiffuseMap:ATFTextureResource;
      
      public var trackNormalMap:ATFTextureResource;
      
      private var part:Part;
      
      public function TankHull(part:Part)
      {
         this.part = part;
         this.physicsProfiles = new Vector.<TankPhysicsData>();
         this.rightWheels = new Vector.<Mesh>();
         this.leftWheels = new Vector.<Mesh>();
       
         this.trackDiffuseMap = part.getTextureByName("tracks_diffuse");
         this.trackNormalMap = part.getTextureByName("tracks_normalmap");
         
         var object:Object3D = this.part.object;
         this.addShadowPlane(object);
         this.addMountPoint(object);
         this.addTracks(object);
         this.addMainMesh(object);
         
         super(part);
      }
      
      public function getSkinDimensions():Vector3 
      {
         return new Vector3(mainMesh.boundBox.maxX - mainMesh.boundBox.minX, mainMesh.boundBox.maxY - mainMesh.boundBox.minY, mainMesh.boundBox.maxZ - mainMesh.boundBox.minZ);
      }
      
      private function addMainMesh(object:Object3D):void
      {
         object.removeChildren(0);
         
         //for each (var wheel:Object3D in this.leftWheels.concat(this.rightWheels)) 
         //{
         //   object.addChild(wheel);
         //}
         //
         //object.addChild(this.leftTrack);
         //object.addChild(this.rightTrack);
         
         this.mainMesh = Mesh(object);
         this.mainMesh.geometry.calculateTangents(0);
      }
      
      private function addTracks(object:Object3D):void 
      {
         for each (var wheelObject:Object3D in Utils3D.findChildsWithNameBeginning(object, "whR")) 
         {
            this.rightWheels.push(Mesh(wheelObject));
         }
         
         for each (var wheelObject:Object3D in Utils3D.findChildsWithNameBeginning(object, "whL")) 
         {
            leftWheels.push(Mesh(wheelObject));
         }
         
         this.leftTrack = Skin(object.getChildByName("LTrack"));
         this.rightTrack = Skin(object.getChildByName("RTrack"));
         
         this.leftTrack.geometry.calculateTangents(0);
         this.rightTrack.geometry.calculateTangents(0);
      }
      
      private function addMountPoint(object:Object3D):void 
      {
         var mountObject:Object3D = object.getChildByName("mount");
         this.turretSkinMountPoint = new Vector3(mountObject.matrix.position.x, mountObject.matrix.position.y, mountObject.matrix.position.z);
      }
      
      private function addShadowPlane(object:Object3D):void 
      {
         this.shadowPlane = Mesh(object.getChildByName("shadow"));
         this.createMaterialForMesh(this.shadowPlane);
      }
      
      private function createMaterialForMesh(mesh:Mesh):void 
      {
         var diffuseTextureResource:ATFTextureResource;
         var opacityTextureResource:ATFTextureResource;
         var parserMaterial:ParserMaterial;
         
         for each(var surface:Surface in mesh._surfaces)
         {
            parserMaterial = surface.material as ParserMaterial;
            
            if(parserMaterial == null)
               continue;
            
            diffuseTextureResource = this.getAtfTextureResource(parserMaterial.textures["diffuse"]);
            opacityTextureResource = this.getAtfTextureResource(parserMaterial.textures["transparent"]);
            surface.material = new TextureMaterial(diffuseTextureResource, opacityTextureResource);
         }
      }
      
      private function getAtfTextureResource(fileTextureResource:ExternalTextureResource):ATFTextureResource
      {
         if (fileTextureResource != null && fileTextureResource.url)
         {
            var textureName:String = fileTextureResource.url.toLowerCase();
            textureName = textureName.substring(0, textureName.lastIndexOf(".")); // this will remove the file type. example: "jea.jpg" -> "jea"
            return this.part.getTextureByName(textureName);
         }
         return null;
      }
      
      public function cloneLeftWheels():Vector.<Mesh>
      {
         return this.cloneWheels(this.leftWheels);
      }
      
      public function cloneRightWheels():Vector.<Mesh>
      {
         return this.cloneWheels(this.rightWheels);
      }
      
      private function cloneWheels(wheels:Vector.<Mesh>):Vector.<Mesh>
      {
         var newWheels:Vector.<Mesh> = new Vector.<Mesh>();
         for each (var wheel:Mesh in wheels) 
         {
            newWheels.push(wheel.clone());
         }
         return newWheels;
      }
   }
}
