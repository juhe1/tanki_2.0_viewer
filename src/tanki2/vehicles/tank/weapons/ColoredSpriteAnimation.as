package tanki2.vehicles.tank.weapons
{
   import alternativa.tanks.sfx.TextureAnimation;
   import flash.geom.ColorTransform;
   
   public class ColoredSpriteAnimation extends SpriteAnimation
   {
       
      
      public var colorTransform:ColorTransform;
      
      public function ColoredSpriteAnimation(frameSize:Number, textureAnimation:TextureAnimation, colorTransform:ColorTransform)
      {
         super(frameSize,textureAnimation);
         this.colorTransform = colorTransform;
      }
   }
}
