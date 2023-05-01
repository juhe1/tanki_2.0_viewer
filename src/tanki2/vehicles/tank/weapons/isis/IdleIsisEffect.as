package alternativa.tanks.vehicles.tank.weapons.isis
{
   import alternativa.tanks.Game;
   import alternativa.tanks.vehicles.tank.Tank;
   import alternativa.tanks.vehicles.tank.weapons.SpriteAnimation;
   import alternativa.tanks.vehicles.tank.weapons.sfx.AnimatedSprite;
   import alternativa.tanks.vehicles.tank.weapons.sfx.MuzzlePositionProvider;
   
   public class IdleIsisEffect implements IsisEffect
   {
       
      
      private var effect:AnimatedSprite;
      
      public function IdleIsisEffect(animation:SpriteAnimation, tank:Tank)
      {
         super();
         this.effect = AnimatedSprite(Game.getInstance().getObjectFromPool(AnimatedSprite));
         this.effect.init(animation.frameSize,animation.frameSize,animation.textureAnimation,new MuzzlePositionProvider(tank,10));
      }
      
      public function start() : void
      {
         trace("IdleIsisEffect::start()");
         Game.getInstance().getBattleScene3D().addGraphicEffect(this.effect);
      }
      
      public function kill() : void
      {
         trace("IdleIsisEffect::kill()");
         this.effect.kill();
         this.effect = null;
      }
   }
}
