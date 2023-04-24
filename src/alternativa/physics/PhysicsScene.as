package alternativa.physics
{
   import alternativa.math.Matrix3;
   import alternativa.math.Vector3;
   import alternativa.physics.collision.CollisionDetector;
   import alternativa.physics.constraints.Constraint;
   
   public class PhysicsScene
   {
      
      private static var lastBodyId:int;
       
      
      public const MAX_CONTACTS:int = 1000;
      
      public var penResolutionSteps:int = 10;
      
      public var allowedPenetration:Number = 0.1;
      
      public var maxPenResolutionSpeed:Number = 0.5;
      
      public var collisionIterations:int = 5;
      
      public var contactIterations:int = 5;
      
      public var usePrediction:Boolean = true;
      
      public var freezeSteps:int = 10;
      
      public var linSpeedFreezeLimit:Number = 1;
      
      public var angSpeedFreezeLimit:Number = 0.01;
      
      public var _gravity:Vector3;
      
      public var _gravityMagnitude:Number = 9.8;
      
      public var collisionDetector:CollisionDetector;
      
      public var bodies:BodyList;
      
      public var contacts:Contact;
      
      public var constraints:Vector.<Constraint>;
      
      public var constraintsNum:int;
      
      public var timeStamp:int;
      
      public var time:int;
      
      private var borderContact:Contact;
      
      private var _r:Vector3;
      
      private var _t:Vector3;
      
      private var _v:Vector3;
      
      private var _v1:Vector3;
      
      private var _v2:Vector3;
      
      public function PhysicsScene()
      {
         this._gravity = new Vector3(0,0,-9.8);
         this.bodies = new BodyList();
         this.constraints = new Vector.<Constraint>();
         this._r = new Vector3();
         this._t = new Vector3();
         this._v = new Vector3();
         this._v1 = new Vector3();
         this._v2 = new Vector3();
         super();
         this.contacts = new Contact(0);
         var contact:Contact = this.contacts;
         for(var i:int = 1; i < this.MAX_CONTACTS; i++)
         {
            contact.next = new Contact(i);
            contact = contact.next;
         }
      }
      
      public function get gravity() : Vector3
      {
         return this._gravity.clone();
      }
      
      public function set gravity(value:Vector3) : void
      {
         this._gravity.copy(value);
         this._gravityMagnitude = this._gravity.length();
      }
      
      public function addBody(body:Body) : void
      {
         body.id = lastBodyId++;
         body.scene = this;
         this.bodies.append(body);
      }
      
      public function removeBody(body:Body) : void
      {
         if(this.bodies.remove(body))
         {
            body.scene = null;
         }
      }
      
      public function addConstraint(c:Constraint) : void
      {
         var _loc2_:* = this.constraintsNum++;
         this.constraints[_loc2_] = c;
         c.world = this;
      }
      
      public function removeConstraint(c:Constraint) : Boolean
      {
         var idx:int = this.constraints.indexOf(c);
         if(idx < 0)
         {
            return false;
         }
         this.constraints.splice(idx,1);
         --this.constraintsNum;
         c.world = null;
         return true;
      }
      
      private function applyForces(dt:Number) : void
      {
         var body:Body = null;
         var item:BodyListItem = this.bodies.head;
         while(item != null)
         {
            body = item.body;
            body.calcAccelerations();
            if(body.movable && !body.frozen)
            {
               body.acceleration.x += this._gravity.x;
               body.acceleration.y += this._gravity.y;
               body.acceleration.z += this._gravity.z;
            }
            item = item.next;
         }
      }
      
      private function detectCollisions(dt:Number) : void
      {
         var body:Body = null;
         var b1:Body = null;
         var b2:Body = null;
         var j:int = 0;
         var cp:ContactPoint = null;
         var bPos:Vector3 = null;
         var item:BodyListItem = this.bodies.head;
         while(item != null)
         {
            body = item.body;
            if(!body.frozen)
            {
               body.numContacts = 0;
               body.saveState();
               if(this.usePrediction && body.movable)
               {
                  body.integrateVelocity(dt);
                  body.integratePosition(dt);
               }
               body.calcDerivedData();
            }
            item = item.next;
         }
         this.borderContact = this.collisionDetector.getAllContacts(this.contacts);
         var contact:Contact = this.contacts;
         while(contact != this.borderContact)
         {
            b1 = contact.body1;
            b2 = contact.body2;
            for(j = 0; j < contact.pcount; j++)
            {
               cp = contact.points[j];
               bPos = b1.state.position;
               cp.r1.x = cp.position.x - bPos.x;
               cp.r1.y = cp.position.y - bPos.y;
               cp.r1.z = cp.position.z - bPos.z;
               if(b2 != null)
               {
                  bPos = b2.state.position;
                  cp.r2.x = cp.position.x - bPos.x;
                  cp.r2.y = cp.position.y - bPos.y;
                  cp.r2.z = cp.position.z - bPos.z;
               }
            }
            contact = contact.next;
         }
         if(this.usePrediction)
         {
            item = this.bodies.head;
            while(item != null)
            {
               body = item.body;
               if(!body.frozen && body.movable)
               {
                  body.restoreState();
                  body.calcDerivedData();
               }
               item = item.next;
            }
         }
      }
      
      private function preProcessContacts(dt:Number) : void
      {
         var b1:Body = null;
         var b2:Body = null;
         var j:int = 0;
         var cp:ContactPoint = null;
         var constraint:Constraint = null;
         var contact:Contact = this.contacts;
         while(contact != this.borderContact)
         {
            b1 = contact.body1;
            b2 = contact.body2;
            if(b1.frozen)
            {
               b1.frozen = false;
               b1.freezeCounter = 0;
            }
            if(b2 != null && b2.frozen)
            {
               b2.frozen = false;
               b2.freezeCounter = 0;
            }
            for(j = 0; j < contact.pcount; j++)
            {
               cp = contact.points[j];
               cp.precalculcate();
               cp.accumImpulseN = 0;
               cp.velByUnitImpulseN = 0;
               if(b1.movable)
               {
                  cp.angularInertia1 = this._v.cross2(cp.r1,contact.normal).transform3(b1.invInertiaWorld).cross(cp.r1).dot(contact.normal);
                  cp.velByUnitImpulseN += b1.invMass + cp.angularInertia1;
               }
               if(b2 != null && b2.movable)
               {
                  cp.angularInertia2 = this._v.cross2(cp.r2,contact.normal).transform3(b2.invInertiaWorld).cross(cp.r2).dot(contact.normal);
                  cp.velByUnitImpulseN += b2.invMass + cp.angularInertia2;
               }
               this.calcSepVelocity(b1,b2,cp,this._v);
               cp.normalVel = this._v.dot(contact.normal);
               if(cp.normalVel < 0)
               {
                  cp.normalVel = -cp.restitution * cp.normalVel;
               }
               cp.minSepVel = cp.penetration > this.allowedPenetration ? Number((cp.penetration - this.allowedPenetration) / (this.penResolutionSteps * dt)) : Number(0);
               if(cp.minSepVel > this.maxPenResolutionSpeed)
               {
                  cp.minSepVel = this.maxPenResolutionSpeed;
               }
            }
            contact = contact.next;
         }
         for(var i:int = 0; i < this.constraintsNum; i++)
         {
            constraint = this.constraints[i];
            constraint.preProcess(dt);
         }
      }
      
      private function processContacts(dt:Number, forceInelastic:Boolean) : void
      {
         var i:int = 0;
         var contact:Contact = null;
         var constraint:Constraint = null;
         var iterNum:int = !!forceInelastic ? int(this.contactIterations) : int(this.collisionIterations);
         var forwardLoop:Boolean = false;
         for(var iter:int = 0; iter < iterNum; iter++)
         {
            forwardLoop = !forwardLoop;
            contact = this.contacts;
            while(contact != this.borderContact)
            {
               this.resolveContact(contact,forceInelastic,forwardLoop);
               contact = contact.next;
            }
            for(i = 0; i < this.constraintsNum; i++)
            {
               constraint = this.constraints[i];
               constraint.apply(dt);
            }
         }
      }
      
      private function resolveContact(contactInfo:Contact, forceInelastic:Boolean, forwardLoop:Boolean) : void
      {
         var i:int = 0;
         var b1:Body = contactInfo.body1;
         var b2:Body = contactInfo.body2;
         var normal:Vector3 = contactInfo.normal;
         if(forwardLoop)
         {
            for(i = 0; i < contactInfo.pcount; i++)
            {
               this.resolveContactPoint(i,b1,b2,contactInfo,normal,forceInelastic);
            }
         }
         else
         {
            for(i = contactInfo.pcount - 1; i >= 0; i--)
            {
               this.resolveContactPoint(i,b1,b2,contactInfo,normal,forceInelastic);
            }
         }
      }
      
      private function resolveContactPoint(idx:int, b1:Body, b2:Body, contact:Contact, normal:Vector3, forceInelastic:Boolean) : void
      {
         var r:Vector3 = null;
         var m:Matrix3 = null;
         var xx:Number = NaN;
         var yy:Number = NaN;
         var zz:Number = NaN;
         var minSpeVel:Number = NaN;
         var cp:ContactPoint = contact.points[idx];
         if(!forceInelastic)
         {
            cp.satisfied = true;
         }
         var newVel:Number = 0;
         this.calcSepVelocity(b1,b2,cp,this._v);
         var cnormal:Vector3 = contact.normal;
         var sepVel:Number = this._v.x * cnormal.x + this._v.y * cnormal.y + this._v.z * cnormal.z;
         if(forceInelastic)
         {
            minSpeVel = cp.minSepVel;
            if(sepVel < minSpeVel)
            {
               cp.satisfied = false;
            }
            else if(cp.satisfied)
            {
               return;
            }
            newVel = minSpeVel;
         }
         else
         {
            newVel = cp.normalVel;
         }
         var deltaVel:Number = newVel - sepVel;
         var impulse:Number = deltaVel / cp.velByUnitImpulseN;
         var accumImpulse:Number = cp.accumImpulseN + impulse;
         if(accumImpulse < 0)
         {
            accumImpulse = 0;
         }
         var deltaImpulse:Number = accumImpulse - cp.accumImpulseN;
         cp.accumImpulseN = accumImpulse;
         if(b1.movable)
         {
            b1.applyRelPosWorldImpulse(cp.r1,normal,deltaImpulse);
         }
         if(b2 != null && b2.movable)
         {
            b2.applyRelPosWorldImpulse(cp.r2,normal,-deltaImpulse);
         }
         this.calcSepVelocity(b1,b2,cp,this._v);
         var tanSpeedByUnitImpulse:Number = 0;
         var dot:Number = this._v.x * cnormal.x + this._v.y * cnormal.y + this._v.z * cnormal.z;
         this._v.x -= dot * cnormal.x;
         this._v.y -= dot * cnormal.y;
         this._v.z -= dot * cnormal.z;
         var tanSpeed:Number = this._v.length();
         if(tanSpeed < 0.001)
         {
            return;
         }
         this._t.x = -this._v.x;
         this._t.y = -this._v.y;
         this._t.z = -this._v.z;
         this._t.normalize();
         if(b1.movable)
         {
            r = cp.r1;
            m = b1.invInertiaWorld;
            this._v.x = r.y * this._t.z - r.z * this._t.y;
            this._v.y = r.z * this._t.x - r.x * this._t.z;
            this._v.z = r.x * this._t.y - r.y * this._t.x;
            xx = m.a * this._v.x + m.b * this._v.y + m.c * this._v.z;
            yy = m.e * this._v.x + m.f * this._v.y + m.g * this._v.z;
            zz = m.i * this._v.x + m.j * this._v.y + m.k * this._v.z;
            this._v.x = yy * r.z - zz * r.y;
            this._v.y = zz * r.x - xx * r.z;
            this._v.z = xx * r.y - yy * r.x;
            tanSpeedByUnitImpulse += b1.invMass + this._v.x * this._t.x + this._v.y * this._t.y + this._v.z * this._t.z;
         }
         if(b2 != null && b2.movable)
         {
            r = cp.r2;
            m = b2.invInertiaWorld;
            this._v.x = r.y * this._t.z - r.z * this._t.y;
            this._v.y = r.z * this._t.x - r.x * this._t.z;
            this._v.z = r.x * this._t.y - r.y * this._t.x;
            xx = m.a * this._v.x + m.b * this._v.y + m.c * this._v.z;
            yy = m.e * this._v.x + m.f * this._v.y + m.g * this._v.z;
            zz = m.i * this._v.x + m.j * this._v.y + m.k * this._v.z;
            this._v.x = yy * r.z - zz * r.y;
            this._v.y = zz * r.x - xx * r.z;
            this._v.z = xx * r.y - yy * r.x;
            tanSpeedByUnitImpulse += b2.invMass + this._v.x * this._t.x + this._v.y * this._t.y + this._v.z * this._t.z;
         }
         var tanImpulse:Number = tanSpeed / tanSpeedByUnitImpulse;
         var max:Number = cp.friction * cp.accumImpulseN;
         if(max < 0)
         {
            if(tanImpulse < max)
            {
               tanImpulse = max;
            }
         }
         else if(tanImpulse > max)
         {
            tanImpulse = max;
         }
         if(b1.movable)
         {
            b1.applyRelPosWorldImpulse(cp.r1,this._t,tanImpulse);
         }
         if(b2 != null && b2.movable)
         {
            b2.applyRelPosWorldImpulse(cp.r2,this._t,-tanImpulse);
         }
      }
      
      private function calcSepVelocity(body1:Body, body2:Body, cp:ContactPoint, result:Vector3) : void
      {
         var rot:Vector3 = body1.state.angularVelocity;
         var v:Vector3 = cp.r1;
         var x:Number = rot.y * v.z - rot.z * v.y;
         var y:Number = rot.z * v.x - rot.x * v.z;
         var z:Number = rot.x * v.y - rot.y * v.x;
         v = body1.state.velocity;
         result.x = v.x + x;
         result.y = v.y + y;
         result.z = v.z + z;
         if(body2 != null)
         {
            rot = body2.state.angularVelocity;
            v = cp.r2;
            x = rot.y * v.z - rot.z * v.y;
            y = rot.z * v.x - rot.x * v.z;
            z = rot.x * v.y - rot.y * v.x;
            v = body2.state.velocity;
            result.x -= v.x + x;
            result.y -= v.y + y;
            result.z -= v.z + z;
         }
      }
      
      private function intergateVelocities(dt:Number) : void
      {
         var item:BodyListItem = this.bodies.head;
         while(item != null)
         {
            item.body.integrateVelocity(dt);
            item = item.next;
         }
      }
      
      private function integratePositions(dt:Number) : void
      {
         var body:Body = null;
         var item:BodyListItem = this.bodies.head;
         while(item != null)
         {
            body = item.body;
            if(body.movable && !body.frozen)
            {
               body.integratePosition(dt);
            }
            item = item.next;
         }
      }
      
      private function postPhysics() : void
      {
         var body:Body = null;
         var item:BodyListItem = this.bodies.head;
         while(item != null)
         {
            body = item.body;
            body.clearAccumulators();
            body.calcDerivedData();
            if(body.canFreeze)
            {
               if(body.state.velocity.length() < this.linSpeedFreezeLimit && body.state.angularVelocity.length() < this.angSpeedFreezeLimit)
               {
                  if(!body.frozen)
                  {
                     ++body.freezeCounter;
                     if(body.freezeCounter >= this.freezeSteps)
                     {
                        body.frozen = true;
                     }
                  }
               }
               else
               {
                  body.freezeCounter = 0;
                  body.frozen = false;
               }
            }
            item = item.next;
         }
      }
      
      public function update(delta:int) : void
      {
         ++this.timeStamp;
         this.time += delta;
         var dt:Number = delta / 1000;
         this.applyForces(dt);
         this.detectCollisions(dt);
         this.preProcessContacts(dt);
         this.processContacts(dt,false);
         this.intergateVelocities(dt);
         this.processContacts(dt,true);
         this.integratePositions(dt);
         this.postPhysics();
      }
   }
}
