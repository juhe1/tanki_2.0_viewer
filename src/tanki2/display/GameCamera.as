package tanki2.display
{
   import alternativa.engine3d.core.Camera3D;
   import alternativa.math.Vector3;
   
   public class GameCamera extends Camera3D
   {
      
      private static const vin:Vector.<Number> = Vector.<Number>([0,0,0,1,0,0,0,1,0,0,0,1]);
      
      private static const vout:Vector.<Number> = Vector.<Number>([0,0,0,1,0,0,0,1,0,0,0,1]);
       
      
      public var position:Vector3;
      
      public var xAxis:Vector3;
      
      public var yAxis:Vector3;
      
      public var zAxis:Vector3;
      
      public function GameCamera()
      {
         this.position = new Vector3();
         this.xAxis = new Vector3();
         this.yAxis = new Vector3();
         this.zAxis = new Vector3();
         super();
      }
      
      public function recalculate() : void
      {
         matrix.transformVectors(vin,vout);
         this.position.x = vout[0];
         this.position.y = vout[1];
         this.position.z = vout[2];
         this.xAxis.x = vout[3] - this.position.x;
         this.xAxis.y = vout[4] - this.position.y;
         this.xAxis.z = vout[5] - this.position.z;
         this.yAxis.x = vout[6] - this.position.x;
         this.yAxis.y = vout[7] - this.position.y;
         this.yAxis.z = vout[8] - this.position.z;
         this.zAxis.x = vout[9] - this.position.x;
         this.zAxis.y = vout[10] - this.position.y;
         this.zAxis.z = vout[11] - this.position.z;
      }
   }
}
