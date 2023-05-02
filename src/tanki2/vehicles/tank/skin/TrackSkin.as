package tanki2.vehicles.tank.skin 
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.materials.TextureMaterial;
   import alternativa.engine3d.objects.Joint;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.objects.Skin;
   import alternativa.math.Matrix3;
   import alternativa.math.Matrix4;
   import alternativa.math.Vector3;
   import alternativa.physics.PhysicsScene;
   import alternativa.physics.collision.types.RayHit;
   import flash.geom.Matrix3D;
   import flash.geom.Vector3D;
   import flash.net.IDynamicPropertyWriter;
   import tanki2.physics.CollisionGroup;
   import tanki2.vehicles.tank.physics.Chassis;
	/**
    * ...
    * @author juhe
    */
   public class TrackSkin 
   {
      
      private static const m1:Matrix4 = new Matrix4();
      
      private static const eulerAngles:Vector3 = new Vector3();
      
      private var trackMaterial:TrackMaterial;
      
      public var wheels:Vector.<Mesh>;
      
      private var dynamicWheels:Vector.<DynamicWheel>;
      
      private var trackWheelRotation:Number = 0;
      
      public var track:Skin;
      
      private var predicate:RayPredicate;
      
      private static const WHEEL_RAY_LENGTH:Number = 70;
      
      public function TrackSkin(wheelMaterial:TextureMaterial, trackMaterial:TrackMaterial, wheels:Vector.<Mesh>, track:Skin, chassis:Chassis) 
      {
         this.wheels = wheels;
         this.track = track;
         
         for (var i:int = 0; i < this.track.numChildren; i++ )
         {
            var joint:Joint = Joint(this.track.getChildAt(i));
            if (joint.name == "bnL_1_1")
            {
               joint.z = 100;
            }
         }
         
         this.predicate = new RayPredicate(chassis);
         this.dynamicWheels = new Vector.<DynamicWheel>();
         
         this.createDynamicWheels();
         
         if (wheelMaterial != null)
         {
            this.setWheelsMaterial(wheelMaterial);
         }
         
         if (trackMaterial != null)
         {
            this.setTrackMaterial(trackMaterial);
         }
      }
      
      private function createDynamicWheels():void 
      {
         for each (var wheel:Mesh in this.wheels) 
         {
            var wheelName:String = wheel.name;
            if (wheelName.indexOf("whL_1_") == 0 || wheelName.indexOf("whR_1_") == 0)
            {
               var jointName:String = "bn" + wheelName.substr(2);
               var joint:Joint = Joint(this.track.getChildByName(jointName));
               this.dynamicWheels.push(new DynamicWheel(wheel, joint));
            }
         }
      }
      
      public function setTrackMaterial(trackMaterial:TrackMaterial):void 
      {
         this.trackMaterial = trackMaterial;
         this.track.setMaterialToAllSurfaces(trackMaterial)
      }
      
      public function setWheelsMaterial(wheelMaterial:TextureMaterial):void 
      {
         for each (var wheel:Mesh in this.wheels) 
         {
            wheel.setMaterialToAllSurfaces(wheelMaterial);
         }
      }
      
      public function moveTrack(deltaMove:Number, physicsScene:PhysicsScene):void 
      {
         if (this.trackMaterial == null)
            return;
            
         this.trackMaterial.vOffset += deltaMove * 0.0024;
         
         for each (var wheel:Mesh in this.wheels) 
         {
            this.trackWheelRotation -= deltaMove * 0.0017;
            m1.toIdentity();
            m1.setPosition(new Vector3(0,0,0));
            m1.setRotationMatrix(this.trackWheelRotation,0,0);
            m1.getEulerAngles(eulerAngles);
            wheel.rotationX = eulerAngles.x;
            wheel.rotationY = eulerAngles.y;
            wheel.rotationZ = eulerAngles.z;
         }
         
         var rayHit:RayHit = new RayHit();
         
         for each (var dynamicWheel:DynamicWheel in this.dynamicWheels)
         {
            var wheelMesh:Mesh = dynamicWheel.mesh;
            var wheelParrent:Object3D = wheelMesh.parent;
            
            var rayGlobalPos:Vector3D = wheelParrent.localToGlobal(dynamicWheel.originalPosition.clone());
            var rayDirection:Vector3D = new Vector3D(0, 0, -1);
            rayDirection = wheelParrent.localToGlobal(rayDirection);
            rayDirection = rayDirection.subtract(wheelParrent.matrix.position);
            
            if (physicsScene.collisionDetector.raycast(new Vector3().copyFromVector3D(rayGlobalPos), new Vector3().copyFromVector3D(rayDirection), CollisionGroup.ACTIVE_TRACK, WHEEL_RAY_LENGTH, this.predicate, rayHit))
            {
               var hitPos:Vector3D = rayHit.position.toVector3D(new Vector3D());
               hitPos = wheelParrent.globalToLocal(hitPos);
               
               wheelMesh.z = hitPos.z + dynamicWheel.wheelZOffset;
            }
            else 
            {
               wheelMesh.z = dynamicWheel.originalPosition.z - WHEEL_RAY_LENGTH + dynamicWheel.wheelZOffset;
            }
            
            dynamicWheel.joint.z = wheelMesh.z;
         }
      }
   }

}

import alternativa.physics.Body;
import alternativa.physics.collision.IRayCollisionFilter;

class RayPredicate implements IRayCollisionFilter
{
    
   
   private var body:Body;
   
   function RayPredicate(body:Body)
   {
      super();
      this.body = body;
   }
   
   public function considerBody(body:Body) : Boolean
   {
      return this.body != body;
   }
}