package tanki2.vehicles.tank.weapons
{
   import alternativa.tanks.Game;
   import alternativa.tanks.config.TextureAnimations;
   
   public class WeaponTextureAnimations
   {
       
      
      private var animations:Vector.<SpriteAnimation>;
      
      private var currentAnimationIndex:int;
      
      public function WeaponTextureAnimations(xml:XMLList)
      {
         var animationXML:XML = null;
         this.animations = new Vector.<SpriteAnimation>();
         super();
         var textureAnimations:TextureAnimations = Game.getInstance().config.textureAnimations;
         for each(animationXML in xml)
         {
            this.animations.push(new SpriteAnimation(Number(animationXML.@frameSize),textureAnimations.getAnimation(animationXML.@animationId)));
         }
      }
      
      public function getCurrentAnimation() : SpriteAnimation
      {
         return this.animations[this.currentAnimationIndex];
      }
      
      public function nextAnimation() : SpriteAnimation
      {
         this.currentAnimationIndex = (this.currentAnimationIndex + 1) % this.animations.length;
         return this.getCurrentAnimation();
      }
      
      public function prevAnimation() : SpriteAnimation
      {
         if(this.currentAnimationIndex == 0)
         {
            this.currentAnimationIndex = this.animations.length - 1;
         }
         else
         {
            --this.currentAnimationIndex;
         }
         return this.getCurrentAnimation();
      }
   }
}
