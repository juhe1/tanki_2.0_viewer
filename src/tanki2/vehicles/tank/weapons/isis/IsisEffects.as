package alternativa.tanks.vehicles.tank.weapons.isis
{
   import alternativa.tanks.vehicles.tank.Tank;
   import alternativa.tanks.vehicles.tank.weapons.ColoredSpriteAnimation;
   import alternativa.tanks.vehicles.tank.weapons.SpriteAnimation;
   
   public class IsisEffects
   {
       
      
      public var name:String;
      
      private var idleSpark:SpriteAnimation;
      
      private var healStart:ColoredSpriteAnimation;
      
      private var healEnd:ColoredSpriteAnimation;
      
      private var healShaft:IsisShaftAnimation;
      
      private var damageStart:ColoredSpriteAnimation;
      
      private var damageEnd:ColoredSpriteAnimation;
      
      private var damageShaft:IsisShaftAnimation;
      
      public function IsisEffects(name:String, idleSpark:SpriteAnimation, healStart:ColoredSpriteAnimation, healEnd:ColoredSpriteAnimation, healShaft:IsisShaftAnimation, damageStart:ColoredSpriteAnimation, damageEnd:ColoredSpriteAnimation, damageShaft:IsisShaftAnimation)
      {
         super();
         this.name = name;
         this.idleSpark = idleSpark;
         this.healStart = healStart;
         this.healEnd = healEnd;
         this.healShaft = healShaft;
         this.damageStart = damageStart;
         this.damageEnd = damageEnd;
         this.damageShaft = damageShaft;
      }
      
      public function createEffect(isisEffectType:IsisEffectType, tank:Tank) : IsisEffect
      {
         switch(isisEffectType)
         {
            case IsisEffectType.IDLE:
               return new IdleIsisEffect(this.idleSpark,tank);
            case IsisEffectType.HEAL:
               return new ActiveIsisEffect(this.healStart,this.healEnd,this.healShaft,tank);
            case IsisEffectType.DAMAGE:
               return new ActiveIsisEffect(this.damageStart,this.damageEnd,this.damageShaft,tank);
            default:
               throw new ArgumentError();
         }
      }
   }
}
