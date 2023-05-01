package alternativa.tanks.vehicles.tank.weapons.flamethrower
{
   import alternativa.tanks.Game;
   import alternativa.tanks.config.Config;
   import alternativa.tanks.vehicles.tank.weapons.Weapon;
   import alternativa.tanks.vehicles.tank.weapons.WeaponTextureAnimations;
   import alternativa.tanks.vehicles.tank.weapons.sfx.MuzzleStreamEffect;
   
   public class FlameThrower extends Weapon
   {
      
      private static const RANGE:Number = 2000;
      
      private static const MAX_PARTICLES:int = 20;
      
      private static const PARTICLE_SPEED:Number = 2000;
      
      private static const colorTarnsforms:Vector.<ColorTransformEntry> = Vector.<ColorTransformEntry>([new ColorTransformEntry(0,1,1,1,1,100,150,100,0),new ColorTransformEntry(0.05,1,1,1,1,50,100,60,0),new ColorTransformEntry(0.1,1,1,1,1,100,100,40,0),new ColorTransformEntry(0.65,0.5,0.3,0.3,1,50,80,50,0),new ColorTransformEntry(0.75,0,0,0,1,50,50,50,0),new ColorTransformEntry(1,0,0,0,0,20,20,20,0)]);
       
      
      private const CONE_ANGLE:Number = 0.15;
      
      private var flameEffect:FlamethrowerGraphicEffect;
      
      private var muzzleEffect:MuzzleStreamEffect;
      
      private var animations:WeaponTextureAnimations;
      
      public function FlameThrower()
      {
         super("Ближнебойные");
         this.animations = new WeaponTextureAnimations(Game.getInstance().config.xml.flamethrower.animation);
      }
      
      override public function start() : void
      {
         var game:Game = null;
         var config:Config = null;
         var width:Number = NaN;
         var length:Number = NaN;
         if(this.flameEffect == null)
         {
            game = Game.getInstance();
            this.flameEffect = FlamethrowerGraphicEffect(game.getObjectFromPool(FlamethrowerGraphicEffect));
            this.flameEffect.init(tank.chassis,RANGE,this.CONE_ANGLE,MAX_PARTICLES,PARTICLE_SPEED,tank.skin.getTurret().muzzlePoints[0],tank.skin.turretMesh,game.getCollisionDetector(),this.animations.getCurrentAnimation().textureAnimation,colorTarnsforms);
            game.getBattleScene3D().addGraphicEffect(this.flameEffect);
            this.muzzleEffect = MuzzleStreamEffect(game.getObjectFromPool(MuzzleStreamEffect));
            config = game.config;
            width = Number(config.xml.flamethrower.muzzlePlane.width);
            length = Number(config.xml.flamethrower.muzzlePlane.length);
            this.muzzleEffect.init(width,length,config.textureAnimations.getAnimation("flame_stream"),tank.skin.turretMesh,tank.turret.muzzlePoints[0]);
            game.getBattleScene3D().addGraphicEffect(this.muzzleEffect);
         }
      }
      
      override public function stop() : void
      {
         if(this.flameEffect != null)
         {
            this.flameEffect.kill();
            this.flameEffect = null;
            this.muzzleEffect.kill();
            this.muzzleEffect = null;
         }
      }
      
      override public function setNextEffects() : void
      {
         this.animations.nextAnimation();
      }
      
      override public function setPrevEffects() : void
      {
         this.animations.prevAnimation();
      }
      
      override public function getEffectsName() : String
      {
         return this.animations.getCurrentAnimation().textureAnimation.animationId;
      }
   }
}
