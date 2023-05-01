package tanki2.vehicles.tank.weapons
{
   import alternativa.math.Vector3;
   import alternativa.physics.Body;
   
   public class HitInfo
   {
       
      
      public var t:Number;
      
      public var body:Body;
      
      public var pos:Vector3;
      
      public var dir:Vector3;
      
      public function HitInfo()
      {
         this.pos = new Vector3();
         this.dir = new Vector3();
         super();
      }
   }
}
