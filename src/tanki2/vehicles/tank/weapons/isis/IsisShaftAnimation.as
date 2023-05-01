package alternativa.tanks.vehicles.tank.weapons.isis
{
   import alternativa.tanks.sfx.TextureAnimation;
   import flash.geom.ColorTransform;
   
   public class IsisShaftAnimation
   {
       
      
      public var shaftWidth:Number;
      
      public var textureAnimation:TextureAnimation;
      
      public var colorTransform:ColorTransform;
      
      public function IsisShaftAnimation(shaftWidth:Number, textureAnimation:TextureAnimation, colorTransform:ColorTransform)
      {
         super();
         this.shaftWidth = shaftWidth;
         this.textureAnimation = textureAnimation;
         this.colorTransform = colorTransform;
      }
   }
}
