package tanki2.vehicles.tank.weapons
{
   public class PlasmaGunData
   {
       
      
      public var maxRange:Number;
      
      public var fadeRange:Number;
      
      public var shotSpeed:Number;
      
      public var shotRadius:Number;
      
      public function PlasmaGunData(maxRange:Number, fadeRange:Number, shotSpeed:Number, shotRadius:Number)
      {
         super();
         this.maxRange = maxRange;
         this.fadeRange = fadeRange;
         this.shotSpeed = shotSpeed;
         this.shotRadius = shotRadius;
      }
   }
}
