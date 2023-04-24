package alternativa.math
{
   import flash.geom.Vector3D;
   
   public class Vector3
   {
      
      public static const ZERO:Vector3 = new Vector3(0,0,0);
      
      public static const X_AXIS:Vector3 = new Vector3(1,0,0);
      
      public static const Y_AXIS:Vector3 = new Vector3(0,1,0);
      
      public static const Z_AXIS:Vector3 = new Vector3(0,0,1);
      
      public static const DOWN:Vector3 = new Vector3(0,0,-1);
       
      
      public var x:Number;
      
      public var y:Number;
      
      public var z:Number;
      
      public function Vector3(x:Number = 0, y:Number = 0, z:Number = 0)
      {
         super();
         this.x = x;
         this.y = y;
         this.z = z;
      }
      
      public static function interpolate(t:Number, a:Vector3, b:Vector3, result:Vector3) : void
      {
         result.x = a.x + t * (b.x - a.x);
         result.y = a.y + t * (b.y - a.y);
         result.z = a.z + t * (b.z - a.z);
      }
      
      public function interpolate(t:Number, a:Vector3, b:Vector3) : void
      {
         this.x = a.x + t * (b.x - a.x);
         this.y = a.y + t * (b.y - a.y);
         this.z = a.z + t * (b.z - a.z);
      }
      
      public function length() : Number
      {
         return Math.sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
      }
      
      public function lengthSqr() : Number
      {
         return this.x * this.x + this.y * this.y + this.z * this.z;
      }
      
      public function setLength(length:Number) : Vector3
      {
         var k:Number = NaN;
         var d:Number = this.x * this.x + this.y * this.y + this.z * this.z;
         if(d == 0)
         {
            this.x = length;
         }
         else
         {
            k = length / Math.sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
            this.x *= k;
            this.y *= k;
            this.z *= k;
         }
         return this;
      }
      
      public function normalize() : Vector3
      {
         var d:Number = this.x * this.x + this.y * this.y + this.z * this.z;
         if(d == 0)
         {
            this.x = 1;
         }
         else
         {
            d = Math.sqrt(d);
            this.x /= d;
            this.y /= d;
            this.z /= d;
         }
         return this;
      }
      
      public function add(v:Vector3) : Vector3
      {
         this.x += v.x;
         this.y += v.y;
         this.z += v.z;
         return this;
      }
      
      public function addScaled(k:Number, v:Vector3) : Vector3
      {
         this.x += k * v.x;
         this.y += k * v.y;
         this.z += k * v.z;
         return this;
      }
      
      public function subtract(v:Vector3) : Vector3
      {
         this.x -= v.x;
         this.y -= v.y;
         this.z -= v.z;
         return this;
      }
      
      public function sum(a:Vector3, b:Vector3) : Vector3
      {
         this.x = a.x + b.x;
         this.y = a.y + b.y;
         this.z = a.z + b.z;
         return this;
      }
      
      public function diff(a:Vector3, b:Vector3) : Vector3
      {
         this.x = a.x - b.x;
         this.y = a.y - b.y;
         this.z = a.z - b.z;
         return this;
      }
      
      public function scale(k:Number) : Vector3
      {
         this.x *= k;
         this.y *= k;
         this.z *= k;
         return this;
      }
      
      public function reverse() : Vector3
      {
         this.x = -this.x;
         this.y = -this.y;
         this.z = -this.z;
         return this;
      }
      
      public function dot(v:Vector3) : Number
      {
         return this.x * v.x + this.y * v.y + this.z * v.z;
      }
      
      public function cross(v:Vector3) : Vector3
      {
         var xx:Number = this.y * v.z - this.z * v.y;
         var yy:Number = this.z * v.x - this.x * v.z;
         var zz:Number = this.x * v.y - this.y * v.x;
         this.x = xx;
         this.y = yy;
         this.z = zz;
         return this;
      }
      
      public function cross2(a:Vector3, b:Vector3) : Vector3
      {
         this.x = a.y * b.z - a.z * b.y;
         this.y = a.z * b.x - a.x * b.z;
         this.z = a.x * b.y - a.y * b.x;
         return this;
      }
      
      public function transform3(m:Matrix3) : Vector3
      {
         var xx:Number = this.x;
         var yy:Number = this.y;
         var zz:Number = this.z;
         this.x = m.a * xx + m.b * yy + m.c * zz;
         this.y = m.e * xx + m.f * yy + m.g * zz;
         this.z = m.i * xx + m.j * yy + m.k * zz;
         return this;
      }
      
      public function transformTransposed3(m:Matrix3) : Vector3
      {
         var xx:Number = this.x;
         var yy:Number = this.y;
         var zz:Number = this.z;
         this.x = m.a * xx + m.e * yy + m.i * zz;
         this.y = m.b * xx + m.f * yy + m.j * zz;
         this.z = m.c * xx + m.g * yy + m.k * zz;
         return this;
      }
      
      public function transform4(m:Matrix4) : Vector3
      {
         var xx:Number = this.x;
         var yy:Number = this.y;
         var zz:Number = this.z;
         this.x = m.a * xx + m.b * yy + m.c * zz + m.d;
         this.y = m.e * xx + m.f * yy + m.g * zz + m.h;
         this.z = m.i * xx + m.j * yy + m.k * zz + m.l;
         return this;
      }
      
      public function transformInverse4(m:Matrix4) : Vector3
      {
         var xx:Number = this.x - m.d;
         var yy:Number = this.y - m.h;
         var zz:Number = this.z - m.l;
         this.x = m.a * xx + m.e * yy + m.i * zz;
         this.y = m.b * xx + m.f * yy + m.j * zz;
         this.z = m.c * xx + m.g * yy + m.k * zz;
         return this;
      }
      
      public function transformVector4(m:Matrix4) : Vector3
      {
         var xx:Number = this.x;
         var yy:Number = this.y;
         var zz:Number = this.z;
         this.x = m.a * xx + m.b * yy + m.c * zz;
         this.y = m.e * xx + m.f * yy + m.g * zz;
         this.z = m.i * xx + m.j * yy + m.k * zz;
         return this;
      }
      
      public function reset(x:Number = 0, y:Number = 0, z:Number = 0) : Vector3
      {
         this.x = x;
         this.y = y;
         this.z = z;
         return this;
      }
      
      public function copy(v:Vector3) : Vector3
      {
         this.x = v.x;
         this.y = v.y;
         this.z = v.z;
         return this;
      }
      
      public function clone() : Vector3
      {
         return new Vector3(this.x,this.y,this.z);
      }
      
      public function toVector3D(result:Vector3D) : Vector3D
      {
         result.x = this.x;
         result.y = this.y;
         result.z = this.z;
         return result;
      }
      
      public function copyFromVector3D(source:Vector3D) : Vector3
      {
         this.x = source.x;
         this.y = source.y;
         this.z = source.z;
         return this;
      }
      
      public function toString() : String
      {
         return this.x.toFixed(3) + ", " + this.y.toFixed(3) + ", " + this.z.toFixed(3);
      }
      
      public function distanceTo(v:Vector3) : Number
      {
         var dx:Number = this.x - v.x;
         var dy:Number = this.y - v.y;
         var dz:Number = this.z - v.z;
         return Math.sqrt(dx * dx + dy * dy + dz * dz);
      }
   }
}
