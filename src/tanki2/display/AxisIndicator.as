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
      
      public function update(param1:Camera3D) : void
      {
      }
      
      public function get size() : int
      {
         return this._size;
      }
   }
}
