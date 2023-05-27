package tanki2.vehicles.tank.skin
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Camera3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.materials.NormalMapSpace;
   import alternativa.engine3d.materials.StandardMaterial;
   import alternativa.engine3d.materials.TextureMaterial;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.objects.Skin;
   import alternativa.engine3d.objects.Surface;
   import alternativa.engine3d.resources.BitmapTextureResource;
   import alternativa.math.Matrix4;
   import alternativa.math.Quaternion;
   import alternativa.math.Vector3;
   import alternativa.physics.PhysicsScene;
   import tanki2.Scene3D;
   import tanki2.vehicles.tank.TankConst;
   import tanki2.vehicles.tank.TankHull;
   import tanki2.vehicles.tank.TankPart;
   import tanki2.vehicles.tank.TankTurret;
   import flash.display.BitmapData;
   import flash.display.BlendMode;
   import flash.display.Shape;
   import tanki2.vehicles.tank.physics.Chassis;
   
   use namespace alternativa3d;
   
   public class TankSkin
   {
      
      private static const m1:Matrix4 = new Matrix4();
      
      private static const m2:Matrix4 = new Matrix4();
      
      private static const eulerAngles:Vector3 = new Vector3();
      
      private static const turretMatrix:Matrix4 = new Matrix4();
       
      
      private var _colormap:BitmapTextureResource;
      
      private var _hull:TankHull;
      
      private var _hullMesh:Mesh;
      
      private var _turret:TankTurret;
      
      private var _turretMesh:Mesh;
      
      private var leftTrackSkin:TrackSkin;
      
      private var rightTrackSkin:TrackSkin;
      
      private var container:Object3D;
      
      private var chassis:Chassis;
      
      public function TankSkin(chassis:Chassis)
      {
         this.chassis = chassis;
         this._hullMesh = new Mesh();
         this._turretMesh = new Mesh();
         super();
      }
      
      private static function setObjectTransformation(object:Object3D, m:Matrix4) : void
      {
         m.getEulerAngles(eulerAngles);
         object.x = m.d;
         object.y = m.h;
         object.z = m.l;
         object.rotationX = eulerAngles.x;
         object.rotationY = eulerAngles.y;
         object.rotationZ = eulerAngles.z;
      }
      
      public function get visible() : Boolean
      {
         return this._hullMesh.visible;
      }
      
      public function set visible(value:Boolean) : void
      {
         this._hullMesh.visible = value;
         this._turretMesh.visible = value;
      }
      
      public function addToContainer(scene3D:Scene3D) : void
      {
         this.container = scene3D.getMap();
         if(this._hullMesh != null)
         {
            this.addHullToContainer()
            
         }
         if(this._turretMesh != null)
         {
            container.addChild(this._turretMesh);
         }
         
         scene3D.uploadResources(this.container.getResources(true));
      }
      
      public function removeFromContainer() : void
      {
         if(this.container != null)
         {
            if(this._hullMesh != null)
            {
               this.removeHullFromContainer();
            }
            if(this._turretMesh != null)
            {
               this.container.removeChild(this._turretMesh);
            }
         }
      }
      
      public function get hullMesh() : Mesh
      {
         return this._hullMesh;
      }
      
      public function get turretMesh() : Mesh
      {
         return this._turretMesh;
      }
      
      public function getHull() : TankHull
      {
         return this._hull;
      }
      
      public function setHull(value:TankHull) : void
      {
         if(this._hull != null && this.container != null)
         {
            this.container.removeChild(this._hullMesh);
         }
         
         this._hull = value;
         
         if(this._hull != null)
         {
            this.leftTrackSkin = new TrackSkin(null, null, this._hull.cloneLeftWheels(), Skin(this._hull.leftTrack.clone()), chassis);
            this.rightTrackSkin = new TrackSkin(null, null, this._hull.cloneRightWheels(), Skin(this._hull.rightTrack.clone()), chassis);
            
            this._hullMesh = Mesh(this._hull.mainMesh.clone());
            if(this.container != null)
            {
               this.addHullToContainer();
            }
         }
         this.updatePartTexture(this._hull, this._hullMesh);
      }
      
      private function addHullToContainer():void 
      {
         this.container.addChild(this._hullMesh);
         _hullMesh.addChild(this.leftTrackSkin.track);
         _hullMesh.addChild(this.rightTrackSkin.track);
         
         for each (var wheel in this.leftTrackSkin.wheels.concat(this.rightTrackSkin.wheels)) 
         {
            _hullMesh.addChild(wheel);
         }
      }
      
      private function removeHullFromContainer():void 
      {
         this.container.removeChild(this._hullMesh);
         this.container.removeChild(this.leftTrackSkin.track);
         this.container.removeChild(this.rightTrackSkin.track);
         
         for each (var wheel in this.leftTrackSkin.wheels.concat(this.rightTrackSkin.wheels)) 
         {
            this.container.removeChild(wheel);
         }
      }
      
      public function getTurret() : TankTurret
      {
         return this._turret;
      }
      
      public function setTurret(value:TankTurret) : void
      {
         var container:Object3D = null;
         if(this._turret != null)
         {
            container = this._turretMesh.parent;
            this._turretMesh.removeFromParent();
         }
         this._turret = value;
         if(this._turret != null)
         {
            this._turretMesh = Mesh(this._turret.mainMesh.clone());
            if(container != null)
            {
               container.addChild(this._turretMesh);
            }
         }
         this.updatePartTexture(this._turret, this._turretMesh);
      }
      
      public function setColormap(value:BitmapTextureResource) : void
      {
         if(value != null)
         {
            this._colormap = value;
            this.updatePartTexture(this._hull,this._hullMesh);
            this.updatePartTexture(this._turret,this._turretMesh);
         }
      }
      
      public function getHalfHeight() : Number
      {
         return (this._hullMesh.boundBox.maxZ - this._hullMesh.boundBox.minZ) / 2;
      }
      
      public function updateTransform(position:Vector3, orientation:Quaternion, turretDirection:Number) : void
      {
         if(this._hull != null)
         {
            orientation.toMatrix4(m1);
            m1.setPosition(position);
            m2.toIdentity();
            m2.l = -(this.getHalfHeight() + TankConst.SKIN_DISPLACEMENT_Z);
            m2.append(m1);
            setObjectTransformation(this._hullMesh,m2);
            if(this._turret != null)
            {
               m1.toIdentity();
               m1.setPosition(this._hull.turretSkinMountPoint);
               m1.setRotationMatrix(0,0,-turretDirection);
               m1.append(m2);
               setObjectTransformation(this._turretMesh,m1);
            }
         }
      }
      
      public function updateTracks(deltaLeft:Number, deltaRight:Number, physicsScene:PhysicsScene) : void
      {
         this.leftTrackSkin.moveTrack(deltaLeft, physicsScene);
         this.rightTrackSkin.moveTrack(deltaRight, physicsScene);
      }
      
      private function updatePartTexture(part:TankPart, mesh:Mesh) : void
      {
         var material:TankMaterial = new TankMaterial(part.diffuseMap, this._colormap, part.surfaceMap, part.normalMap);
         mesh.setMaterialToAllSurfaces(material);
         
         if (part is TankHull)
         {
            var tankHull:TankHull = TankHull(part);
            var wheelMaterial:TankMaterial = new TankMaterial(part.diffuseMap, this._colormap, part.surfaceMap, part.normalMap);
            
            var rightTrackMaterial:TrackMaterial = new TrackMaterial(tankHull.trackDiffuseMap, tankHull.trackNormalMap);
            this.rightTrackSkin.setTrackMaterial(rightTrackMaterial);
            this.rightTrackSkin.setWheelsMaterial(wheelMaterial);
            
            var leftTrackMaterial:TrackMaterial = TrackMaterial(rightTrackMaterial.clone());
            this.leftTrackSkin.setTrackMaterial(leftTrackMaterial);
            this.leftTrackSkin.setWheelsMaterial(wheelMaterial);
            
            material.tilingX = 6;
            material.tilingY = 6;
         }
      }
      
      public function getGlobalMuzzlePosition(index:int) : Vector3
      {
         turretMatrix.setMatrix(this._turretMesh.x,this._turretMesh.y,this._turretMesh.z,this._turretMesh.rotationX,this._turretMesh.rotationY,this._turretMesh.rotationZ);
         var result:Vector3 = new Vector3();
         turretMatrix.transformVector(this._turret.muzzlePoints[index],result);
         return result;
      }
   }
}
