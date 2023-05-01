package tanki2.display
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Camera3D;
   import flash.display.Shape;
   
   use namespace alternativa3d;
   
   public class AxisIndicator extends Shape
   {
       
      
      private var _size:int;
      
      private var axis:Vector.<Number>;
      
      public function AxisIndicator(size:int)
      {
         this.axis = Vector.<Number>([1,0,0,0,1,0,0,0,1,0,0,0]);
         super();
         this._size = size;
      }
      
      public function update(camera:Camera3D) : void
      {
         var kx:Number = NaN;
         var ky:Number = NaN;
         graphics.clear();
         camera.composeTransforms();
         this.axis[0] = camera.transform.a;
         this.axis[1] = camera.transform.b;
         this.axis[2] = camera.transform.e;
         this.axis[3] = camera.transform.f;
         this.axis[4] = camera.transform.i;
         this.axis[5] = camera.transform.j;
         var bitOffset:int = 16;
         for (var i:int = 0;  i < 6; i += 2, bitOffset -= 8)
         {
            kx = this.axis[i] + 1;
            ky = this.axis[int(i + 1)] + 1;
            graphics.lineStyle(0,255 << bitOffset);
            graphics.moveTo(this._size,this._size);
            graphics.lineTo(this._size * kx,this._size * ky);
         }
      }
      
      public function get size() : int
      {
         return this._size;
      }
   }
}
