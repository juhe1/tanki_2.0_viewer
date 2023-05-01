package tanki2.vehicles.tank.weapons
{
   import flash.geom.ColorTransform;
   
   public class WeaponUtils
   {
       
      
      public function WeaponUtils()
      {
         super();
      }
      
      public static function parseColorTransform(xml:XML) : ColorTransform
      {
         return new ColorTransform(Number(xml.@rm),Number(xml.@gm),Number(xml.@bm),Number(xml.@am),Number(xml.@ro),Number(xml.@go),Number(xml.@bo),Number(xml.@ao));
      }
   }
}
