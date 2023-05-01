package alternativa.tanks.vehicles.tank.weapons.railgun
{
   import flash.geom.ColorTransform;
   
   public class RailgunSFXData
   {
       
      
      public var id:String;
      
      public var colorTransform:ColorTransform;
      
      public var maxBeamScale:Number;
      
      public var beamLifeTime:int;
      
      public function RailgunSFXData(id:String, colorTransform:ColorTransform, maxBeamScale:Number, beamLifeTime:int)
      {
         super();
         this.id = id;
         this.colorTransform = colorTransform;
         this.maxBeamScale = maxBeamScale;
         this.beamLifeTime = beamLifeTime;
      }
   }
}
