package alternativa.tanks.vehicles.tank.weapons.isis
{
   import alternativa.tanks.Game;
   import alternativa.tanks.sfx.TextureAnimation;
   import alternativa.tanks.vehicles.tank.weapons.ColoredSpriteAnimation;
   import alternativa.tanks.vehicles.tank.weapons.SpriteAnimation;
   import alternativa.tanks.vehicles.tank.weapons.WeaponUtils;
   
   public class IsisEffectsLoader
   {
       
      
      public var effects:Vector.<IsisEffects>;
      
      public function IsisEffectsLoader()
      {
         var effectXML:XML = null;
         var effectName:String = null;
         var idleSpark:SpriteAnimation = null;
         var healStart:ColoredSpriteAnimation = null;
         var healEnd:ColoredSpriteAnimation = null;
         var healShaft:IsisShaftAnimation = null;
         var damageStart:ColoredSpriteAnimation = null;
         var damageEnd:ColoredSpriteAnimation = null;
         var damageShaft:IsisShaftAnimation = null;
         this.effects = new Vector.<IsisEffects>();
         super();
         for each(effectXML in Game.getInstance().config.xml.isis.effect)
         {
            effectName = effectXML.@id;
            idleSpark = readSpriteAnimation(effectXML.idleSpark[0]);
            healStart = readSpriteAnimation(effectXML.healStart[0]);
            healEnd = readSpriteAnimation(effectXML.healEnd[0]);
            healShaft = readShaftAnimation(effectXML.healShaft[0]);
            damageStart = readSpriteAnimation(effectXML.damageStart[0]);
            damageEnd = readSpriteAnimation(effectXML.damageEnd[0]);
            damageShaft = readShaftAnimation(effectXML.damageShaft[0]);
            this.effects.push(new IsisEffects(effectName,idleSpark,healStart,healEnd,healShaft,damageStart,damageEnd,damageShaft));
         }
      }
      
      private static function readSpriteAnimation(xml:XML) : ColoredSpriteAnimation
      {
         var frameSize:Number = Number(xml.@frameSize);
         var animation:TextureAnimation = Game.getInstance().config.textureAnimations.getAnimation(xml.@animationId);
         return new ColoredSpriteAnimation(frameSize,animation,WeaponUtils.parseColorTransform(xml));
      }
      
      private static function readShaftAnimation(xml:XML) : IsisShaftAnimation
      {
         var width:Number = Number(xml.@width);
         var animation:TextureAnimation = Game.getInstance().config.textureAnimations.getAnimation(xml.@animationId);
         return new IsisShaftAnimation(width,animation,WeaponUtils.parseColorTransform(xml));
      }
   }
}
