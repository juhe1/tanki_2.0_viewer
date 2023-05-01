package alternativa.tanks.vehicles.tank.weapons.flamethrower
{
   public class ColorTransformEntry
   {
       
      
      public var t:Number;
      
      public var redMultiplier:Number;
      
      public var greenMultiplier:Number;
      
      public var blueMultiplier:Number;
      
      public var alphaMultiplier:Number;
      
      public var redOffset:int;
      
      public var greenOffset:int;
      
      public var blueOffset:int;
      
      public var alphaOffset:int;
      
      public function ColorTransformEntry(t:Number, redMultiplier:Number, greenMultiplier:Number, blueMultiplier:Number, alphaMultiplier:Number, redOffset:int, greenOffset:int, blueOffset:int, alphaOffset:int)
      {
         super();
         this.t = t;
         this.redMultiplier = redMultiplier;
         this.greenMultiplier = greenMultiplier;
         this.blueMultiplier = blueMultiplier;
         this.alphaMultiplier = alphaMultiplier;
         this.redOffset = redOffset;
         this.greenOffset = greenOffset;
         this.blueOffset = blueOffset;
         this.alphaOffset = alphaOffset;
      }
   }
}
