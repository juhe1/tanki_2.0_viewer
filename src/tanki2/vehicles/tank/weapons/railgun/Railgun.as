package alternativa.tanks.vehicles.tank.weapons.railgun
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.RayIntersectionData;
   import alternativa.engine3d.materials.TextureMaterial;
   import alternativa.math.Vector3;
   import alternativa.physics.collision.types.RayHit;
   import alternativa.tanks.Game;
   import alternativa.tanks.battle.BattleService;
   import alternativa.tanks.config.Config;
   import alternativa.tanks.sfx.AnimatedPlaneEffect;
   import alternativa.tanks.sfx.AnimatedSpriteEffect;
   import alternativa.tanks.sfx.StaticObject3DPositionProvider;
   import alternativa.tanks.sfx.TextureAnimation;
   import alternativa.tanks.vehicles.tank.weapons.SpriteAnimation;
   import alternativa.tanks.vehicles.tank.weapons.Weapon;
   import alternativa.tanks.vehicles.tank.weapons.WeaponTextureAnimations;
   import flash.geom.Vector3D;
   
   public class Railgun extends Weapon
   {
      
      private static var chargeSpriteSize:Number;
      
      private static var chargeAnimation:TextureAnimation;
      
      private static var sfxParams:Vector.<RailgunSFXData>;
      
      private static var beamMaterial:TextureMaterial;
       
      
      private var charging:Boolean;
      
      private var nextReadyTime:int;
      
      private var chargeTime:int = 1000;
      
      private var reloadTime:int = 0;
      
      private var sfxParamsIndex:int;
      
      private var explosionAnimations:WeaponTextureAnimations;
      
      private var battleService:BattleService;
      
      public function Railgun(battleService:BattleService)
      {
         super("Railgun");
         this.battleService = battleService;
         if(chargeAnimation == null)
         {
            initEffects();
         }
         this.explosionAnimations = new WeaponTextureAnimations(Game.getInstance().config.xml.railgun.animation);
      }
      
      private static function initEffects() : void
      {
         var railgunSFXLoader:RailgunSFXLoader = new RailgunSFXLoader();
         chargeAnimation = railgunSFXLoader.chargeAnimation;
         sfxParams = railgunSFXLoader.sfxParams;
         chargeSpriteSize = railgunSFXLoader.chargeSpriteSize;
         beamMaterial = railgunSFXLoader.beamMaterial;
      }
      
      override public function setNextEffects() : void
      {
         this.sfxParamsIndex = (this.sfxParamsIndex + 1) % sfxParams.length;
      }
      
      override public function setPrevEffects() : void
      {
         if(this.sfxParamsIndex == 0)
         {
            this.sfxParamsIndex = sfxParams.length - 1;
         }
         else
         {
            --this.sfxParamsIndex;
         }
      }
      
      override public function getEffectsName() : String
      {
         return sfxParams[this.sfxParamsIndex].id;
      }
      
      override public function update(time:int, delta:int) : void
      {
         if(this.charging)
         {
            if(this.nextReadyTime < time)
            {
               this.shoot(time);
            }
         }
         else if(active && this.nextReadyTime < time)
         {
            this.startCharging(time);
         }
      }
      
      private function shoot(time:int) : void
      {
         this.charging = false;
         this.nextReadyTime = time + this.reloadTime;
         this.createShotEffect();
      }
      
      private function createShotEffect() : void
      {
         var game:Game = null;
         var powEffect:FixedBeamEffect = null;
         var dir:Vector3D = null;
         var obj:Object3D = null;
         var pos:Vector3D = null;
         var objPos:Vector3D = null;
         var pos3:Vector3 = null;
         var rotation:Vector3 = null;
         var config:Config = null;
         game = Game.getInstance();
         var effect:BeamEffect = BeamEffect(game.getObjectFromPool(BeamEffect));
         powEffect = FixedBeamEffect(game.getObjectFromPool(FixedBeamEffect));
         var sfxParam:RailgunSFXData = sfxParams[this.sfxParamsIndex];
         calculateTurretParams();
         var rayHit:RayHit = new RayHit();
         var beamLength:Number = 100000;
         var orig:Vector3D = new Vector3D();
         dir = new Vector3D();
         muzzlePosition.toVector3D(orig);
         barrelDirection.toVector3D(dir);
         var rayData:RayIntersectionData = Game.getInstance().config.map.mapContainer.intersectRay(orig,dir);
         if(Game.getInstance().getCollisionDetector().raycastStatic(muzzlePosition,barrelDirection,255,10000000000,null,rayHit))
         {
            beamLength = rayHit.t;
            obj = rayData.object;
            pos = obj.localToGlobal(rayData.point);
            dir = obj.localToGlobal(rayData.face.normal);
            objPos = new Vector3D(obj.x,obj.y,obj.z);
            objPos = obj.parent.localToGlobal(objPos);
            dir = dir.subtract(objPos);
            dir.scaleBy(5);
            pos = pos.add(dir);
            pos3 = new Vector3();
            pos3.copyFromVector3D(pos);
            rotation = new Vector3();
            rotation.x = Math.atan2(dir.z,Math.sqrt(dir.x * dir.x + dir.y * dir.y));
            rotation.y = 0;
            rotation.z = -Math.atan2(dir.x,dir.y);
            rotation.x -= Math.PI / 2;
            this.createExplosion(pos3,rotation);
            config = game.config;
            trace("len",dir.length);
            pos3.copyFromVector3D(pos);
            powEffect.init(muzzlePosition,pos3,config.textureAnimations.getAnimation("railgun_pow").fps,config.textureAnimations.getAnimation("railgun_pow"));
            this.battleService.getBattleScene3D().addGraphicEffect(powEffect);
         }
         var endPoint:Vector3 = muzzlePosition.clone().addScaled(beamLength,barrelDirection);
         effect.init(muzzlePosition,endPoint,beamMaterial,sfxParam.maxBeamScale,sfxParam.beamLifeTime,sfxParam.colorTransform);
         this.battleService.getBattleScene3D().addGraphicEffect(effect);
      }
      
      private function createExplosion(position:Vector3, rotation:Vector3) : void
      {
         var game:Game = Game.getInstance();
         var spriteAnimation:SpriteAnimation = this.explosionAnimations.getCurrentAnimation();
         var positionProvider:StaticObject3DPositionProvider = StaticObject3DPositionProvider(game.getObjectFromPool(StaticObject3DPositionProvider));
         positionProvider.init(position,50);
         var effect2:AnimatedSpriteEffect = AnimatedSpriteEffect(game.getObjectFromPool(AnimatedSpriteEffect));
         effect2.init(spriteAnimation.frameSize / 2,spriteAnimation.frameSize / 2,spriteAnimation.textureAnimation,0,positionProvider);
         this.battleService.getBattleScene3D().addGraphicEffect(effect2);
         var effect:AnimatedPlaneEffect = AnimatedPlaneEffect(game.getObjectFromPool(AnimatedPlaneEffect));
         effect.init(spriteAnimation.frameSize,position,rotation,40,spriteAnimation.textureAnimation,0);
         this.battleService.getBattleScene3D().addGraphicEffect(effect);
      }
      
      private function startCharging(time:int) : void
      {
         this.charging = true;
         this.nextReadyTime = time + this.chargeTime;
         this.createChargeEffect();
      }
      
      private function createChargeEffect() : void
      {
         var game:Game = Game.getInstance();
         var effect:ChargeEffect = ChargeEffect(game.getObjectFromPool(ChargeEffect));
         var sfxParam:RailgunSFXData = sfxParams[this.sfxParamsIndex];
         effect.init(chargeSpriteSize,chargeSpriteSize,chargeAnimation,tank.turret.muzzlePoints[0],tank.skin.turretMesh,0,sfxParam.colorTransform);
         this.battleService.getBattleScene3D().addGraphicEffect(effect);
      }
   }
}
