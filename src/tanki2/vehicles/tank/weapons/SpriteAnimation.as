package tanki2.vehicles.tank.weapons
{
   import tanki2.sfx.TextureAnimation;
   
   public class SpriteAnimation
   {
       
      
      public var frameSize:Number;
      
      public var textureAnimation:TextureAnimation;
      
      public function SpriteAnimation(frameSize:Number, textureAnimation:TextureAnimation)
      {
         super();
         this.frameSize = frameSize;
         this.textureAnimation = textureAnimation;
      }
   }
}
