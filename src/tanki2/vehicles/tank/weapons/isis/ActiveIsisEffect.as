package alternativa.tanks.vehicles.tank.weapons.isis
{
   import alternativa.tanks.Game;
   import alternativa.tanks.battle.BattleScene3D;
   import alternativa.tanks.vehicles.tank.Tank;
   import alternativa.tanks.vehicles.tank.weapons.ColoredSpriteAnimation;
   import alternativa.tanks.vehicles.tank.weapons.sfx.AnimatedSprite;
   import alternativa.tanks.vehicles.tank.weapons.sfx.MuzzlePositionProvider;
   
   public class ActiveIsisEffect implements IsisEffect
   {
       
      
      private var startEffect:AnimatedSprite;
      
      private var endEffect:AnimatedSprite;
      
      private var shaftEffect:HealingGunShaftEffect;
      
      public function ActiveIsisEffect(startAnimation:ColoredSpriteAnimation, endAnimation:ColoredSpriteAnimation, shaftAnimation:IsisShaftAnimation, tank:Tank)
      {
         super();
         this.startEffect = AnimatedSprite(Game.getInstance().getObjectFromPool(AnimatedSprite));
         var startPositionProvider:MuzzlePositionProvider = new MuzzlePositionProvider(tank,10);
         this.startEffect.init(startAnimation.frameSize,startAnimation.frameSize,startAnimation.textureAnimation,startPositionProvider,startAnimation.colorTransform);
         this.endEffect = AnimatedSprite(Game.getInstance().getObjectFromPool(AnimatedSprite));
         var endPositionProvider:MuzzlePositionProvider = new MuzzlePositionProvider(tank,600);
         this.endEffect.init(endAnimation.frameSize,endAnimation.frameSize,endAnimation.textureAnimation,endPositionProvider,endAnimation.colorTransform);
         this.shaftEffect = HealingGunShaftEffect(Game.getInstance().getObjectFromPool(HealingGunShaftEffect));
         this.shaftEffect.init(shaftAnimation,startPositionProvider,endPositionProvider);
      }
      
      public function start() : void
      {
         trace("ActiveIsisEffect::start()");
         var battleScene3D:BattleScene3D = Game.getInstance().getBattleScene3D();
         battleScene3D.addGraphicEffect(this.startEffect);
         battleScene3D.addGraphicEffect(this.endEffect);
         battleScene3D.addGraphicEffect(this.shaftEffect);
      }
      
      public function kill() : void
      {
         trace("ActiveIsisEffect::kill()");
         this.startEffect.kill();
         this.startEffect = null;
         this.endEffect.kill();
         this.endEffect = null;
         this.shaftEffect.kill();
         this.shaftEffect = null;
      }
   }
}
