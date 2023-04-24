package tanki2.physics
{
   public class CollisionGroup
   {
      
      public static const TANK:int = 1;
      
      public static const ACTIVE_TRACK:int = 2;
      
      public static const INACTIVE_TRACK:int = 4;
      
      public static const WEAPON:int = 16;
      
      public static const CAMERA:int = 32;
      
      public static const STATIC:int = 64;
      
      public static const BONUS_WITH_TANK:int = 256;
       
      
      public function CollisionGroup()
      {
         super();
      }
   }
}
