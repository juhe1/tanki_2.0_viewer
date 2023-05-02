package tanki2.vehicles.tank
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.resources.BitmapTextureResource;
   import alternativa.math.Matrix3;
   import alternativa.math.Matrix4;
   import alternativa.math.Quaternion;
   import alternativa.math.Vector3;
   import tanki2.Game;
   import tanki2.GameObject;
   import tanki2.Scene3D;
   import tanki2.display.controllers.CameraTarget;
   import tanki2.physics.TanksCollisionDetector;
   import tanki2.vehicles.tank.physics.Chassis;
   import tanki2.vehicles.tank.physics.ChassisID;
   import tanki2.vehicles.tank.physics.TankPhysicsVisualizer;
   import tanki2.vehicles.tank.skin.TankSkin;
   import tanki2.vehicles.tank.weapons.Weapon;
   import flash.display.BitmapData;
   
   public class Tank extends GameObject implements CameraTarget
   {
      
      private static const _v:Vector3 = new Vector3();
      
      private static const _m:Matrix3 = new Matrix3();
      
      private static const m41:Matrix4 = new Matrix4();
      
      private static const m42:Matrix4 = new Matrix4();
       
      
      private const interpolatedPosition:Vector3 = new Vector3();
      
      private const interpolatedOrientation:Quaternion = new Quaternion();
      
      public var turretAngularSpeed:Number = 1;
      
      public var hull:TankHull;
      
      public var turret:TankTurret;
      
      public var chassis:Chassis;
      
      public var skin:TankSkin;
      
      private var _debug:Boolean;
      
      private var physicsVisualizer:TankPhysicsVisualizer;
      
      private var weapon:Weapon;  
      
      private var interpolatedTurretDirection:Number = 0;
      
      public function Tank(hull:TankHull, turret:TankTurret, colormap:BitmapTextureResource)
      {
         super(GameObject.getId());
         this.chassis = new Chassis(this);
         this.skin = new TankSkin(this.chassis);
         this.setHull(hull);
         this.setTurret(turret);
         this.setColormap(colormap);
      }
      
      public function getCameraParams(position:Vector3, direction:Vector3) : void
      {
         this.interpolatedOrientation.toMatrix3(_m);
         _v.copy(this.interpolatedPosition);
         var h:Number = this.skin.getHalfHeight() + TankConst.SKIN_DISPLACEMENT_Z -200;
         _v.x -= h * _m.c;
         _v.y -= h * _m.g;
         _v.z -= h * _m.k;
         m41.setFromMatrix3(_m,_v);
         var turretMountPoint:Vector3 = this.skin.getHull().turretSkinMountPoint;
         m42.setMatrix(turretMountPoint.x,turretMountPoint.y,turretMountPoint.z,0,0,-this.interpolatedTurretDirection);
         m42.append(m41);
         position.reset(m42.d,m42.h,m42.l);
         direction.reset(m42.b,m42.f,m42.j);
      }
      
      public function setWeapon(weapon:Weapon) : void
      {
         this.weapon = weapon;
         weapon.tank = this;
      }
      
      public function setHull(hull:TankHull) : void
      {
         if(hull == null)
         {
            throw new ArgumentError("Hull is null");
         }
         if(this.hull != hull)
         {
            this.hull = hull;
            this.chassis.setHull(hull);
            this.skin.setHull(hull);
            this.updatePhysicsVisualizer();
         }
      }
      
      public function setTurret(turret:TankTurret) : void
      {
         if(turret == null)
         {
            throw new ArgumentError("Turret is null");
         }
         if(this.turret != turret)
         {
            this.turret = turret;
            this.chassis.setTurret(turret);
            this.skin.setTurret(turret);
            this.updatePhysicsVisualizer();
         }
      }
      
      public function setColormap(colormap:BitmapTextureResource) : void
      {
         this.skin.setColormap(colormap);
      }
      
      public function get turretDirection() : Number
      {
         return this.chassis.turretDirection;
      }
      
      public function set turretDirection(value:Number) : void
      {
         this.chassis.turretDirection = value;
      }
      
      public function rotateTurret(angle:Number) : void
      {
         this.turretDirection += angle;
      }
      
      public function get debug() : Boolean
      {
         return this._debug;
      }
      
      public function set debug(value:Boolean) : void
      {
         if(this._debug != value)
         {
            if(this._debug && this.physicsVisualizer != null)
            {
               this.physicsVisualizer.removeFromContainer();
            }
            this._debug = value;
         }
      }
      
      override public function addToGame(game:Game) : void
      {
         this.game = game;
         game.physicsSystem.physicsScene.addBody(this.chassis);
         game.physicsSystem.physicsControllers.add(this.chassis);
         TanksCollisionDetector(game.physicsSystem.physicsScene.collisionDetector).addBodyWrapper(this.chassis.wrapper);
         var scene3D:Scene3D = game.renderSystem.scene3D;
         this.skin.addToContainer(scene3D);
         this.updatePhysicsVisualizer();
      }
      
      override public function removeFromGame() : void
      {
         if(game != null)
         {
            game.physicsSystem.physicsScene.removeBody(this.chassis);
            game.physicsSystem.physicsControllers.remove(this.chassis);
            TanksCollisionDetector(game.physicsSystem.physicsScene.collisionDetector).removeBodyWrapper(this.chassis.wrapper);
            this.skin.removeFromContainer();
            if(this._debug && this.physicsVisualizer != null)
            {
               this.physicsVisualizer.removeFromContainer();
            }
            game = null;
         }
      }
      
      override public function update(time:uint, deltaMsec:uint, deltaSec:Number, t:Number) : void
      {
         this.updateSkin(t);
         this.skin.updateTracks(deltaSec * this.chassis._leftTrack.getSpeed(),deltaSec * this.chassis._rightTrack.getSpeed(), game.physicsSystem.physicsScene);
         if(this.weapon != null)
         {
            this.weapon.update(time,deltaMsec);
         }
         if(this._debug)
         {
            this.physicsVisualizer.update();
         }
      }
      
      private function updateSkin(t:Number) : void
      {
         var pi2:Number = NaN;
         this.chassis.interpolate(t,this.interpolatedPosition,this.interpolatedOrientation);
         this.interpolatedOrientation.normalize();
         var oldAngle:Number = this.chassis._prevTurretDirection;
         var newAngle:Number = this.chassis._turretDirection;
         var pi_2:Number = 0.5 * Math.PI;
         if(oldAngle < -pi_2 && newAngle > pi_2 || oldAngle > pi_2 && newAngle < -pi_2)
         {
            pi2 = 2 * Math.PI;
            if(oldAngle < newAngle)
            {
               this.interpolatedTurretDirection = oldAngle - t * (pi2 + oldAngle - newAngle);
            }
            else
            {
               this.interpolatedTurretDirection = oldAngle + t * (pi2 - oldAngle + newAngle);
            }
         }
         else
         {
            this.interpolatedTurretDirection = oldAngle + t * (newAngle - oldAngle);
         }
         this.skin.updateTransform(this.interpolatedPosition, this.interpolatedOrientation, this.interpolatedTurretDirection);
      }
      
      private function updatePhysicsVisualizer() : void
      {
         if(this.physicsVisualizer != null)
         {
            this.physicsVisualizer.removeFromContainer();
         }
         if(this.hull != null && this.turret != null)
         {
            this.physicsVisualizer = new TankPhysicsVisualizer(this);
         }
      }
      
      public function getWeapon() : Weapon
      {
         return this.weapon;
      }
      
      public function destroy() : void
      {
         ChassisID.releaseId(this.chassis.chassisId);
      }
   }
}
