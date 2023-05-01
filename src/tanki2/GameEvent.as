package tanki2
{
   import flash.events.Event;
   
   public class GameEvent extends Event
   {
      
      public static const INIT_COMPLETE:String = "initComplete";
       
      
      public function GameEvent(type:String)
      {
         super(type);
      }
   }
}
