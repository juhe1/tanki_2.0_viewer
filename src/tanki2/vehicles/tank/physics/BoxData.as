package tanki2.vehicles.tank.physics
{
   import alternativa.math.Matrix4;
   import alternativa.math.Vector3;
   
   public class BoxData
   {
       
      
      public var hs:Vector3;
      
      public var matrix:Matrix4;
      
      public var excludedFaces:int;
      
      public function BoxData(hs:Vector3, matrix:Matrix4)
      {
         super();
         this.hs = hs;
         this.matrix = matrix;
      }
      
      public function toString() : String
      {
         return "BoxData(hs=" + this.hs + ", matrix=" + this.matrix + ")";
      }
   }
}
