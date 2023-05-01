package tanki2.vehicles.tank.physics
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.math.Matrix3;
   import alternativa.math.Matrix4;
   import alternativa.math.Vector3;
   import alternativa.physics.Body;
   import alternativa.physics.PhysicsMaterial;
   import alternativa.physics.PhysicsUtils;
   import alternativa.physics.collision.primitives.CollisionBox;
   import tanki2.battle.PhysicsController;
   import tanki2.battle.objects.tank.TankBodyWrapper;
   import tanki2.physics.CollisionGroup;
   import tanki2.vehicles.tank.Tank;
   import tanki2.vehicles.tank.TankConst;
   import tanki2.vehicles.tank.TankHull;
   import tanki2.vehicles.tank.TankTurret;
   
   use namespace alternativa3d;
   
   public class Chassis extends Body implements PhysicsController
   {
      
      private static const PHYSICS_MATERIAL:PhysicsMaterial = new PhysicsMaterial(0,0.3);
      
      private static const LOW_FRICTION_MATERIAL:PhysicsMaterial = new PhysicsMaterial(0,0.1);
       
      
      public var chassisId:int;
      
      public var _leftTrack:Track;
      
      public var _rightTrack:Track;
      
      public var _moveDirection:int = 0;
      
      public var _turnDirection:int = 0;
      
      public var _turretTurnDirection:int = 0;
      
      public var _currentProfile:TankPhysicsData;
      
      private var _profiles:Vector.<TankPhysicsData>;
      
      private var _currtProfileIndex:int;
      
      public var _turretDirection:Number = 0;
      
      public var _prevTurretDirection:Number = 0;
      
      private const turretMountPoint:Vector3 = new Vector3();
      
      private var hull:TankHull;
      
      private var turret:TankTurret;
      
      private var _collisionGroup:int;
      
      public var tank:Tank;
      
      public var wrapper:TankBodyWrapper;
      
      public function Chassis(tank:Tank)
      {
         this._currentProfile = new TankPhysicsData();
         this._profiles = new Vector.<TankPhysicsData>();
         super(1,Matrix3.IDENTITY);
         this.chassisId = ChassisID.getId();
         this.tank = tank;
         this.wrapper = new TankBodyWrapper(this);
      }
      
      public function setControls(moveDirection:int, turnDirection:int, force:Boolean) : void
      {
         if(force || this._moveDirection != moveDirection || this._turnDirection != turnDirection)
         {
            this._moveDirection = moveDirection;
            this._turnDirection = turnDirection;
            this._leftTrack.updateControls(moveDirection,turnDirection);
            this._rightTrack.updateControls(moveDirection,turnDirection);
         }
      }
      
      public function get numProfiles() : int
      {
         return this._profiles.length;
      }
      
      public function get profiles() : Vector.<TankPhysicsData>
      {
         return this._profiles;
      }
      
      public function get currProfileIndex() : int
      {
         return this._currtProfileIndex;
      }
      
      public function addProfile() : void
      {
         this._profiles.push(this._currentProfile.clone());
      }
      
      public function removeProfile(profileIndex:int) : void
      {
         this.checkProfileIndex(profileIndex);
         if(this._profiles.length < 2)
         {
            return;
         }
         this._profiles.splice(profileIndex,1);
         if(this._currtProfileIndex >= profileIndex)
         {
            --this._currtProfileIndex;
            if(this._currtProfileIndex < 0)
            {
               this._currtProfileIndex = 0;
            }
            this.loadProfile(this._currtProfileIndex);
         }
      }
      
      public function updateProfile(profileIndex:int, pData:TankPhysicsData) : void
      {
         this.checkProfileIndex(profileIndex);
         TankPhysicsData(this._profiles[this._currtProfileIndex]).copy(pData);
      }
      
      public function loadProfile(profileIndex:int) : void
      {
         if(this.hull == null)
         {
            throw Error("Hull is not set");
         }
         this.checkProfileIndex(profileIndex);
         this._currtProfileIndex = profileIndex;
         this._currentProfile.copy(this._profiles[this._currtProfileIndex]);
         this.setMass(this._currentProfile.mass);
         this.updateRaysLengths();
      }
      
      public function setHull(hull:TankHull) : void
      {
         var halfSize:Vector3 = null;
         var dimensions:Vector3 = null;
         var trackLength:Number = NaN;
         var widthBetween:Number = NaN;
         var rayOffset:Number = NaN;
         var data:TankPhysicsData = null;
         if(hull == null)
         {
            throw new ArgumentError("Parameter hull cannot be null");
         }
         if(this.hull != hull)
         {
            this.hull = hull;
            halfSize = hull.getSkinDimensions().scale(0.5);
            this.rebuildPhysicsData(halfSize);
            this.turretMountPoint.copy(hull.turretSkinMountPoint);
            this.turretDirection = this._turretDirection;
            dimensions = halfSize.clone().scale(2);
            trackLength = dimensions.y * 0.8;
            widthBetween = dimensions.x - 40;
            rayOffset = TankConst.RAY_OFFSET;
            this._leftTrack = new Track(this,new Vector3(-0.5 * widthBetween,0,-0.5 * dimensions.z + rayOffset),trackLength,CollisionGroup.ACTIVE_TRACK);
            this._rightTrack = new Track(this,new Vector3(0.5 * widthBetween,0,-0.5 * dimensions.z + rayOffset),trackLength,CollisionGroup.ACTIVE_TRACK);
            this._profiles.length = 0;
            for each(data in hull.physicsProfiles)
            {
               this._profiles.push(data.clone());
            }
            this.loadProfile(0);
            this.setControls(this._moveDirection,this._turnDirection,true);
         }
      }
      
      private function rebuildPhysicsData(halfSize:Vector3) : void
      {
         PhysicsUtils.setBoxInvInertia(1 / invMass,halfSize,invInertia);
         removeCollisionData();
         this.wrapper.staticCollisionPrimitives.length = 0;
         this.createCollisionPrimitives(halfSize.clone());
      }
      
      private function createCollisionPrimitives(bodyHalfSize:Vector3) : void
      {
         var totalCollisionHeight:Number = 2 * bodyHalfSize.z - TankConst.SKIN_DISPLACEMENT_Z;
         this.createTankCollisionBox(bodyHalfSize,totalCollisionHeight);
         this.createStaticCollisionBoxes(bodyHalfSize,totalCollisionHeight);
      }
      
      private function createTankCollisionBox(bodyHalfSize:Vector3, totalCollisionHeight:Number) : void
      {
         var halfSize:Vector3 = new Vector3(bodyHalfSize.x,bodyHalfSize.y,totalCollisionHeight / 2);
         var collisionBox:CollisionBox = new CollisionBox(halfSize,CollisionGroup.TANK | CollisionGroup.ACTIVE_TRACK,LOW_FRICTION_MATERIAL);
         var localTransform:Matrix4 = new Matrix4();
         localTransform.l = totalCollisionHeight / 2 - bodyHalfSize.z;
         this.wrapper.body.addCollisionPrimitive(collisionBox,localTransform);
         this.wrapper.tankCollisionBox = collisionBox;
      }
      
      private function createStaticCollisionBoxes(bodyHalfSize:Vector3, totalCollisionHeight:Number) : void
      {
         var topBoxHeight:Number = totalCollisionHeight / 3;
         var topBoxHalfSize:Vector3 = new Vector3(bodyHalfSize.x,bodyHalfSize.y,topBoxHeight / 2);
         var topBoxLocalTransform:Matrix4 = new Matrix4();
         topBoxLocalTransform.l = totalCollisionHeight - bodyHalfSize.z - topBoxHeight / 2;
         var topBox:CollisionBox = new CollisionBox(topBoxHalfSize,CollisionGroup.STATIC,PHYSICS_MATERIAL);
         this.wrapper.body.addCollisionPrimitive(topBox,topBoxLocalTransform);
         this.wrapper.staticCollisionPrimitives.push(topBox);
         var bottomBoxHeight:Number = 5 / 6 * totalCollisionHeight;
         var bottomBoxHalfSize:Vector3 = new Vector3(bodyHalfSize.x,bodyHalfSize.y * 0.8,bottomBoxHeight / 2);
         var bottomBoxLocalTransform:Matrix4 = new Matrix4();
         bottomBoxLocalTransform.l = bottomBoxHeight / 2 - bodyHalfSize.z;
         var bottomBox:CollisionBox = new CollisionBox(bottomBoxHalfSize,CollisionGroup.STATIC,LOW_FRICTION_MATERIAL);
         this.wrapper.body.addCollisionPrimitive(bottomBox,bottomBoxLocalTransform);
         this.wrapper.staticCollisionPrimitives.push(bottomBox);
      }
      
      public function setTurret(turret:TankTurret) : void
      {
         if(turret == null)
         {
            throw new ArgumentError("Parameter turret cannot be null");
         }
         if(this.turret == turret)
         {
            return;
         }
         this.turret = turret;
         this.turretDirection = this._turretDirection;
      }
      
      public function get turretDirection() : Number
      {
         return this._turretDirection;
      }
      
      public function set turretDirection(value:Number) : void
      {
         if(value < -Math.PI)
         {
            value += 2 * Math.PI;
         }
         else if(value > Math.PI)
         {
            value -= 2 * Math.PI;
         }
         this._turretDirection = value;
      }
      
      public function set collisionGroup(value:int) : void
      {
         if(this._collisionGroup == value)
         {
            return;
         }
         this._collisionGroup = value;
         this.tracksCollisionGroup = value;
      }
      
      public function set tracksCollisionGroup(value:int) : void
      {
         this._leftTrack.collisionGroup = value;
         this._rightTrack.collisionGroup = value;
      }
      
      public function runBeforePhysicsUpdate(dt:Number) : void
      {
         var d:Number = NaN;
         var limit:Number = NaN;
         var fx:Number = NaN;
         var fy:Number = NaN;
         var fz:Number = NaN;
         this._prevTurretDirection = this._turretDirection;
         if(this._turretTurnDirection != 0)
         {
            this.turretDirection += this._turretTurnDirection * this.tank.turretAngularSpeed * dt;
         }
         var m:Number = this._currentProfile.mass;
         var gravity:Vector3 = scene._gravity;
         var gMagnitude:Number = scene._gravityMagnitude;
         var weight:Number = m * gMagnitude;
         var power:Number = 0.5 * this._currentProfile.power;
         this._leftTrack.addForces(dt,weight,power);
         this._rightTrack.addForces(dt,weight,power);
         if(this._rightTrack._numContacts >= this._rightTrack._numRays >> 1 || this._leftTrack._numContacts >= this._leftTrack._numRays >> 1)
         {
            d = gravity.x * baseMatrix.c + gravity.y * baseMatrix.g + gravity.z * baseMatrix.k;
            limit = Math.SQRT1_2 * gMagnitude;
            if(d < -limit || d > limit)
            {
               fx = (baseMatrix.c * d - gravity.x) * m;
               fy = (baseMatrix.g * d - gravity.y) * m;
               fz = (baseMatrix.k * d - gravity.z) * m;
               addForceXYZ(fx,fy,fz);
            }
         }
      }
      
      private function setMass(value:Number) : void
      {
         if(value <= 0)
         {
            throw new ArgumentError("Mass must have a positive value");
         }
         invMass = 1 / value;
         if(this.hull != null)
         {
            PhysicsUtils.setBoxInvInertia(value,this.hull.getSkinDimensions().scale(0.5),invInertia);
         }
      }
      
      private function updateRaysLengths() : void
      {
         var rayWorkLength:Number = NaN;
         var rayRestLength:Number = NaN;
         if(this.hull != null)
         {
            rayWorkLength = TankConst.RAY_OFFSET + TankConst.SKIN_DISPLACEMENT_Z;
            rayRestLength = this._currentProfile.rayLength;
            this._leftTrack.setRayLengths(rayRestLength,rayWorkLength);
            this._rightTrack.setRayLengths(rayRestLength,rayWorkLength);
         }
      }
      
      private function checkProfileIndex(profileIndex:int) : void
      {
         if(profileIndex < 0 || profileIndex >= this._profiles.length)
         {
            throw new ArgumentError("Wrong profile index");
         }
      }
   }
}
