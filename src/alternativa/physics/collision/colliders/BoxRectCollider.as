package alternativa.physics.collision.colliders
{
   import alternativa.math.Matrix4;
   import alternativa.math.Vector3;
   import alternativa.physics.Contact;
   import alternativa.physics.ContactPoint;
   import alternativa.physics.collision.CollisionPrimitive;
   import alternativa.physics.collision.primitives.CollisionBox;
   import alternativa.physics.collision.primitives.CollisionRect;
   
   public class BoxRectCollider extends BoxCollider
   {
       
      
      private var epsilon:Number = 0.001;
      
      private var vectorToBox:Vector3;
      
      private var axis:Vector3;
      
      private var axis10:Vector3;
      
      private var axis11:Vector3;
      
      private var axis12:Vector3;
      
      private var axis20:Vector3;
      
      private var axis21:Vector3;
      
      private var axis22:Vector3;
      
      private var bestAxisIndex:int;
      
      private var minOverlap:Number;
      
      private var points1:Vector.<Vector3>;
      
      private var points2:Vector.<Vector3>;
      
      public function BoxRectCollider()
      {
         this.vectorToBox = new Vector3();
         this.axis = new Vector3();
         this.axis10 = new Vector3();
         this.axis11 = new Vector3();
         this.axis12 = new Vector3();
         this.axis20 = new Vector3();
         this.axis21 = new Vector3();
         this.axis22 = new Vector3();
         this.points1 = new Vector.<Vector3>(8,true);
         this.points2 = new Vector.<Vector3>(8,true);
         super();
         for(var i:int = 0; i < 8; i++)
         {
            this.points1[i] = new Vector3();
            this.points2[i] = new Vector3();
         }
      }
      
      override public function getContact(prim1:CollisionPrimitive, prim2:CollisionPrimitive, contact:Contact) : Boolean
      {
         var rect:CollisionRect = null;
         var normal:Vector3 = null;
         var contactPoint:ContactPoint = null;
         if(!this.haveCollision(prim1,prim2))
         {
            return false;
         }
         var box:CollisionBox = prim1 as CollisionBox;
         if(box == null)
         {
            box = prim2 as CollisionBox;
            rect = prim1 as CollisionRect;
         }
         else
         {
            rect = prim2 as CollisionRect;
         }
         if(this.bestAxisIndex < 4)
         {
            if(!this.findFaceContactPoints(box,rect,this.vectorToBox,this.bestAxisIndex,contact))
            {
               return false;
            }
         }
         else
         {
            this.bestAxisIndex -= 4;
            if(!this.findEdgesIntersection(box,rect,this.vectorToBox,int(this.bestAxisIndex / 2),this.bestAxisIndex % 2,contact))
            {
               return false;
            }
         }
         for(var i:int = 0; i < contact.pcount; i++)
         {
            contactPoint = contact.points[i];
            contactPoint.primitive1 = box;
            contactPoint.primitive2 = rect;
         }
         contact.body1 = box.body;
         contact.body2 = rect.body;
         var transform:Matrix4 = rect.transform;
         normal = contact.normal;
         if(transform.k > 0.99999)
         {
            normal.x = 0;
            normal.y = 0;
            normal.z = 1;
         }
         return true;
      }
      
      override public function haveCollision(prim1:CollisionPrimitive, prim2:CollisionPrimitive) : Boolean
      {
         var box:CollisionBox = null;
         var rect:CollisionRect = null;
         var boxTransform:Matrix4 = null;
         var rectTransform:Matrix4 = null;
         this.minOverlap = 10000000000;
         box = prim1 as CollisionBox;
         if(box == null)
         {
            box = prim2 as CollisionBox;
            rect = prim1 as CollisionRect;
         }
         else
         {
            rect = prim2 as CollisionRect;
         }
         boxTransform = box.transform;
         rectTransform = rect.transform;
         this.vectorToBox.x = boxTransform.d - rectTransform.d;
         this.vectorToBox.y = boxTransform.h - rectTransform.h;
         this.vectorToBox.z = boxTransform.l - rectTransform.l;
         rectTransform.getAxis(2,this.axis22);
         if(!this.testMainAxis(box,rect,this.axis22,0,this.vectorToBox))
         {
            return false;
         }
         boxTransform.getAxis(0,this.axis10);
         if(!this.testMainAxis(box,rect,this.axis10,1,this.vectorToBox))
         {
            return false;
         }
         boxTransform.getAxis(1,this.axis11);
         if(!this.testMainAxis(box,rect,this.axis11,2,this.vectorToBox))
         {
            return false;
         }
         boxTransform.getAxis(2,this.axis12);
         if(!this.testMainAxis(box,rect,this.axis12,3,this.vectorToBox))
         {
            return false;
         }
         rectTransform.getAxis(0,this.axis20);
         rectTransform.getAxis(1,this.axis21);
         if(!this.testDerivedAxis(box,rect,this.axis10,this.axis20,4,this.vectorToBox))
         {
            return false;
         }
         if(!this.testDerivedAxis(box,rect,this.axis10,this.axis21,5,this.vectorToBox))
         {
            return false;
         }
         if(!this.testDerivedAxis(box,rect,this.axis11,this.axis20,6,this.vectorToBox))
         {
            return false;
         }
         if(!this.testDerivedAxis(box,rect,this.axis11,this.axis21,7,this.vectorToBox))
         {
            return false;
         }
         if(!this.testDerivedAxis(box,rect,this.axis12,this.axis20,8,this.vectorToBox))
         {
            return false;
         }
         if(!this.testDerivedAxis(box,rect,this.axis12,this.axis21,9,this.vectorToBox))
         {
            return false;
         }
         return true;
      }
      
      private function findFaceContactPoints(box:CollisionBox, rect:CollisionRect, vectorToBox:Vector3, faceAxisIdx:int, contact:Contact) : Boolean
      {
         var pnum:int = 0;
         var i:int = 0;
         var v:Vector3 = null;
         var cp:ContactPoint = null;
         var boxTransform:Matrix4 = null;
         var rectTransform:Matrix4 = null;
         var colAxis:Vector3 = null;
         var negativeFace:Boolean = false;
         var flip:Boolean = false;
         var offset:Number = NaN;
         var incidentAxisIdx:int = 0;
         var incidentAxisDot:Number = NaN;
         var maxDot:Number = NaN;
         var axisIdx:int = 0;
         var dot:Number = NaN;
         var absDot:Number = NaN;
         var cpPos:Vector3 = null;
         var pen:Number = NaN;
         boxTransform = box.transform;
         rectTransform = rect.transform;
         colAxis = contact.normal;
         if(faceAxisIdx == 0)
         {
            colAxis.x = rectTransform.c;
            colAxis.y = rectTransform.g;
            colAxis.z = rectTransform.k;
            offset = colAxis.x * rectTransform.d + colAxis.y * rectTransform.h + colAxis.z * rectTransform.l;
            if(boxTransform.d * colAxis.x + boxTransform.h * colAxis.y + boxTransform.l * colAxis.z < offset)
            {
               colAxis.reverse();
               flip = true;
            }
            incidentAxisIdx = 0;
            maxDot = 0;
            for(axisIdx = 0; axisIdx < 3; axisIdx++)
            {
               boxTransform.getAxis(axisIdx,this.axis);
               dot = this.axis.x * colAxis.x + this.axis.y * colAxis.y + this.axis.z * colAxis.z;
               absDot = dot < 0 ? Number(-dot) : Number(dot);
               if(absDot > maxDot)
               {
                  maxDot = absDot;
                  incidentAxisIdx = axisIdx;
                  incidentAxisDot = dot;
               }
            }
            negativeFace = incidentAxisDot > 0;
            boxTransform.getAxis(incidentAxisIdx,this.axis);
            getFaceVertsByAxis(box.hs,incidentAxisIdx,negativeFace,this.points1);
            boxTransform.transformVectorsN(this.points1,this.points2,4);
            rectTransform.transformVectorsInverseN(this.points2,this.points1,4);
            pnum = this.clipByRect(rect.hs);
            contact.pcount = 0;
            for(i = 0; i < pnum; i++)
            {
               v = this.points1[i];
               if(flip)
               {
                  v.z = -v.z;
               }
               if(v.z < this.epsilon)
               {
                  cp = contact.points[contact.pcount++];
                  cp.penetration = -v.z;
                  cpPos = cp.position;
                  cpPos.x = rectTransform.a * v.x + rectTransform.b * v.y + rectTransform.c * v.z + rectTransform.d;
                  cpPos.y = rectTransform.e * v.x + rectTransform.f * v.y + rectTransform.g * v.z + rectTransform.h;
                  cpPos.z = rectTransform.i * v.x + rectTransform.j * v.y + rectTransform.k * v.z + rectTransform.l;
                  v = cp.r1;
                  v.x = cpPos.x - boxTransform.d;
                  v.y = cpPos.y - boxTransform.h;
                  v.z = cpPos.z - boxTransform.l;
                  v = cp.r2;
                  v.x = cpPos.x - rectTransform.d;
                  v.y = cpPos.y - rectTransform.h;
                  v.z = cpPos.z - rectTransform.l;
               }
            }
         }
         else
         {
            faceAxisIdx--;
            boxTransform.getAxis(faceAxisIdx,colAxis);
            negativeFace = colAxis.x * vectorToBox.x + colAxis.y * vectorToBox.y + colAxis.z * vectorToBox.z > 0;
            if(!negativeFace)
            {
               colAxis.x = -colAxis.x;
               colAxis.y = -colAxis.y;
               colAxis.z = -colAxis.z;
            }
            if(rectTransform.c * colAxis.x + rectTransform.g * colAxis.y + rectTransform.k * colAxis.z < 0)
            {
               return false;
            }
            getFaceVertsByAxis(rect.hs,2,false,this.points1);
            rectTransform.transformVectorsN(this.points1,this.points2,4);
            boxTransform.transformVectorsInverseN(this.points2,this.points1,4);
            pnum = this.clipByBox(box.hs,faceAxisIdx);
            contact.pcount = 0;
            for(i = 0; i < pnum; i++)
            {
               v = this.points1[i];
               if((pen = this.getPointBoxPenetration(box.hs,v,faceAxisIdx,negativeFace)) > -this.epsilon)
               {
                  cp = contact.points[contact.pcount++];
                  cp.penetration = pen;
                  cpPos = cp.position;
                  cpPos.x = boxTransform.a * v.x + boxTransform.b * v.y + boxTransform.c * v.z + boxTransform.d;
                  cpPos.y = boxTransform.e * v.x + boxTransform.f * v.y + boxTransform.g * v.z + boxTransform.h;
                  cpPos.z = boxTransform.i * v.x + boxTransform.j * v.y + boxTransform.k * v.z + boxTransform.l;
                  v = cp.r1;
                  v.x = cpPos.x - boxTransform.d;
                  v.y = cpPos.y - boxTransform.h;
                  v.z = cpPos.z - boxTransform.l;
                  v = cp.r2;
                  v.x = cpPos.x - rectTransform.d;
                  v.y = cpPos.y - rectTransform.h;
                  v.z = cpPos.z - rectTransform.l;
               }
            }
         }
         return true;
      }
      
      private function getPointBoxPenetration(hs:Vector3, p:Vector3, faceAxisIdx:int, reverse:Boolean) : Number
      {
         switch(faceAxisIdx)
         {
            case 0:
               if(reverse)
               {
                  return p.x + hs.x;
               }
               return hs.x - p.x;
               break;
            case 1:
               if(reverse)
               {
                  return p.y + hs.y;
               }
               return hs.y - p.y;
               break;
            case 2:
               if(reverse)
               {
                  return p.z + hs.z;
               }
               return hs.z - p.z;
               break;
            default:
               return 0;
         }
      }
      
      private function clipByBox(hs:Vector3, faceAxisIdx:int) : int
      {
         var pnum:int = 4;
         switch(faceAxisIdx)
         {
            case 0:
               if((pnum = clipLowZ(-hs.z,pnum,this.points1,this.points2,this.epsilon)) == 0)
               {
                  return 0;
               }
               if((pnum = clipHighZ(hs.z,pnum,this.points2,this.points1,this.epsilon)) == 0)
               {
                  return 0;
               }
               if((pnum = clipLowY(-hs.y,pnum,this.points1,this.points2,this.epsilon)) == 0)
               {
                  return 0;
               }
               return clipHighY(hs.y,pnum,this.points2,this.points1,this.epsilon);
               break;
            case 1:
               if((pnum = clipLowZ(-hs.z,pnum,this.points1,this.points2,this.epsilon)) == 0)
               {
                  return 0;
               }
               if((pnum = clipHighZ(hs.z,pnum,this.points2,this.points1,this.epsilon)) == 0)
               {
                  return 0;
               }
               if((pnum = clipLowX(-hs.x,pnum,this.points1,this.points2,this.epsilon)) == 0)
               {
                  return 0;
               }
               return clipHighX(hs.x,pnum,this.points2,this.points1,this.epsilon);
               break;
            case 2:
               if((pnum = clipLowX(-hs.x,pnum,this.points1,this.points2,this.epsilon)) == 0)
               {
                  return 0;
               }
               if((pnum = clipHighX(hs.x,pnum,this.points2,this.points1,this.epsilon)) == 0)
               {
                  return 0;
               }
               if((pnum = clipLowY(-hs.y,pnum,this.points1,this.points2,this.epsilon)) == 0)
               {
                  return 0;
               }
               return clipHighY(hs.y,pnum,this.points2,this.points1,this.epsilon);
               break;
            default:
               return 0;
         }
      }
      
      private function clipByRect(hs:Vector3) : int
      {
         var pnum:int = 4;
         if((pnum = clipLowX(-hs.x,pnum,this.points1,this.points2,this.epsilon)) == 0)
         {
            return 0;
         }
         if((pnum = clipHighX(hs.x,pnum,this.points2,this.points1,this.epsilon)) == 0)
         {
            return 0;
         }
         if((pnum = clipLowY(-hs.y,pnum,this.points1,this.points2,this.epsilon)) == 0)
         {
            return 0;
         }
         return clipHighY(hs.y,pnum,this.points2,this.points1,this.epsilon);
      }
      
      private function findEdgesIntersection(box:CollisionBox, rect:CollisionRect, vectorToBox:Vector3, axisIdx1:int, axisIdx2:int, contact:Contact) : Boolean
      {
         var halfLen1:Number = NaN;
         var halfLen2:Number = NaN;
         var boxTransform:Matrix4 = box.transform;
         var rectTransform:Matrix4 = rect.transform;
         boxTransform.getAxis(axisIdx1,this.axis10);
         rectTransform.getAxis(axisIdx2,this.axis20);
         var colAxis:Vector3 = contact.normal;
         colAxis.x = this.axis10.y * this.axis20.z - this.axis10.z * this.axis20.y;
         colAxis.y = this.axis10.z * this.axis20.x - this.axis10.x * this.axis20.z;
         colAxis.z = this.axis10.x * this.axis20.y - this.axis10.y * this.axis20.x;
         var k:Number = 1 / Math.sqrt(colAxis.x * colAxis.x + colAxis.y * colAxis.y + colAxis.z * colAxis.z);
         colAxis.x *= k;
         colAxis.y *= k;
         colAxis.z *= k;
         if(colAxis.x * vectorToBox.x + colAxis.y * vectorToBox.y + colAxis.z * vectorToBox.z < 0)
         {
            colAxis.x = -colAxis.x;
            colAxis.y = -colAxis.y;
            colAxis.z = -colAxis.z;
         }
         var vx:Number = box.hs.x;
         var vy:Number = box.hs.y;
         var vz:Number = box.hs.z;
         var x2:Number = rect.hs.x;
         var y2:Number = rect.hs.y;
         var z2:Number = rect.hs.z;
         if(axisIdx1 == 0)
         {
            vx = 0;
            halfLen1 = box.hs.x;
         }
         else if(boxTransform.a * colAxis.x + boxTransform.e * colAxis.y + boxTransform.i * colAxis.z > 0)
         {
            vx = -vx;
         }
         if(axisIdx2 == 0)
         {
            x2 = 0;
            halfLen2 = rect.hs.x;
         }
         else if(rectTransform.a * colAxis.x + rectTransform.e * colAxis.y + rectTransform.i * colAxis.z < 0)
         {
            x2 = -x2;
         }
         if(axisIdx1 == 1)
         {
            vy = 0;
            halfLen1 = box.hs.y;
         }
         else if(boxTransform.b * colAxis.x + boxTransform.f * colAxis.y + boxTransform.j * colAxis.z > 0)
         {
            vy = -vy;
         }
         if(axisIdx2 == 1)
         {
            y2 = 0;
            halfLen2 = rect.hs.y;
         }
         else if(rectTransform.b * colAxis.x + rectTransform.f * colAxis.y + rectTransform.j * colAxis.z < 0)
         {
            y2 = -y2;
         }
         if(axisIdx1 == 2)
         {
            vz = 0;
            halfLen1 = box.hs.z;
         }
         else if(boxTransform.c * colAxis.x + boxTransform.g * colAxis.y + boxTransform.k * colAxis.z > 0)
         {
            vz = -vz;
         }
         var x1:Number = boxTransform.a * vx + boxTransform.b * vy + boxTransform.c * vz + boxTransform.d;
         var y1:Number = boxTransform.e * vx + boxTransform.f * vy + boxTransform.g * vz + boxTransform.h;
         var z1:Number = boxTransform.i * vx + boxTransform.j * vy + boxTransform.k * vz + boxTransform.l;
         vx = x2;
         vy = y2;
         vz = z2;
         x2 = rectTransform.a * vx + rectTransform.b * vy + rectTransform.c * vz + rectTransform.d;
         y2 = rectTransform.e * vx + rectTransform.f * vy + rectTransform.g * vz + rectTransform.h;
         z2 = rectTransform.i * vx + rectTransform.j * vy + rectTransform.k * vz + rectTransform.l;
         k = this.axis10.x * this.axis20.x + this.axis10.y * this.axis20.y + this.axis10.z * this.axis20.z;
         var det:Number = k * k - 1;
         vx = x2 - x1;
         vy = y2 - y1;
         vz = z2 - z1;
         var c1:Number = this.axis10.x * vx + this.axis10.y * vy + this.axis10.z * vz;
         var c2:Number = this.axis20.x * vx + this.axis20.y * vy + this.axis20.z * vz;
         var t1:Number = (c2 * k - c1) / det;
         var t2:Number = (c2 - c1 * k) / det;
         contact.pcount = 1;
         var cp:ContactPoint = contact.points[0];
         cp.penetration = this.minOverlap;
         var cpPos:Vector3 = cp.position;
         cpPos.x = 0.5 * (x1 + this.axis10.x * t1 + x2 + this.axis20.x * t2);
         cpPos.y = 0.5 * (y1 + this.axis10.y * t1 + y2 + this.axis20.y * t2);
         cpPos.z = 0.5 * (z1 + this.axis10.z * t1 + z2 + this.axis20.z * t2);
         var v:Vector3 = cp.r1;
         v.x = cpPos.x - boxTransform.d;
         v.y = cpPos.y - boxTransform.h;
         v.z = cpPos.z - boxTransform.l;
         v = cp.r2;
         v.x = cpPos.x - rectTransform.d;
         v.y = cpPos.y - rectTransform.h;
         v.z = cpPos.z - rectTransform.l;
         return true;
      }
      
      private function testMainAxis(box:CollisionBox, rect:CollisionRect, axis:Vector3, axisIndex:int, vectorToBox:Vector3) : Boolean
      {
         var overlap:Number = this.overlapOnAxis(box,rect,axis,vectorToBox);
         if(overlap > -this.epsilon)
         {
            if(overlap + this.epsilon < this.minOverlap)
            {
               this.minOverlap = overlap;
               this.bestAxisIndex = axisIndex;
            }
            return true;
         }
         return false;
      }
      
      private function testDerivedAxis(box:CollisionBox, rect:CollisionRect, axis1:Vector3, axis2:Vector3, axisIndex:int, vectorToBox:Vector3) : Boolean
      {
         this.axis.x = axis1.y * axis2.z - axis1.z * axis2.y;
         this.axis.y = axis1.z * axis2.x - axis1.x * axis2.z;
         this.axis.z = axis1.x * axis2.y - axis1.y * axis2.x;
         var lenSqr:Number = this.axis.x * this.axis.x + this.axis.y * this.axis.y + this.axis.z * this.axis.z;
         if(lenSqr < 0.0001)
         {
            return true;
         }
         var k:Number = 1 / Math.sqrt(lenSqr);
         this.axis.x *= k;
         this.axis.y *= k;
         this.axis.z *= k;
         var overlap:Number = this.overlapOnAxis(box,rect,this.axis,vectorToBox);
         if(overlap > -this.epsilon)
         {
            if(overlap + this.epsilon < this.minOverlap)
            {
               this.minOverlap = overlap;
               this.bestAxisIndex = axisIndex;
            }
            return true;
         }
         return false;
      }
      
      public function overlapOnAxis(box:CollisionBox, rect:CollisionRect, axis:Vector3, vectorToBox:Vector3) : Number
      {
         var m:Matrix4 = box.transform;
         var d:Number = (m.a * axis.x + m.e * axis.y + m.i * axis.z) * box.hs.x;
         if(d < 0)
         {
            d = -d;
         }
         var projection:Number = d;
         d = (m.b * axis.x + m.f * axis.y + m.j * axis.z) * box.hs.y;
         if(d < 0)
         {
            d = -d;
         }
         projection += d;
         d = (m.c * axis.x + m.g * axis.y + m.k * axis.z) * box.hs.z;
         if(d < 0)
         {
            d = -d;
         }
         projection += d;
         m = rect.transform;
         d = (m.a * axis.x + m.e * axis.y + m.i * axis.z) * rect.hs.x;
         if(d < 0)
         {
            d = -d;
         }
         projection += d;
         d = (m.b * axis.x + m.f * axis.y + m.j * axis.z) * rect.hs.y;
         if(d < 0)
         {
            d = -d;
         }
         projection += d;
         d = vectorToBox.x * axis.x + vectorToBox.y * axis.y + vectorToBox.z * axis.z;
         if(d < 0)
         {
            d = -d;
         }
         return projection - d;
      }
   }
}
