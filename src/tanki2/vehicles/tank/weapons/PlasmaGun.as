package tanki2.vehicles.tank.weapons
{
   import alternativa.engine3d.materials.TextureMaterial;
   import alternativa.math.Vector3;
   import alternativa.physics.Body;
   import alternativa.tanks.Game;
   import alternativa.tanks.config.Config;
   import alternativa.tanks.sfx.AnimatedSpriteEffect;
   import alternativa.tanks.sfx.StaticObject3DPositionProvider;
   import alternativa.tanks.sfx.TextureAnimation;
   import alternativa.tanks.vehicles.tank.weapons.sfx.PlasmaShot;
   import alternativa.tanks.vehicles.tank.weapons.sfx.ShotFlashEffect;
   import flash.display.BitmapData;
   
   public class PlasmaGun extends Weapon implements IPlasmaShotListener
   {
      
      private static const FLASH_OFFSET:int = 10;
      
      public static const FLASH_SIZE:int = 120;
      
      private static const FLASH_LIFE_TIME:int = 100;
      
      private static const FLASH_FADE_TIME:int = 50;
       
      
      private const firePeriod:int = 500;
      
      private var shotSpeed:Number = 50;
      
      private var shotTravelDistance:Number = 30;
      
      private var shotFadeDistance:Number = 20;
      
      private var readyTime:int;
      
      private const plasmaGunData:PlasmaGunData = new PlasmaGunData(this.shotTravelDistance * 100,this.shotFadeDistance * 100,this.shotSpeed * 100,20);
      
      private var muzzleFlashMaterial:TextureMaterial;
      
      public function PlasmaGun()
      {
         super("Твинс");
         var game:Game = Game.getInstance();
         var muzzleFlash:BitmapData = game.config.textureLibrary.getTexture("plasma/muzzle_flash");
         this.muzzleFlashMaterial = new TextureMaterial(muzzleFlash);
      }
      
      override public function update(time:int, delta:int) : void
      {
         if(active && time >= this.readyTime)
         {
            this.readyTime = time + this.firePeriod;
            this.fire();
            barrelDirection.scale(-300000000);
         }
      }
      
      public function shotDissolved(shot:PlasmaShot) : void
      {
      }
      
      public function shotHit(shot:PlasmaShot, hitPoint:Vector3, hitDir:Vector3, body:Body, scaleFactor:Number) : void
      {
         var baseScale:Number = 3;
         var scale:Number = baseScale * (1 + scaleFactor) * 0.5;
         var game:Game = Game.getInstance();
         var explosion:AnimatedSpriteEffect = AnimatedSpriteEffect(game.getObjectFromPool(AnimatedSpriteEffect));
         var animation:TextureAnimation = game.config.textureAnimations.getAnimation("plasma/explosion");
         explosion.init(100 * scale,100 * scale,animation,Math.random() * Math.PI,StaticObject3DPositionProvider.create(hitPoint,50));
         game.getBattleScene3D().addGraphicEffect(explosion);
      }
      
      private function fire() : void
      {
         calculateTurretParams();
         this.createMuzzleFlash();
         this.createShot();
      }
      
      private function createMuzzleFlash() : void
      {
         var game:Game = Game.getInstance();
         var config:Config = game.config;
         var graphicEffect:ShotFlashEffect = ShotFlashEffect(game.getObjectFromPool(ShotFlashEffect));
         var planeWidth:Number = config.getNumber("plasma.muzzleFlash.width");
         var planeLength:Number = config.getNumber("plasma.muzzleFlash.length");
         graphicEffect.init(tank.turret.muzzlePoints[0],tank.skin.turretMesh,this.muzzleFlashMaterial,FLASH_LIFE_TIME,planeWidth,planeLength);
         game.getBattleScene3D().addGraphicEffect(graphicEffect);
      }
      
      private function createShot() : void
      {
         var game:Game = Game.getInstance();
         var shot:PlasmaShot = PlasmaShot(game.getObjectFromPool(PlasmaShot));
         shot.init(this.plasmaGunData,tank.skin.getGlobalMuzzlePosition(0),barrelDirection,game.getCollisionDetector(),this);
         game.logicUnitsSystem.add(shot);
      }
   }
}
