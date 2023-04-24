package tanki2.display.controllers
{
   import alternativa.math.Vector3;
   
   public class CameraPositionData
   {
       
      
      public var t:Number;
      
      public var extraPitch:Number;
      
      public var position:Vector3;
      
      public function CameraPositionData()
      {
         this.position = new Vector3();
         super();
      }
   }
}
