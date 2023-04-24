package tanki2.systems
{
   public class SystemPriority
   {
      
      public static const TIME:int = 0;
      
      public static const LOGIC:int = 1000;
      
      public static const OBJECT_CONTROLLERS:int = 2000;
      
      public static const PHYSICS:int = 3000;
      
      public static const OBJECTS:int = 4000;
      
      public static const RENDER:int = 5000;
      
      public static const TANK_PARAMS_PRINTER:int = 6000;
       
      
      public function SystemPriority()
      {
         super();
      }
   }
}
