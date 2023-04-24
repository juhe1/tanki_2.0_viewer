package alternativa.physics
{
   import alternativa.math.Matrix3;
   import alternativa.math.Matrix4;
   import alternativa.math.Quaternion;
   import alternativa.math.Vector3;
   import alternativa.physics.collision.CollisionPrimitive;
   import alternativa.physics.collision.IBodyCollisionFilter;
   import alternativa.physics.collision.types.AABB;
   
   public class Body
   {
      
      public static var linearDamping:Number = 0.997;
      
      public static var rotationalDamping:Number = 0.997;
      
      private static const _r:Vector3 = new Vector3();
      
      private static const _f:Vector3 = new Vector3();
      
      private static const MAX_CONTACTS:int = 20;
       
      
      public var id:int;
      
      public var data:Object;
      
      public var scene:PhysicsScene;
      
      public var movable:Boolean = true;
      
      public var canFreeze:Boolean = false;
      
      public var freezeCounter:int;
      
      public var frozen:Boolean = false;
      
      public var aabb:AABB;
      
      public var postCollisionFilter:IBodyCollisionFilter;
      
      public var acceleration:Vector3;
      
      public var angularAcceleration:Vector3;
      
      public var prevState:BodyState;
      
      public var invMass:Number = 1;
      
      public var invInertia:Matrix3;
      
      public var invInertiaWorld:Matrix3;
      
      public var baseMatrix:Matrix3;
      
      public var state:BodyState;
      
      public var contacts:Vector.<Contact>;
      
      public var numContacts:int;
      
      public var collisionPrimitives:Vector.<CollisionPrimitive>;
      
      public var numCollisionPrimitives:int;
      
      public var forceAccum:Vector3;
      
      public var torqueAccum:Vector3;
      
      public function Body(invMass:Number, invInertia:Matrix3)
      {
         this.aabb = new AABB();
         this.acceleration = new Vector3();
         this.angularAcceleration = new Vector3();
         this.prevState = new BodyState();
         this.invInertia = new Matrix3();
         this.invInertiaWorld = new Matrix3();
         this.baseMatrix = new Matrix3();
         this.state = new BodyState();
         this.contacts = new Vector.<Contact>(MAX_CONTACTS);
         this.forceAccum = new Vector3();
         this.torqueAccum = new Vector3();
         super();
         this.invMass = invMass;
         this.invInertia.copy(invInertia);
      }
      
      public function removeCollisionData() : void
      {
         this.numCollisionPrimitives = 0;
         this.collisionPrimitives = null;
      }
      
      public function addCollisionPrimitive(primitive:CollisionPrimitive, localTransform:Matrix4 = null) : void
      {
         if(primitive == null)
         {
            throw new ArgumentError("Parameter is null");
         }
         if(this.collisionPrimitives == null)
         {
            this.collisionPrimitives = new Vector.<CollisionPrimitive>();
            this.numCollisionPrimitives = 0;
         }
         this.collisionPrimitives.push(primitive);
         this.numCollisionPrimitives = this.collisionPrimitives.length;
         primitive.setBody(this,localTransform);
      }
      
      public function removeCollisionPrimitive(primitive:CollisionPrimitive) : void
      {
         var i:int = 0;
         if(this.collisionPrimitives != null)
         {
            if(this.numCollisionPrimitives > 0)
            {
               i = this.collisionPrimitives.indexOf(primitive);
               if(i >= 0)
               {
                  primitive.setBody(null);
                  this.collisionPrimitives[i] = this.collisionPrimitives[--this.numCollisionPrimitives];
                  if(this.numCollisionPrimitives == 0)
                  {
                     this.collisionPrimitives = null;
                  }
                  else
                  {
                     this.collisionPrimitives.length = this.numCollisionPrimitives;
                  }
               }
            }
         }
      }
      
      public function interpolate(t:Number, pos:Vector3, orientation:Quaternion) : void
      {
         var t1:Number = NaN;
         t1 = 1 - t;
         pos.x = this.prevState.position.x * t1 + this.state.position.x * t;
         pos.y = this.prevState.position.y * t1 + this.state.position.y * t;
         pos.z = this.prevState.position.z * t1 + this.state.position.z * t;
         orientation.w = this.prevState.orientation.w * t1 + this.state.orientation.w * t;
         orientation.x = this.prevState.orientation.x * t1 + this.state.orientation.x * t;
         orientation.y = this.prevState.orientation.y * t1 + this.state.orientation.y * t;
         orientation.z = this.prevState.orientation.z * t1 + this.state.orientation.z * t;
      }
      
      public function setPosition(pos:Vector3) : void
      {
         this.state.position.copy(pos);
      }
      
      public function setPositionXYZ(x:Number, y:Number, z:Number) : void
      {
         this.state.position.reset(x,y,z);
      }
      
      public function setVelocity(vel:Vector3) : void
      {
         this.state.velocity.copy(vel);
      }
      
      public function setVelocityXYZ(x:Number, y:Number, z:Number) : void
      {
         this.state.velocity.reset(x,y,z);
      }
      
      public function setRotation(rot:Vector3) : void
      {
         this.state.angularVelocity.copy(rot);
      }
      
      public function setRotationXYZ(x:Number, y:Number, z:Number) : void
      {
         this.state.angularVelocity.reset(x,y,z);
      }
      
      public function setOrientation(q:Quaternion) : void
      {
         this.state.orientation.copy(q);
      }
      
      public function applyRelPosWorldImpulse(r:Vector3, dir:Vector3, magnitude:Number) : void
      {
         var x:Number = NaN;
         var y:Number = NaN;
         var d:Number = magnitude * this.invMass;
         this.state.velocity.x += d * dir.x;
         this.state.velocity.y += d * dir.y;
         this.state.velocity.z += d * dir.z;
         x = (r.y * dir.z - r.z * dir.y) * magnitude;
         y = (r.z * dir.x - r.x * dir.z) * magnitude;
         var z:Number = (r.x * dir.y - r.y * dir.x) * magnitude;
         this.state.angularVelocity.x += this.invInertiaWorld.a * x + this.invInertiaWorld.b * y + this.invInertiaWorld.c * z;
         this.state.angularVelocity.y += this.invInertiaWorld.e * x + this.invInertiaWorld.f * y + this.invInertiaWorld.g * z;
         this.state.angularVelocity.z += this.invInertiaWorld.i * x + this.invInertiaWorld.j * y + this.invInertiaWorld.k * z;
      }
      
      public function applyImpulse(dir:Vector3, magnitude:Number) : void
      {
         var d:Number = magnitude * this.invMass;
         this.state.velocity.x += d * dir.x;
         this.state.velocity.y += d * dir.y;
         this.state.velocity.z += d * dir.z;
      }
      
      public function addForce(f:Vector3) : void
      {
         this.forceAccum.add(f);
      }
      
      public function addForceXYZ(fx:Number, fy:Number, fz:Number) : void
      {
         this.forceAccum.x += fx;
         this.forceAccum.y += fy;
         this.forceAccum.z += fz;
      }
      
      public function addWorldForceXYZ(px:Number, py:Number, pz:Number, fx:Number, fy:Number, fz:Number) : void
      {
         var ry:Number = NaN;
         this.forceAccum.x += fx;
         this.forceAccum.y += fy;
         this.forceAccum.z += fz;
         var pos:Vector3 = this.state.position;
         var rx:Number = px - pos.x;
         ry = py - pos.y;
         var rz:Number = pz - pos.z;
         this.torqueAccum.x += ry * fz - rz * fy;
         this.torqueAccum.y += rz * fx - rx * fz;
         this.torqueAccum.z += rx * fy - ry * fx;
      }
      
      public function addWorldForce(pos:Vector3, force:Vector3) : void
      {
         this.forceAccum.add(force);
         this.torqueAccum.add(_r.diff(pos,this.state.position).cross(force));
      }
      
      public function addWorldForceScaled(pos:Vector3, force:Vector3, scale:Number) : void
      {
         _f.x = scale * force.x;
         _f.y = scale * force.y;
         _f.z = scale * force.z;
         this.forceAccum.add(_f);
         this.torqueAccum.add(_r.diff(pos,this.state.position).cross(_f));
      }
      
      public function addLocalForce(pos:Vector3, force:Vector3) : void
      {
         this.baseMatrix.transformVector(pos,_r);
         this.baseMatrix.transformVector(force,_f);
         this.forceAccum.add(_f);
         this.torqueAccum.add(_r.cross(_f));
      }
      
      public function addWorldForceAtLocalPoint(localPos:Vector3, worldForce:Vector3) : void
      {
         this.baseMatrix.transformVector(localPos,_r);
         this.forceAccum.add(worldForce);
         this.torqueAccum.add(_r.cross(worldForce));
      }
      
      public function addTorque(t:Vector3) : void
      {
         this.torqueAccum.add(t);
      }
      
      public function clearAccumulators() : void
      {
         this.forceAccum.x = this.forceAccum.y = this.forceAccum.z = 0;
         this.torqueAccum.x = this.torqueAccum.y = this.torqueAccum.z = 0;
      }
      
      public function calcAccelerations() : void
      {
         this.acceleration.x = this.forceAccum.x * this.invMass;
         this.acceleration.y = this.forceAccum.y * this.invMass;
         this.acceleration.z = this.forceAccum.z * this.invMass;
         this.angularAcceleration.x = this.invInertiaWorld.a * this.torqueAccum.x + this.invInertiaWorld.b * this.torqueAccum.y + this.invInertiaWorld.c * this.torqueAccum.z;
         this.angularAcceleration.y = this.invInertiaWorld.e * this.torqueAccum.x + this.invInertiaWorld.f * this.torqueAccum.y + this.invInertiaWorld.g * this.torqueAccum.z;
         this.angularAcceleration.z = this.invInertiaWorld.i * this.torqueAccum.x + this.invInertiaWorld.j * this.torqueAccum.y + this.invInertiaWorld.k * this.torqueAccum.z;
      }
      
      public function calcDerivedData() : void
      {
         var i:int = 0;
         var primitive:CollisionPrimitive = null;
         this.state.orientation.toMatrix3(this.baseMatrix);
         this.invInertiaWorld.copy(this.invInertia).append(this.baseMatrix).prependTransposed(this.baseMatrix);
         if(this.collisionPrimitives != null)
         {
            this.aabb.infinity();
            for(i = 0; i < this.numCollisionPrimitives; i++)
            {
               primitive = this.collisionPrimitives[i];
               primitive.transform.setFromMatrix3(this.baseMatrix,this.state.position);
               if(primitive.localTransform != null)
               {
                  primitive.transform.prepend(primitive.localTransform);
               }
               primitive.calculateAABB();
               this.aabb.addBoundBox(primitive.aabb);
            }
         }
      }
      
      public function saveState() : void
      {
         this.prevState.copy(this.state);
      }
      
      public function restoreState() : void
      {
         this.state.copy(this.prevState);
      }
      
      public function integrateVelocity(dt:Number) : void
      {
         this.state.velocity.x += this.acceleration.x * dt;
         this.state.velocity.y += this.acceleration.y * dt;
         this.state.velocity.z += this.acceleration.z * dt;
         this.state.angularVelocity.x += this.angularAcceleration.x * dt;
         this.state.angularVelocity.y += this.angularAcceleration.y * dt;
         this.state.angularVelocity.z += this.angularAcceleration.z * dt;
         this.state.velocity.x *= linearDamping;
         this.state.velocity.y *= linearDamping;
         this.state.velocity.z *= linearDamping;
         this.state.angularVelocity.x *= rotationalDamping;
         this.state.angularVelocity.y *= rotationalDamping;
         this.state.angularVelocity.z *= rotationalDamping;
      }
      
      public function integratePosition(dt:Number) : void
      {
         this.state.position.x += this.state.velocity.x * dt;
         this.state.position.y += this.state.velocity.y * dt;
         this.state.position.z += this.state.velocity.z * dt;
         this.state.orientation.addScaledVector(this.state.angularVelocity,dt);
      }
   }
}
