package tanki2.display.controllers
{
   import alternativa.engine3d.core.EllipsoidCollider;
   import alternativa.engine3d.core.Object3DContainer;
   import alternativa.engine3d.primitives.Sphere;
   import alternativa.math.Matrix3;
   import alternativa.math.Vector3;
   import alternativa.physics.collision.CollisionDetector;
   import alternativa.physics.collision.types.RayHit;
   import alternativa.tanks.display.GameCamera;
   import alternativa.tanks.display.ICameraController;
   import flash.display.Stage;
   import flash.events.KeyboardEvent;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   
   public class FollowCameraController extends CameraControllerBase implements ICameraController
   {
      
      private static const KEYS_CAMERA_UP:Vector.<uint> = Vector.<uint>([Keyboard.PAGE_UP,Keyboard.Q]);
      
      private static const KEYS_CAMERA_DOWN:Vector.<uint> = Vector.<uint>([Keyboard.PAGE_DOWN,Keyboard.E]);
      
      public static var maxPositionError:Number = 10;
      
      public static var maxAngleError:Number = Math.PI / 180;
      
      public static var camSpeedThreshold:Number = 10;
      
      private static const rotationMatrix:Matrix3 = new Matrix3();
      
      private static const elevationAngles:Vector.<Number> = new Vector.<Number>(1,true);
      
      private static const axis:Vector3 = new Vector3();
      
      private static const rayDirection:Vector3 = new Vector3();
      
      private static const MIN_DISTANCE:Number = 300;
      
      private static const COLLISION_OFFSET:Number = 50;
      
      private static const currentPosition:Vector3 = new Vector3();
      
      private static const currentRotation:Vector3 = new Vector3();
      
      private static const rayOrigin:Vector3 = new Vector3();
      
      private static const flatDirection:Vector3 = new Vector3();
      
      private static const positionDelta:Vector3 = new Vector3();
      
      private static const rayIntersection:RayHit = new RayHit();
      
      private static const PI2:Number = 2 * Math.PI;
       
      
      public var inputLocked:Boolean;
      
      private var stage:Stage;
      
      private var collisionDetector:CollisionDetector;
      
      private var cameraCollisionGroup:int;
      
      private var cameraDistance:Number = 0;
      
      private var locked:Boolean;
      
      private var keyUpPressed:Boolean;
      
      private var keyDownPressed:Boolean;
      
      private var active:Boolean;
      
      private var target:CameraTarget;
      
      private var position:Vector3;
      
      private var rotation:Vector3;
      
      private var targetPosition:Vector3;
      
      private var targetDirection:Vector3;
      
      private var linearSpeed:Number = 0;
      
      private var pitchSpeed:Number = 0;
      
      private var yawSpeed:Number = 0;
      
      private var lastCollisionDistance:Number = 10000000;
      
      private var lastMinDistanceTime:int;
      
      private var cameraPositionData:CameraPositionData;
      
      private var baseElevation:Number;
      
      private var extraPitchFromTarget:Number = 0;
      
      private var _cameraT:Number = 0;
      
      private var cameraPosition:Point;
      
      private var point0:Point;
      
      private var point1:Point;
      
      private var point2:Point;
      
      private var point3:Point;
      
      public var collisionObject:Object3DContainer;
      
      private var collisionFilter:Dictionary;
      
      private var collider:EllipsoidCollider;
      
      private var startMarker:Sphere;
      
      private var endMarker:Sphere;
      
      private const rayOrigin3D:Vector3D = new Vector3D();
      
      private const rayDirection3D:Vector3D = new Vector3D();
      
      private const displacement:Vector3D = new Vector3D();
      
      private const collisionPoint:Vector3D = new Vector3D();
      
      private const collisionNormal:Vector3D = new Vector3D();
      
      private const v:Vector3 = new Vector3();
      
      public function FollowCameraController(stage:Stage, collisionDetector:CollisionDetector, camera:GameCamera, cameraCollisionGroup:int, collisionObject:Object3DContainer, collisionFilter:Dictionary)
      {
         this.position = new Vector3();
         this.rotation = new Vector3();
         this.targetPosition = new Vector3();
         this.targetDirection = new Vector3();
         this.cameraPositionData = new CameraPositionData();
         this.cameraPosition = new Point();
         super(camera);
         this.collisionObject = collisionObject;
         this.collisionFilter = collisionFilter;
         this.collider = new EllipsoidCollider(25,25,25);
         if(stage == null)
         {
            throw new ArgumentError("Parameter stage cannot be null");
         }
         if(collisionDetector == null)
         {
            throw new ArgumentError("Parameter collisionDetector cannot be null");
         }
         this.stage = stage;
         this.collisionDetector = collisionDetector;
         this.cameraCollisionGroup = cameraCollisionGroup;
         this.point0 = new Point(145,545);
         this.point1 = new Point(930,1395);
         this.point2 = new Point(2245,1565);
         this.point3 = new Point(3105,760);
         this.setCameraT(0.2);
      }
      
      private static function bezier(t:Number, p0:Number, p1:Number, p2:Number, p3:Number) : Number
      {
         var c1:Number = 3 * (p1 - p0);
         var c2:Number = 3 * p0 - 6 * p1 + 3 * p2;
         var c3:Number = -p0 + 3 * p1 - 3 * p2 + p3;
         return p0 + t * c1 + t * t * c2 + t * t * t * c3;
      }
      
      public static function clampAngle(radians:Number) : Number
      {
         radians %= PI2;
         if(radians < -Math.PI)
         {
            return PI2 + radians;
         }
         if(radians > Math.PI)
         {
            return radians - PI2;
         }
         return radians;
      }
      
      public static function clampAngleFast(radians:Number) : Number
      {
         if(radians < -Math.PI)
         {
            return PI2 + radians;
         }
         if(radians > Math.PI)
         {
            return radians - PI2;
         }
         return radians;
      }
      
      public static function snap(value:Number, snapValue:Number, epsilon:Number) : Number
      {
         if(value > snapValue - epsilon && value < snapValue + epsilon)
         {
            return snapValue;
         }
         return value;
      }
      
      public static function clamp(value:Number, min:Number, max:Number) : Number
      {
         if(value < min)
         {
            return min;
         }
         if(value > max)
         {
            return max;
         }
         return value;
      }
      
      public function setTarget(value:CameraTarget) : void
      {
         this.target = value;
      }
      
      public function setTargetParams(targetPosition:Vector3, targetDirection:Vector3) : void
      {
         this.targetPosition.copy(targetPosition);
         this.targetDirection.copy(targetDirection);
         this.lastMinDistanceTime = 0;
         this.getCameraPositionData(targetPosition,targetDirection,false,10000,this.cameraPositionData);
         this.position.copy(this.cameraPositionData.position);
         this.rotation.x = this.getPitchAngle(this.cameraPositionData) - 0.5 * Math.PI;
         this.rotation.y = 0;
         this.rotation.z = Math.atan2(-targetDirection.x,targetDirection.y);
         setPosition(this.position);
         setOrientation(this.rotation);
      }
      
      public function initCameraComponents() : void
      {
         this.position.copy(getCameraPosition());
         this.rotation.reset(getCameraRotationX(),getCameraRotationY(),getCameraRotationZ());
      }
      
      public function activate() : void
      {
         if(!this.active)
         {
            this.active = true;
            this.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKey);
            this.stage.addEventListener(KeyboardEvent.KEY_UP,this.onKey);
            if(this.startMarker != null)
            {
               this.collisionObject.addChild(this.startMarker);
               this.collisionObject.addChild(this.endMarker);
            }
         }
      }
      
      public function deactivate() : void
      {
         if(this.active)
         {
            this.active = false;
            this.stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKey);
            this.stage.removeEventListener(KeyboardEvent.KEY_UP,this.onKey);
            this.keyUpPressed = false;
            this.keyDownPressed = false;
         }
      }
      
      public function updateCamera(time:uint, timeDelta:uint, deltaSec:Number) : void
      {
         if(this.target == null)
         {
            return;
         }
         var dt:Number = timeDelta * 0.001;
         if(dt > 0.1)
         {
            dt = 0.1;
         }
         this.updateCameraHeight(dt);
         if(!this.locked)
         {
            this.recalculateTargetData();
         }
         this.getCameraPositionData(this.targetPosition,this.targetDirection,true,dt,this.cameraPositionData);
         positionDelta.diff(this.cameraPositionData.position,this.position);
         var positionError:Number = positionDelta.length();
         if(positionError > maxPositionError)
         {
            this.linearSpeed = this.getLinearSpeed(positionError - maxPositionError);
         }
         var distance:Number = this.linearSpeed * dt;
         if(distance > positionError)
         {
            distance = positionError;
         }
         positionDelta.normalize().scale(distance);
         var targetPitchAngle:Number = this.getPitchAngle(this.cameraPositionData);
         var targetYawAngle:Number = Math.atan2(-this.targetDirection.x,this.targetDirection.y);
         var currentPitchAngle:Number = clampAngle(this.rotation.x + 0.5 * Math.PI);
         var currentYawAngle:Number = clampAngle(this.rotation.z);
         var pitchError:Number = clampAngleFast(targetPitchAngle - currentPitchAngle);
         this.pitchSpeed = this.getAngularSpeed(pitchError,this.pitchSpeed);
         var deltaPitch:Number = this.pitchSpeed * dt;
         if(pitchError > 0 && deltaPitch > pitchError || pitchError < 0 && deltaPitch < pitchError)
         {
            deltaPitch = pitchError;
         }
         var yawError:Number = clampAngleFast(targetYawAngle - currentYawAngle);
         this.yawSpeed = this.getAngularSpeed(yawError,this.yawSpeed);
         var deltaYaw:Number = this.yawSpeed * dt;
         if(yawError > 0 && deltaYaw > yawError || yawError < 0 && deltaYaw < yawError)
         {
            deltaYaw = yawError;
         }
         this.linearSpeed = snap(this.linearSpeed,0,camSpeedThreshold);
         this.pitchSpeed = snap(this.pitchSpeed,0,camSpeedThreshold);
         this.yawSpeed = snap(this.yawSpeed,0,camSpeedThreshold);
         this.position.add(positionDelta);
         this.rotation.x += deltaPitch;
         this.rotation.z += deltaYaw;
         currentPosition.copy(this.position);
         currentRotation.copy(this.rotation);
         setPosition(currentPosition);
         setOrientation(currentRotation);
      }
      
      public function setLocked(locked:Boolean) : void
      {
         this.locked = locked;
      }
      
      public function getCameraT() : Number
      {
         return this._cameraT;
      }
      
      public function setCameraT(value:Number) : void
      {
         this._cameraT = clamp(value,0,1);
         this.cameraPosition.x = bezier(this._cameraT,this.point0.x,this.point1.x,this.point2.x,this.point3.x);
         this.cameraPosition.y = bezier(this._cameraT,this.point0.y,this.point1.y,this.point2.y,this.point3.y);
         this.baseElevation = Math.atan2(this.cameraPosition.x,this.cameraPosition.y);
         this.cameraDistance = this.cameraPosition.length;
         this.lastMinDistanceTime = 0;
      }
      
      public function getCameraState(targetPosition:Vector3, targetDirection:Vector3, resultingPosition:Vector3, resultingAngles:Vector3) : void
      {
         this.getCameraPositionData(targetPosition,targetDirection,false,10000,this.cameraPositionData);
         resultingAngles.x = this.getPitchAngle(this.cameraPositionData) - 0.5 * Math.PI;
         resultingAngles.z = Math.atan2(-targetDirection.x,targetDirection.y);
         resultingPosition.copy(this.cameraPositionData.position);
      }
      
      public function recalculateTargetData() : void
      {
         this.target.getCameraParams(this.targetPosition,this.targetDirection);
      }
      
      private function getCameraPositionData(targetPosition:Vector3, targetDirection:Vector3, useReboundDelay:Boolean, dt:Number, result:CameraPositionData) : void
      {
         var actualElevation:Number = this.baseElevation;
         var xyLength:Number = Math.sqrt(targetDirection.x * targetDirection.x + targetDirection.y * targetDirection.y);
         if(xyLength < 0.00001)
         {
            flatDirection.x = 1;
            flatDirection.y = 0;
         }
         else
         {
            flatDirection.x = targetDirection.x / xyLength;
            flatDirection.y = targetDirection.y / xyLength;
         }
         result.extraPitch = 0;
         rayOrigin.copy(targetPosition);
         axis.x = flatDirection.y;
         axis.y = -flatDirection.x;
         flatDirection.reverse();
         rotationMatrix.fromAxisAngle(axis,-actualElevation);
         rotationMatrix.transformVector(flatDirection,rayDirection);
         var cameraCollisionPosition:Vector3 = this.getCameraCollisionPosition(rayOrigin,rayDirection,this.cameraDistance);
         var distance:Number = cameraCollisionPosition.clone().subtract(targetPosition).length();
         if(distance < MIN_DISTANCE)
         {
            rayOrigin.copy(cameraCollisionPosition);
            rayDirection.copy(Vector3.Z_AXIS);
            cameraCollisionPosition = this.getCameraCollisionPosition(rayOrigin,rayDirection,MIN_DISTANCE - distance);
         }
         if(this.startMarker != null)
         {
            this.startMarker.x = targetPosition.x;
            this.startMarker.y = targetPosition.y;
            this.startMarker.z = targetPosition.z;
            this.endMarker.x = cameraCollisionPosition.x;
            this.endMarker.y = cameraCollisionPosition.y;
            this.endMarker.z = cameraCollisionPosition.z;
         }
         result.position.copy(cameraCollisionPosition);
      }
      
      private function getCameraCollisionPosition(rayOrigin:Vector3, rayDirection:Vector3, rayLength:Number) : Vector3
      {
         var offset:Number = NaN;
         this.rayOrigin3D.x = rayOrigin.x;
         this.rayOrigin3D.y = rayOrigin.y;
         this.rayOrigin3D.z = rayOrigin.z;
         this.rayDirection3D.x = rayDirection.x;
         this.rayDirection3D.y = rayDirection.y;
         this.rayDirection3D.z = rayDirection.z;
         this.displacement.x = rayDirection.x * rayLength;
         this.displacement.y = rayDirection.y * rayLength;
         this.displacement.z = rayDirection.z * rayLength;
         if(this.collider.getCollision(this.rayOrigin3D,this.displacement,this.collisionPoint,this.collisionNormal,this.collisionObject,this.collisionFilter))
         {
            offset = this.collider.radiusX + 0.1;
            this.v.x = this.collisionPoint.x + this.collisionNormal.x * offset;
            this.v.y = this.collisionPoint.y + this.collisionNormal.y * offset;
            this.v.z = this.collisionPoint.z + this.collisionNormal.z * offset;
         }
         else
         {
            this.v.x = this.rayOrigin3D.x + this.displacement.x;
            this.v.y = this.rayOrigin3D.y + this.displacement.y;
            this.v.z = this.rayOrigin3D.z + this.displacement.z;
         }
         return this.v;
      }
      
      private function onKey(e:KeyboardEvent) : void
      {
         if(KEYS_CAMERA_DOWN.indexOf(e.keyCode) >= 0)
         {
            this.keyDownPressed = e.type == KeyboardEvent.KEY_DOWN;
         }
         else if(KEYS_CAMERA_UP.indexOf(e.keyCode) >= 0)
         {
            this.keyUpPressed = e.type == KeyboardEvent.KEY_DOWN;
         }
      }
      
      private function updateCameraHeight(dt:Number) : void
      {
         var heightChangeDir:int = 0;
         if(!this.inputLocked && this.keyUpPressed != this.keyDownPressed)
         {
            heightChangeDir = !!this.keyUpPressed ? int(1) : int(-1);
            this.setCameraT(this.getCameraT() + heightChangeDir * 0.4 * dt);
         }
      }
      
      private function getLinearSpeed(positionError:Number) : Number
      {
         return 3 * positionError;
      }
      
      private function getAngularSpeed(angleError:Number, currentSpeed:Number) : Number
      {
         var k:Number = 3;
         if(angleError < -maxAngleError)
         {
            return k * (angleError + maxAngleError);
         }
         if(angleError > maxAngleError)
         {
            return k * (angleError - maxAngleError);
         }
         return currentSpeed;
      }
      
      private function getPitchAngle(cameraPositionData:CameraPositionData) : Number
      {
         var angle:Number = this.baseElevation - 10 * Math.PI / 180;
         if(angle < 0)
         {
            angle = 0;
         }
         return cameraPositionData.extraPitch - angle;
      }
   }
}
