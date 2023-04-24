package alternativa.math
{
   import flash.geom.Vector3D;
   
   public class Matrix3
   {
      
      public static const ZERO:Matrix3 = new Matrix3(0,0,0,0,0,0,0,0,0);
      
      public static const IDENTITY:Matrix3 = new Matrix3();
       
      
      public var a:Number;
      
      public var b:Number;
      
      public var c:Number;
      
      public var e:Number;
      
      public var f:Number;
      
      public var g:Number;
      
      public var i:Number;
      
      public var j:Number;
      
      public var k:Number;
      
      public function Matrix3(a:Number = 1, b:Number = 0, c:Number = 0, e:Number = 0, f:Number = 1, g:Number = 0, i:Number = 0, j:Number = 0, k:Number = 1)
      {
         super();
         this.a = a;
         this.b = b;
         this.c = c;
         this.e = e;
         this.f = f;
         this.g = g;
         this.i = i;
         this.j = j;
         this.k = k;
      }
      
      public function toIdentity() : Matrix3
      {
         this.a = this.f = this.k = 1;
         this.b = this.c = this.e = this.g = this.i = this.j = 0;
         return this;
      }
      
      public function invert() : Matrix3
      {
         var aa:Number = this.a;
         var bb:Number = this.b;
         var cc:Number = this.c;
         var ee:Number = this.e;
         var ff:Number = this.f;
         var gg:Number = this.g;
         var ii:Number = this.i;
         var jj:Number = this.j;
         var kk:Number = this.k;
         var det:Number = 1 / (-cc * ff * ii + bb * gg * ii + cc * ee * jj - aa * gg * jj - bb * ee * kk + aa * ff * kk);
         this.a = (ff * kk - gg * jj) * det;
         this.b = (cc * jj - bb * kk) * det;
         this.c = (bb * gg - cc * ff) * det;
         this.e = (gg * ii - ee * kk) * det;
         this.f = (aa * kk - cc * ii) * det;
         this.g = (cc * ee - aa * gg) * det;
         this.i = (ee * jj - ff * ii) * det;
         this.j = (bb * ii - aa * jj) * det;
         this.k = (aa * ff - bb * ee) * det;
         return this;
      }
      
      public function append(m:Matrix3) : Matrix3
      {
         var aa:Number = this.a;
         var bb:Number = this.b;
         var cc:Number = this.c;
         var ee:Number = this.e;
         var ff:Number = this.f;
         var gg:Number = this.g;
         var ii:Number = this.i;
         var jj:Number = this.j;
         var kk:Number = this.k;
         this.a = m.a * aa + m.b * ee + m.c * ii;
         this.b = m.a * bb + m.b * ff + m.c * jj;
         this.c = m.a * cc + m.b * gg + m.c * kk;
         this.e = m.e * aa + m.f * ee + m.g * ii;
         this.f = m.e * bb + m.f * ff + m.g * jj;
         this.g = m.e * cc + m.f * gg + m.g * kk;
         this.i = m.i * aa + m.j * ee + m.k * ii;
         this.j = m.i * bb + m.j * ff + m.k * jj;
         this.k = m.i * cc + m.j * gg + m.k * kk;
         return this;
      }
      
      public function prepend(m:Matrix3) : Matrix3
      {
         var aa:Number = this.a;
         var bb:Number = this.b;
         var cc:Number = this.c;
         var ee:Number = this.e;
         var ff:Number = this.f;
         var gg:Number = this.g;
         var ii:Number = this.i;
         var jj:Number = this.j;
         var kk:Number = this.k;
         this.a = aa * m.a + bb * m.e + cc * m.i;
         this.b = aa * m.b + bb * m.f + cc * m.j;
         this.c = aa * m.c + bb * m.g + cc * m.k;
         this.e = ee * m.a + ff * m.e + gg * m.i;
         this.f = ee * m.b + ff * m.f + gg * m.j;
         this.g = ee * m.c + ff * m.g + gg * m.k;
         this.i = ii * m.a + jj * m.e + kk * m.i;
         this.j = ii * m.b + jj * m.f + kk * m.j;
         this.k = ii * m.c + jj * m.g + kk * m.k;
         return this;
      }
      
      public function prependTransposed(m:Matrix3) : Matrix3
      {
         var aa:Number = this.a;
         var bb:Number = this.b;
         var cc:Number = this.c;
         var ee:Number = this.e;
         var ff:Number = this.f;
         var gg:Number = this.g;
         var ii:Number = this.i;
         var jj:Number = this.j;
         var kk:Number = this.k;
         this.a = aa * m.a + bb * m.b + cc * m.c;
         this.b = aa * m.e + bb * m.f + cc * m.g;
         this.c = aa * m.i + bb * m.j + cc * m.k;
         this.e = ee * m.a + ff * m.b + gg * m.c;
         this.f = ee * m.e + ff * m.f + gg * m.g;
         this.g = ee * m.i + ff * m.j + gg * m.k;
         this.i = ii * m.a + jj * m.b + kk * m.c;
         this.j = ii * m.e + jj * m.f + kk * m.g;
         this.k = ii * m.i + jj * m.j + kk * m.k;
         return this;
      }
      
      public function add(m:Matrix3) : Matrix3
      {
         this.a += m.a;
         this.b += m.b;
         this.c += m.c;
         this.e += m.e;
         this.f += m.f;
         this.g += m.g;
         this.i += m.i;
         this.j += m.j;
         this.k += m.k;
         return this;
      }
      
      public function subtract(m:Matrix3) : Matrix3
      {
         this.a -= m.a;
         this.b -= m.b;
         this.c -= m.c;
         this.e -= m.e;
         this.f -= m.f;
         this.g -= m.g;
         this.i -= m.i;
         this.j -= m.j;
         this.k -= m.k;
         return this;
      }
      
      public function transpose() : Matrix3
      {
         var tmp:Number = this.b;
         this.b = this.e;
         this.e = tmp;
         tmp = this.c;
         this.c = this.i;
         this.i = tmp;
         tmp = this.g;
         this.g = this.j;
         this.j = tmp;
         return this;
      }
      
      public function transformVector(vin:Vector3, vout:Vector3) : void
      {
         vout.x = this.a * vin.x + this.b * vin.y + this.c * vin.z;
         vout.y = this.e * vin.x + this.f * vin.y + this.g * vin.z;
         vout.z = this.i * vin.x + this.j * vin.y + this.k * vin.z;
      }
      
      public function transformVectorInverse(vin:Vector3, vout:Vector3) : void
      {
         vout.x = this.a * vin.x + this.e * vin.y + this.i * vin.z;
         vout.y = this.b * vin.x + this.f * vin.y + this.j * vin.z;
         vout.z = this.c * vin.x + this.g * vin.y + this.k * vin.z;
      }
      
      public function transformVector3To3D(vin:Vector3, vout:Vector3D) : void
      {
         vout.x = this.a * vin.x + this.b * vin.y + this.c * vin.z;
         vout.y = this.e * vin.x + this.f * vin.y + this.g * vin.z;
         vout.z = this.i * vin.x + this.j * vin.y + this.k * vin.z;
      }
      
      public function createSkewSymmetric(v:Vector3) : Matrix3
      {
         this.a = this.f = this.k = 0;
         this.b = -v.z;
         this.c = v.y;
         this.e = v.z;
         this.g = -v.x;
         this.i = -v.y;
         this.j = v.x;
         return this;
      }
      
      public function copy(m:Matrix3) : Matrix3
      {
         this.a = m.a;
         this.b = m.b;
         this.c = m.c;
         this.e = m.e;
         this.f = m.f;
         this.g = m.g;
         this.i = m.i;
         this.j = m.j;
         this.k = m.k;
         return this;
      }
      
      public function setRotationMatrix(rx:Number, ry:Number, rz:Number) : Matrix3
      {
         var cosX:Number = Math.cos(rx);
         var sinX:Number = Math.sin(rx);
         var cosY:Number = Math.cos(ry);
         var sinY:Number = Math.sin(ry);
         var cosZ:Number = Math.cos(rz);
         var sinZ:Number = Math.sin(rz);
         var cosZsinY:Number = cosZ * sinY;
         var sinZsinY:Number = sinZ * sinY;
         this.a = cosZ * cosY;
         this.b = cosZsinY * sinX - sinZ * cosX;
         this.c = cosZsinY * cosX + sinZ * sinX;
         this.e = sinZ * cosY;
         this.f = sinZsinY * sinX + cosZ * cosX;
         this.g = sinZsinY * cosX - cosZ * sinX;
         this.i = -sinY;
         this.j = cosY * sinX;
         this.k = cosY * cosX;
         return this;
      }
      
      public function fromAxisAngle(axis:Vector3, angle:Number) : void
      {
         var c1:Number = Math.cos(angle);
         var s:Number = Math.sin(angle);
         var t:Number = 1 - c1;
         var x:Number = axis.x;
         var y:Number = axis.y;
         var z:Number = axis.z;
         this.a = t * x * x + c1;
         this.b = t * x * y - z * s;
         this.c = t * x * z + y * s;
         this.e = t * x * y + z * s;
         this.f = t * y * y + c1;
         this.g = t * y * z - x * s;
         this.i = t * x * z - y * s;
         this.j = t * y * z + x * s;
         this.k = t * z * z + c1;
      }
      
      public function clone() : Matrix3
      {
         return new Matrix3(this.a,this.b,this.c,this.e,this.f,this.g,this.i,this.j,this.k);
      }
      
      public function toString() : String
      {
         return "[Matrix3 (" + this.a + ", " + this.b + ", " + this.c + "), (" + this.e + ", " + this.f + ", " + this.g + "), (" + this.i + ", " + this.j + ", " + this.k + ")]";
      }
      
      public function getEulerAngles(angles:Vector3) : void
      {
         if(-1 < this.i && this.i < 1)
         {
            angles.x = Math.atan2(this.j,this.k);
            angles.y = -Math.asin(this.i);
            angles.z = Math.atan2(this.e,this.a);
         }
         else
         {
            angles.x = 0;
            angles.y = this.i <= -1 ? Number(Math.PI) : Number(-Math.PI);
            angles.y *= 0.5;
            angles.z = Math.atan2(-this.b,this.f);
         }
      }
      
      public function getAxis(index:int, result:Vector3) : void
      {
         switch(index)
         {
            case 0:
               result.reset(this.a,this.e,this.i);
               break;
            case 1:
               result.reset(this.b,this.f,this.j);
               break;
            case 2:
               result.reset(this.c,this.g,this.k);
         }
      }
   }
}
