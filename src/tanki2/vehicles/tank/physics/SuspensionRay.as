package tanki2.vehicles.tank.physics
{
   import alternativa.math.Matrix3;
   import alternativa.math.Vector3;
   import alternativa.physics.BodyState;
   import alternativa.physics.collision.types.RayHit;
   
   public class SuspensionRay
   {
       
      
      public var collisionGroup:int;
      
      public var _track:Track;
      
      private var relPos:Vector3;
      
      private var relDir:Vector3;
      
      public var worldPos:Vector3;
      
      public var worldDir:Vector3;
      
      public var lastCollided:Boolean = false;
      
      public var lastIntersection:RayHit;
      
      private var prevDisplacement:Number = 100;
      
      private var predicate:RayPredicate;
      
      private var dynamicFriction:Number = 0;
      
      private var sideFriction:Number = 0;
      
      private var powerCoeff:Number = 0;
      
      private var inner:Boolean;
      
      public var speed:Number;
      
      public function SuspensionRay(track:Track, relPos:Vector3, relDir:Vector3, collisionGroup:int)
      {
         this.worldPos = new Vector3();
         this.worldDir = new Vector3();
         this.lastIntersection = new RayHit();
         super();
         this._track = track;
         this.relPos = relPos.clone();
         this.relDir = relDir.clone();
         this.collisionGroup = collisionGroup;
         this.predicate = new RayPredicate(track._chassis);
      }
      
      public function updateCachedValues(rayIndex:int, numRays:int) : void
      {
         var chassis:Chassis = this._track._chassis;
         var moveDirection:int = chassis._moveDirection;
         var turnDirection:int = chassis._turnDirection;
         var pData:TankPhysicsData = chassis._currentProfile;
         var mid:Number = 0.5 * (numRays - 1);
         if(moveDirection == 0)
         {
            if(turnDirection == 0)
            {
               this.powerCoeff = 0;
               this.sideFriction = pData.sideFriction;
               this.dynamicFriction = pData.dynamicFriction;
            }
            else
            {
               if(turnDirection < 0 && this.relPos.x < 0 || turnDirection > 0 && this.relPos.x > 0)
               {
                  this.powerCoeff = -pData.spotTurnPowerCoeff;
               }
               else
               {
                  this.powerCoeff = pData.spotTurnPowerCoeff;
               }
               if(rayIndex <= mid)
               {
                  this.sideFriction = pData.spotTurnSideFriction * rayIndex / mid;
               }
               else
               {
                  this.sideFriction = pData.spotTurnSideFriction * (numRays - rayIndex - 1) / mid;
               }
               this.dynamicFriction = pData.spotTurnDynamicFriction;
            }
         }
         else if(turnDirection == 0)
         {
            if(moveDirection < 0)
            {
               this.powerCoeff = -1;
            }
            else
            {
               this.powerCoeff = 1;
            }
            this.sideFriction = pData.sideFriction;
            this.dynamicFriction = pData.dynamicFriction;
         }
         else
         {
            if(turnDirection < 0 && this.relPos.x < 0 || turnDirection > 0 && this.relPos.x > 0)
            {
               this.inner = true;
               this.powerCoeff = pData.moveTurnPowerCoeffInner;
               this.dynamicFriction = pData.moveTurnDynamicFrictionInner;
            }
            else
            {
               this.inner = false;
               this.powerCoeff = pData.moveTurnPowerCoeffOuter;
               this.dynamicFriction = pData.moveTurnDynamicFrictionOuter;
            }
            if(moveDirection < 0)
            {
               this.powerCoeff = -this.powerCoeff;
            }
            if(moveDirection > 0)
            {
               if(rayIndex <= mid)
               {
                  this.sideFriction = pData.moveTurnSideFriction * rayIndex / mid;
               }
               else
               {
                  this.sideFriction = pData.moveTurnSideFriction;
               }
            }
            else if(rayIndex <= mid)
            {
               this.sideFriction = pData.moveTurnSideFriction;
            }
            else
            {
               this.sideFriction = pData.moveTurnSideFriction * (numRays - rayIndex - 1) / mid;
            }
         }
      }
      
      public function calculateIntersection() : Boolean
      {
         var chassis:Chassis = this._track._chassis;
         var m:Matrix3 = this._track._chassis.baseMatrix;
         m.transformVector(this.relDir,this.worldDir);
         m.transformVector(this.relPos,this.worldPos);
         var p:Vector3 = chassis.state.position;
         this.worldPos.x += p.x;
         this.worldPos.y += p.y;
         this.worldPos.z += p.z;
         if(this.lastCollided)
         {
            this.prevDisplacement = this._track._rayRestLength - this.lastIntersection.t;
         }
         this.lastCollided = chassis.scene.collisionDetector.raycast(this.worldPos, this.worldDir, this.collisionGroup, this._track._rayRestLength, this.predicate, this.lastIntersection);
         if(!this.lastCollided)
         {
            this.speed = 0;
         }
         return this.lastCollided;
      }
      
      public function addForce(dt:Number, springCoeff:Number, power:Number) : void
      {
         var fx:Number = NaN;
         var fy:Number = NaN;
         var fz:Number = NaN;
         var slipSpeed:Number = NaN;
         var smallVelocity:Number = NaN;
         var frictionForce:Number = NaN;
         var friction:Number = NaN;
         var k:Number = NaN;
         if(!this.lastCollided)
         {
            this.speed = 0;
            return;
         }
         var chassis:Chassis = this._track._chassis;
         power *= this.powerCoeff;
         var pData:TankPhysicsData = chassis._currentProfile;
         var rot:Vector3 = chassis.state.angularVelocity;
         var globalMatrix:Matrix3 = chassis.baseMatrix;
         var turnSpeed:Number = rot.x * globalMatrix.c + rot.y * globalMatrix.g + rot.z * globalMatrix.k;
         var grndUpX:Number = this.lastIntersection.normal.x;
         var grndUpY:Number = this.lastIntersection.normal.y;
         var grndUpZ:Number = this.lastIntersection.normal.z;
         var x:Number = globalMatrix.b;
         var y:Number = globalMatrix.f;
         var z:Number = globalMatrix.j;
         var grndRightX:Number = y * grndUpZ - z * grndUpY;
         var grndRightY:Number = z * grndUpX - x * grndUpZ;
         var grndRightZ:Number = x * grndUpY - y * grndUpX;
         var len:Number = grndRightX * grndRightX + grndRightY * grndRightY + grndRightZ * grndRightZ;
         if(len == 0)
         {
            grndRightX = globalMatrix.a;
            grndRightY = globalMatrix.e;
            grndRightZ = globalMatrix.i;
         }
         else
         {
            len = 1 / Math.sqrt(len);
            grndRightX *= len;
            grndRightY *= len;
            grndRightZ *= len;
         }
         var grndFwdX:Number = grndUpY * grndRightZ - grndUpZ * grndRightY;
         var grndFwdY:Number = grndUpZ * grndRightX - grndUpX * grndRightZ;
         var grndFwdZ:Number = grndUpX * grndRightY - grndUpY * grndRightX;
         var state:BodyState = chassis.state;
         x = this.lastIntersection.position.x - state.position.x;
         y = this.lastIntersection.position.y - state.position.y;
         z = this.lastIntersection.position.z - state.position.z;
         var relVelX:Number = rot.y * z - rot.z * y + state.velocity.x;
         var relVelY:Number = rot.z * x - rot.x * z + state.velocity.y;
         var relVelZ:Number = rot.x * y - rot.y * x + state.velocity.z;
         if(this.lastIntersection.primitive.body != null)
         {
            state = this.lastIntersection.primitive.body.state;
            x = this.lastIntersection.position.x - state.position.x;
            y = this.lastIntersection.position.y - state.position.y;
            z = this.lastIntersection.position.z - state.position.z;
            rot = state.angularVelocity;
            relVelX -= rot.y * z - rot.z * y + state.velocity.x;
            relVelY -= rot.z * x - rot.x * z + state.velocity.y;
            relVelZ -= rot.x * y - rot.y * x + state.velocity.z;
         }
         var relSpeed:Number = Math.sqrt(relVelX * relVelX + relVelY * relVelY + relVelZ * relVelZ);
         var fwdSpeed:Number = relVelX * grndFwdX + relVelY * grndFwdY + relVelZ * grndFwdZ;
         this.speed = fwdSpeed;
         var drivingForceOffsetZ:Number = pData.drivingForceOffsetZ;
         var moveDirection:int = this._track._chassis._moveDirection;
         var turnDirection:int = this._track._chassis._turnDirection;
         var worldUpX:Number = chassis.baseMatrix.c;
         var worldUpY:Number = chassis.baseMatrix.g;
         var worldUpZ:Number = chassis.baseMatrix.k;
         var t:Number = this.lastIntersection.t;
         var currDisplacement:Number = this._track._rayRestLength - t;
         var springForce:Number = springCoeff * currDisplacement * (worldUpX * this.lastIntersection.normal.x + worldUpY * this.lastIntersection.normal.y + worldUpZ * this.lastIntersection.normal.z);
         var upSpeed:Number = (currDisplacement - this.prevDisplacement) / dt;
         springForce += upSpeed * pData.springDamping;
         if(springForce < 0)
         {
            springForce = 0;
         }
         fx = -springForce * this.worldDir.x;
         fy = -springForce * this.worldDir.y;
         fz = -springForce * this.worldDir.z;
         if(relSpeed > 0.001)
         {
            slipSpeed = relVelX * grndRightX + relVelY * grndRightY + relVelZ * grndRightZ;
            smallVelocity = pData.smallVelocity;
            frictionForce = this.sideFriction * springForce * slipSpeed / relSpeed;
            if(slipSpeed > -smallVelocity && slipSpeed < smallVelocity)
            {
               frictionForce *= slipSpeed / smallVelocity;
               if(slipSpeed < 0)
               {
                  frictionForce = -frictionForce;
               }
            }
            fx -= frictionForce * grndRightX;
            fy -= frictionForce * grndRightY;
            fz -= frictionForce * grndRightZ;
            if(fwdSpeed <= 0 && power >= 0 || fwdSpeed >= 0 && power <= 0)
            {
               friction = pData.brakeFriction;
            }
            else
            {
               friction = this.dynamicFriction;
            }
            frictionForce = friction * springForce * fwdSpeed / relSpeed;
            if(fwdSpeed > -smallVelocity && fwdSpeed < smallVelocity)
            {
               frictionForce *= fwdSpeed / smallVelocity;
               if(fwdSpeed < 0)
               {
                  frictionForce = -frictionForce;
               }
            }
            fx -= frictionForce * grndFwdX;
            fy -= frictionForce * grndFwdY;
            fz -= frictionForce * grndFwdZ;
         }
         x = this.worldPos.x + drivingForceOffsetZ * this.worldDir.x;
         y = this.worldPos.y + drivingForceOffsetZ * this.worldDir.y;
         z = this.worldPos.z + drivingForceOffsetZ * this.worldDir.z;
         if(moveDirection == 0)
         {
            if(turnDirection < 0 && turnSpeed > pData.maxTurnSpeed || turnDirection > 0 && turnSpeed < -pData.maxTurnSpeed)
            {
               power *= 0.1;
            }
         }
         else
         {
            if(turnDirection == 0)
            {
               k = 1;
            }
            else
            {
               k = !!this.inner ? Number(pData.moveTurnSpeedCoeffInner) : Number(pData.moveTurnSpeedCoeffOuter);
            }
            if(power > 0 && fwdSpeed > k * pData.maxForwardSpeed || power < 0 && -fwdSpeed > k * pData.maxBackwardSpeed)
            {
               power *= 0.1;
            }
         }
         fx += power * grndFwdX;
         fy += power * grndFwdY;
         fz += power * grndFwdZ;
         chassis.addWorldForceXYZ(x,y,z,fx,fy,fz);
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
