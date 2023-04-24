package tanki2.physics
{
   import alternativa.math.Vector3;
   import alternativa.physics.Body;
   import alternativa.physics.Contact;
   import alternativa.physics.ContactPoint;
   import alternativa.physics.collision.CollisionDetector;
   import alternativa.physics.collision.CollisionKdNode;
   import alternativa.physics.collision.CollisionKdTree;
   import alternativa.physics.collision.CollisionPrimitive;
   import alternativa.physics.collision.ICollider;
   import alternativa.physics.collision.IRayCollisionFilter;
   import alternativa.physics.collision.colliders.BoxBoxCollider;
   import alternativa.physics.collision.colliders.BoxRectCollider;
   import alternativa.physics.collision.colliders.BoxSphereCollider;
   import alternativa.physics.collision.colliders.BoxTriangleCollider;
   import alternativa.physics.collision.types.AABB;
   import alternativa.physics.collision.types.RayHit;
   import tanki2.battle.objects.tank.TankBodyWrapper;
   
   public class TanksCollisionDetector implements CollisionDetector
   {
      
      private static const _rayHit:RayHit = new RayHit();
       
      
      public var tree:CollisionKdTree;
      
      public var wrappers:Vector.<TankBodyWrapper>;
      
      public var threshold:Number = 1.0E-4;
      
      private var colliders:Object;
      
      private const _time:MinMax = new MinMax();
      
      private const _normal:Vector3 = new Vector3();
      
      private const _o:Vector3 = new Vector3();
      
      private const _dynamicRayHit:RayHit = new RayHit();
      
      private const _rayAABB:AABB = new AABB();
      
      public var trackedBody:Body;
      
      public const touchedPrimitives:TouchedPrimitives = new TouchedPrimitives();
      
      public function TanksCollisionDetector()
      {
         this.tree = new CollisionKdTree();
         this.wrappers = new Vector.<TankBodyWrapper>();
         this.colliders = {};
         super();
         this.addCollider(CollisionPrimitive.BOX,CollisionPrimitive.BOX,new BoxBoxCollider());
         this.addCollider(CollisionPrimitive.BOX,CollisionPrimitive.RECT,new BoxRectCollider());
         this.addCollider(CollisionPrimitive.BOX,CollisionPrimitive.TRIANGLE,new BoxTriangleCollider());
         this.addCollider(CollisionPrimitive.BOX,CollisionPrimitive.SPHERE,new BoxSphereCollider());
      }
      
      public function buildKdTree(collisionPrimitives:Vector.<CollisionPrimitive>, boundBox:AABB = null) : void
      {
         this.tree.createTree(collisionPrimitives,boundBox);
      }
      
      public function addBodyWrapper(wrapper:TankBodyWrapper) : void
      {
         this.wrappers.push(wrapper);
      }
      
      public function removeBodyWrapper(wrapper:TankBodyWrapper) : void
      {
         var n:int = 0;
         var i:int = this.wrappers.indexOf(wrapper);
         if(i > -1)
         {
            n = this.wrappers.length - 1;
            this.wrappers[i] = this.wrappers[n];
            this.wrappers.length = n;
         }
      }
      
      public function getAllContacts(contact:Contact) : Contact
      {
         return this.getBodiesContacts(contact);
      }
      
      private function getBodiesContacts(contact:Contact) : Contact
      {
         var wrapper:TankBodyWrapper = null;
         var N:int = this.wrappers.length;
         for(var i:int = 0; i < N; i++)
         {
            wrapper = this.wrappers[i];
            contact = this.getContactsWithStatic(wrapper,contact);
            contact = this.getContactsWithOtherBodies(wrapper,i + 1,contact);
         }
         return contact;
      }
      
      private function getContactsWithStatic(wrapper:TankBodyWrapper, contact:Contact) : Contact
      {
         var numPrimitives:int = 0;
         var j:int = 0;
         if(!wrapper.body.frozen)
         {
            numPrimitives = wrapper.staticCollisionPrimitives.length;
            for(j = 0; j < numPrimitives; j++)
            {
               contact = this.getPrimitiveNodeCollisions(this.tree.rootNode,wrapper.staticCollisionPrimitives[j],contact);
            }
         }
         return contact;
      }
      
      private function getContactsWithOtherBodies(wrapper:TankBodyWrapper, nextIndex:int, contact:Contact) : Contact
      {
         var otherWrapper:TankBodyWrapper = null;
         var body:Body = null;
         var otherBody:Body = null;
         var N:int = this.wrappers.length;
         for(var i:int = nextIndex; i < N; i++)
         {
            otherWrapper = this.wrappers[i];
            body = wrapper.body;
            otherBody = otherWrapper.body;
            if(!(body.frozen && otherBody.frozen) && body.aabb.intersects(otherBody.aabb,0.1))
            {
               if(this.getContact(wrapper.tankCollisionBox,otherWrapper.tankCollisionBox,contact))
               {
                  if(body.postCollisionFilter == null || body.postCollisionFilter.considerBodies(body,otherBody) || otherBody.postCollisionFilter == null && otherBody.postCollisionFilter.considerBodies(otherBody,body))
                  {
                     contact = contact.next;
                  }
               }
            }
         }
         return contact;
      }
      
      public function getContact(prim1:CollisionPrimitive, prim2:CollisionPrimitive, contact:Contact) : Boolean
      {
         var pen:Number = NaN;
         var i:int = 0;
         if((prim1.collisionGroup & prim2.collisionGroup) == 0)
         {
            return false;
         }
         if(prim1.body != null && prim1.body == prim2.body)
         {
            return false;
         }
         if(!prim1.aabb.intersects(prim2.aabb,0.01))
         {
            return false;
         }
         var collider:ICollider = this.colliders[prim1.type | prim2.type];
         if(collider.getContact(prim1,prim2,contact))
         {
            if(prim1.postCollisionFilter != null && !prim1.postCollisionFilter.considerCollision(prim2))
            {
               return false;
            }
            if(prim2.postCollisionFilter != null && !prim2.postCollisionFilter.considerCollision(prim1))
            {
               return false;
            }
            contact.maxPenetration = (contact.points[0] as ContactPoint).penetration;
            for(i = contact.pcount - 1; i >= 1; i--)
            {
               if((pen = (contact.points[i] as ContactPoint).penetration) > contact.maxPenetration)
               {
                  contact.maxPenetration = pen;
               }
            }
            return true;
         }
         return false;
      }
      
      public function testCollision(prim1:CollisionPrimitive, prim2:CollisionPrimitive) : Boolean
      {
         if((prim1.collisionGroup & prim2.collisionGroup) == 0)
         {
            return false;
         }
         if(prim1.body != null && prim1.body == prim2.body)
         {
            return false;
         }
         if(!prim1.aabb.intersects(prim2.aabb,0.01))
         {
            return false;
         }
         var collider:ICollider = this.colliders[prim1.type | prim2.type];
         if(collider.haveCollision(prim1,prim2))
         {
            if(prim1.postCollisionFilter != null && !prim1.postCollisionFilter.considerCollision(prim2))
            {
               return false;
            }
            return !(prim2.postCollisionFilter != null && !prim2.postCollisionFilter.considerCollision(prim1));
         }
         return false;
      }
      
      public function raycast(origin:Vector3, dir:Vector3, collisionGroup:int, maxTime:Number, predicate:IRayCollisionFilter, result:RayHit) : Boolean
      {
         var hasStaticIntersection:Boolean = this.raycastStatic(origin,dir,collisionGroup,maxTime,predicate,result);
         var hasDynamicIntersection:Boolean = this.raycastDynamic(origin,dir,collisionGroup,maxTime,predicate,this._dynamicRayHit);
         if(!(hasDynamicIntersection || hasStaticIntersection))
         {
            return false;
         }
         if(hasDynamicIntersection && hasStaticIntersection)
         {
            if(result.t > this._dynamicRayHit.t)
            {
               result.copy(this._dynamicRayHit);
            }
            return true;
         }
         if(hasStaticIntersection)
         {
            return true;
         }
         result.copy(this._dynamicRayHit);
         return true;
      }
      
      public function raycastStatic(origin:Vector3, dir:Vector3, collisionGroup:int, maxTime:Number, predicate:IRayCollisionFilter, result:RayHit) : Boolean
      {
         if(!this.getRayBoundBoxIntersection(origin,dir,this.tree.rootNode.boundBox,this._time))
         {
            return false;
         }
         if(this._time.max < 0 || this._time.min > maxTime)
         {
            return false;
         }
         if(this._time.min <= 0)
         {
            this._time.min = 0;
            this._o.x = origin.x;
            this._o.y = origin.y;
            this._o.z = origin.z;
         }
         else
         {
            this._o.x = origin.x + this._time.min * dir.x;
            this._o.y = origin.y + this._time.min * dir.y;
            this._o.z = origin.z + this._time.min * dir.z;
         }
         if(this._time.max > maxTime)
         {
            this._time.max = maxTime;
         }
         var hasIntersection:Boolean = this.testRayAgainstNode(this.tree.rootNode,origin,this._o,dir,collisionGroup,this._time.min,this._time.max,predicate,result);
         return !!hasIntersection ? Boolean(result.t <= maxTime) : Boolean(false);
      }
      
      public function hasStaticHit(origin:Vector3, direction:Vector3, collisionGroup:int, maxTime:Number, predicate:IRayCollisionFilter = null) : Boolean
      {
         return this.raycastStatic(origin,direction,collisionGroup,maxTime,predicate,_rayHit);
      }
      
      private function addCollider(type1:int, type2:int, collider:ICollider) : void
      {
         this.colliders[type1 | type2] = collider;
      }
      
      private function getPrimitiveNodeCollisions(node:CollisionKdNode, primitive:CollisionPrimitive, contact:Contact) : Contact
      {
         var min:Number = NaN;
         var max:Number = NaN;
         var primitives:Vector.<CollisionPrimitive> = null;
         var indices:Vector.<int> = null;
         var i:int = 0;
         var staticPrimitive:CollisionPrimitive = null;
         if(node.indices != null)
         {
            primitives = this.tree.staticChildren;
            indices = node.indices;
            for(i = indices.length - 1; i >= 0; i--)
            {
               staticPrimitive = primitives[indices[i]];
               this.touchedPrimitives.touch(staticPrimitive);
               if(this.getContact(primitive,staticPrimitive,contact))
               {
                  contact = contact.next;
               }
            }
         }
         if(node.axis == -1)
         {
            return contact;
         }
         switch(node.axis)
         {
            case 0:
               min = primitive.aabb.minX;
               max = primitive.aabb.maxX;
               break;
            case 1:
               min = primitive.aabb.minY;
               max = primitive.aabb.maxY;
               break;
            case 2:
               min = primitive.aabb.minZ;
               max = primitive.aabb.maxZ;
         }
         if(min < node.coord)
         {
            contact = this.getPrimitiveNodeCollisions(node.negativeNode,primitive,contact);
         }
         if(max > node.coord)
         {
            contact = this.getPrimitiveNodeCollisions(node.positiveNode,primitive,contact);
         }
         if(node.splitTree != null && min < node.coord && max > node.coord)
         {
            contact = this.getPrimitiveNodeCollisions(node.splitTree.rootNode,primitive,contact);
         }
         return contact;
      }
      
      private function testPrimitiveNodeCollision(primitive:CollisionPrimitive, node:CollisionKdNode) : Boolean
      {
         var min:Number = NaN;
         var max:Number = NaN;
         var primitives:Vector.<CollisionPrimitive> = null;
         var indices:Vector.<int> = null;
         var i:int = 0;
         if(node.indices != null)
         {
            primitives = this.tree.staticChildren;
            indices = node.indices;
            for(i = indices.length - 1; i >= 0; i--)
            {
               if(this.testCollision(primitive,primitives[indices[i]]))
               {
                  return true;
               }
            }
         }
         if(node.axis == -1)
         {
            return false;
         }
         switch(node.axis)
         {
            case 0:
               min = primitive.aabb.minX;
               max = primitive.aabb.maxX;
               break;
            case 1:
               min = primitive.aabb.minY;
               max = primitive.aabb.maxY;
               break;
            case 2:
               min = primitive.aabb.minZ;
               max = primitive.aabb.maxZ;
         }
         if(node.splitTree != null && min < node.coord && max > node.coord)
         {
            if(this.testPrimitiveNodeCollision(primitive,node.splitTree.rootNode))
            {
               return true;
            }
         }
         if(min < node.coord)
         {
            if(this.testPrimitiveNodeCollision(primitive,node.negativeNode))
            {
               return true;
            }
         }
         if(max > node.coord)
         {
            if(this.testPrimitiveNodeCollision(primitive,node.positiveNode))
            {
               return true;
            }
         }
         return false;
      }
      
      private function raycastDynamic(origin:Vector3, direction:Vector3, collisionGroup:int, maxTime:Number, filter:IRayCollisionFilter, result:RayHit) : Boolean
      {
         var wrapper:TankBodyWrapper = null;
         var body:Body = null;
         var aabb:AABB = null;
         var i:int = 0;
         var primitive:CollisionPrimitive = null;
         var t:Number = NaN;
         var xx:Number = origin.x + direction.x * maxTime;
         var yy:Number = origin.y + direction.y * maxTime;
         var zz:Number = origin.z + direction.z * maxTime;
         if(xx < origin.x)
         {
            this._rayAABB.minX = xx;
            this._rayAABB.maxX = origin.x;
         }
         else
         {
            this._rayAABB.minX = origin.x;
            this._rayAABB.maxX = xx;
         }
         if(yy < origin.y)
         {
            this._rayAABB.minY = yy;
            this._rayAABB.maxY = origin.y;
         }
         else
         {
            this._rayAABB.minY = origin.y;
            this._rayAABB.maxY = yy;
         }
         if(zz < origin.z)
         {
            this._rayAABB.minZ = zz;
            this._rayAABB.maxZ = origin.z;
         }
         else
         {
            this._rayAABB.minZ = origin.z;
            this._rayAABB.maxZ = zz;
         }
         var minTime:Number = maxTime + 1;
         var N:int = this.wrappers.length;
         for(var j:int = 0; j < N; j++)
         {
            wrapper = this.wrappers[j];
            body = wrapper.body;
            aabb = body.aabb;
            if(!(this._rayAABB.maxX < aabb.minX || this._rayAABB.minX > aabb.maxX || this._rayAABB.maxY < aabb.minY || this._rayAABB.minY > aabb.maxY || this._rayAABB.maxZ < aabb.minZ || this._rayAABB.minZ > aabb.maxZ))
            {
               for(i = 0; i < body.numCollisionPrimitives; i++)
               {
                  primitive = body.collisionPrimitives[i];
                  if((primitive.collisionGroup & collisionGroup) != 0)
                  {
                     aabb = primitive.aabb;
                     if(!(this._rayAABB.maxX < aabb.minX || this._rayAABB.minX > aabb.maxX || this._rayAABB.maxY < aabb.minY || this._rayAABB.minY > aabb.maxY || this._rayAABB.maxZ < aabb.minZ || this._rayAABB.minZ > aabb.maxZ))
                     {
                        if(!(filter != null && !filter.considerBody(body)))
                        {
                           t = primitive.raycast(origin,direction,this.threshold,this._normal);
                           if(t >= 0 && t < minTime)
                           {
                              minTime = t;
                              result.primitive = primitive;
                              result.normal.x = this._normal.x;
                              result.normal.y = this._normal.y;
                              result.normal.z = this._normal.z;
                           }
                        }
                     }
                  }
               }
            }
         }
         if(minTime > maxTime)
         {
            return false;
         }
         result.position.x = origin.x + direction.x * minTime;
         result.position.y = origin.y + direction.y * minTime;
         result.position.z = origin.z + direction.z * minTime;
         result.t = minTime;
         return true;
      }
      
      private function getRayBoundBoxIntersection(origin:Vector3, dir:Vector3, bb:AABB, time:MinMax) : Boolean
      {
         var t1:Number = NaN;
         var t2:Number = NaN;
         time.min = -1;
         time.max = 1e+308;
         for(var i:int = 0; i < 3; i++)
         {
            switch(i)
            {
               case 0:
                  if(!(dir.x < this.threshold && dir.x > -this.threshold))
                  {
                     t1 = (bb.minX - origin.x) / dir.x;
                     t2 = (bb.maxX - origin.x) / dir.x;
                  }
                  if(origin.x < bb.minX || origin.x > bb.maxX)
                  {
                     return false;
                  }
                  break;
               case 1:
                  if(!(dir.y < this.threshold && dir.y > -this.threshold))
                  {
                     t1 = (bb.minY - origin.y) / dir.y;
                     t2 = (bb.maxY - origin.y) / dir.y;
                  }
                  if(origin.y < bb.minY || origin.y > bb.maxY)
                  {
                     return false;
                  }
                  break;
               case 2:
                  if(!(dir.z < this.threshold && dir.z > -this.threshold))
                  {
                     t1 = (bb.minZ - origin.z) / dir.z;
                     t2 = (bb.maxZ - origin.z) / dir.z;
                  }
                  if(origin.z < bb.minZ || origin.z > bb.maxZ)
                  {
                     return false;
                  }
                  break;
            }
            if(t1 < t2)
            {
               if(t1 > time.min)
               {
                  time.min = t1;
               }
               if(t2 < time.max)
               {
                  time.max = t2;
               }
            }
            else
            {
               if(t2 > time.min)
               {
                  time.min = t2;
               }
               if(t1 < time.max)
               {
                  time.max = t1;
               }
            }
            if(time.max < time.min)
            {
               return false;
            }
         }
         return true;
      }
      
      private function testRayAgainstNode(node:CollisionKdNode, origin:Vector3, localOrigin:Vector3, dir:Vector3, collisionGroup:int, t1:Number, t2:Number, predicate:IRayCollisionFilter, result:RayHit) : Boolean
      {
         var splitTime:Number = NaN;
         var currChildNode:CollisionKdNode = null;
         var intersects:Boolean = false;
         var splitNode:CollisionKdNode = null;
         var i:int = 0;
         var primitive:CollisionPrimitive = null;
         if(node.indices != null && this.getRayNodeIntersection(origin,dir,collisionGroup,this.tree.staticChildren,node.indices,predicate,result))
         {
            return true;
         }
         if(node.axis == -1)
         {
            return false;
         }
         switch(node.axis)
         {
            case 0:
               if(dir.x > -this.threshold && dir.x < this.threshold)
               {
                  splitTime = t2 + 1;
               }
               else
               {
                  splitTime = (node.coord - origin.x) / dir.x;
               }
               currChildNode = localOrigin.x < node.coord ? node.negativeNode : node.positiveNode;
               break;
            case 1:
               if(dir.y > -this.threshold && dir.y < this.threshold)
               {
                  splitTime = t2 + 1;
               }
               else
               {
                  splitTime = (node.coord - origin.y) / dir.y;
               }
               currChildNode = localOrigin.y < node.coord ? node.negativeNode : node.positiveNode;
               break;
            case 2:
               if(dir.z > -this.threshold && dir.z < this.threshold)
               {
                  splitTime = t2 + 1;
               }
               else
               {
                  splitTime = (node.coord - origin.z) / dir.z;
               }
               currChildNode = localOrigin.z < node.coord ? node.negativeNode : node.positiveNode;
         }
         if(splitTime < t1 || splitTime > t2)
         {
            return this.testRayAgainstNode(currChildNode,origin,localOrigin,dir,collisionGroup,t1,t2,predicate,result);
         }
         intersects = this.testRayAgainstNode(currChildNode,origin,localOrigin,dir,collisionGroup,t1,splitTime,predicate,result);
         if(intersects)
         {
            return true;
         }
         this._o.x = origin.x + splitTime * dir.x;
         this._o.y = origin.y + splitTime * dir.y;
         this._o.z = origin.z + splitTime * dir.z;
         if(node.splitTree != null)
         {
            splitNode = node.splitTree.rootNode;
            while(splitNode != null && splitNode.axis != -1)
            {
               switch(splitNode.axis)
               {
                  case 0:
                     splitNode = this._o.x < splitNode.coord ? splitNode.negativeNode : splitNode.positiveNode;
                     break;
                  case 1:
                     splitNode = this._o.y < splitNode.coord ? splitNode.negativeNode : splitNode.positiveNode;
                     break;
                  case 2:
                     splitNode = this._o.z < splitNode.coord ? splitNode.negativeNode : splitNode.positiveNode;
                     break;
               }
            }
            if(splitNode != null && splitNode.indices != null)
            {
               for(i = splitNode.indices.length - 1; i >= 0; i--)
               {
                  primitive = this.tree.staticChildren[splitNode.indices[i]];
                  this.touchedPrimitives.touch(primitive);
                  if((primitive.collisionGroup & collisionGroup) != 0)
                  {
                     if(!(predicate != null && primitive.body != null && !predicate.considerBody(primitive.body)))
                     {
                        result.t = primitive.raycast(origin,dir,this.threshold,result.normal);
                        if(result.t >= 0)
                        {
                           result.position.copy(this._o);
                           result.primitive = primitive;
                           return true;
                        }
                     }
                  }
               }
            }
         }
         return this.testRayAgainstNode(currChildNode == node.negativeNode ? node.positiveNode : node.negativeNode,origin,this._o,dir,collisionGroup,splitTime,t2,predicate,result);
      }
      
      private function getRayNodeIntersection(origin:Vector3, dir:Vector3, collisionGroup:int, primitives:Vector.<CollisionPrimitive>, indices:Vector.<int>, predicate:IRayCollisionFilter, intersection:RayHit) : Boolean
      {
         var primitive:CollisionPrimitive = null;
         var t:Number = NaN;
         var pnum:int = indices.length;
         var minTime:Number = 1e+308;
         for(var i:int = 0; i < pnum; i++)
         {
            primitive = primitives[indices[i]];
            this.touchedPrimitives.touch(primitive);
            if((primitive.collisionGroup & collisionGroup) != 0)
            {
               if(!(predicate != null && primitive.body != null && !predicate.considerBody(primitive.body)))
               {
                  t = primitive.raycast(origin,dir,this.threshold,this._normal);
                  if(t > 0 && t < minTime)
                  {
                     minTime = t;
                     intersection.primitive = primitive;
                     intersection.normal.x = this._normal.x;
                     intersection.normal.y = this._normal.y;
                     intersection.normal.z = this._normal.z;
                  }
               }
            }
         }
         if(minTime == 1e+308)
         {
            return false;
         }
         intersection.position.x = origin.x + dir.x * minTime;
         intersection.position.y = origin.y + dir.y * minTime;
         intersection.position.z = origin.z + dir.z * minTime;
         intersection.t = minTime;
         return true;
      }
   }
}
