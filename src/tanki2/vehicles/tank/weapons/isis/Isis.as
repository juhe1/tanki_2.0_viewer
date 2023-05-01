package alternativa.tanks.vehicles.tank.weapons.isis
{
   import alternativa.tanks.vehicles.tank.weapons.Weapon;
   
   public class Isis extends Weapon
   {
      
      private static const effectTypes:Vector.<IsisEffectType> = Vector.<IsisEffectType>([IsisEffectType.IDLE,IsisEffectType.HEAL,IsisEffectType.DAMAGE]);
      
      private static var effects:Vector.<IsisEffects>;
       
      
      private var effectTypeIndex:int;
      
      private var effectIndex:int;
      
      private var currentEffect:IsisEffect;
      
      public function Isis()
      {
         super("Изида");
         if(effects == null)
         {
            initEffects();
         }
      }
      
      private static function initEffects() : void
      {
         var loader:IsisEffectsLoader = new IsisEffectsLoader();
         effects = loader.effects;
      }
      
      override protected function onStart() : void
      {
         this.currentEffect = effects[this.effectIndex].createEffect(effectTypes[this.effectTypeIndex],tank);
         this.currentEffect.start();
      }
      
      override protected function onStop() : void
      {
         this.currentEffect.kill();
         this.currentEffect = null;
         this.effectTypeIndex = (this.effectTypeIndex + 1) % effectTypes.length;
      }
      
      override public function setNextEffects() : void
      {
         this.effectIndex = (this.effectIndex + 1) % effects.length;
      }
      
      override public function setPrevEffects() : void
      {
         if(this.effectIndex == 0)
         {
            this.effectIndex = effects.length - 1;
         }
         else
         {
            --this.effectIndex;
         }
      }
      
      override public function getEffectsName() : String
      {
         return effects[this.effectIndex].name;
      }
   }
}
