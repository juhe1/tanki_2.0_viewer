package tanki2.taskmanager
{
   public class GameTask
   {
       
      
      public var taskManager:TaskManager;
      
      public var priority:int;
      
      public var tag:String;
      
      protected var _paused:Boolean;
      
      public function GameTask(priority:int, tag:String)
      {
         super();
         this.priority = priority;
         this.tag = tag;
      }
      
      public function onStart() : void
      {
      }
      
      public function onStop() : void
      {
      }
      
      public function run() : void
      {
      }
      
      public final function get paused() : Boolean
      {
         return this._paused;
      }
      
      public final function set paused(value:Boolean) : void
      {
         if(value)
         {
            this.pause();
         }
         else
         {
            this.resume();
         }
      }
      
      public final function pause() : void
      {
         if(!this._paused)
         {
            this._paused = true;
            this.onPause();
         }
      }
      
      public final function resume() : void
      {
         if(this._paused)
         {
            this._paused = false;
            this.onResume();
         }
      }
      
      protected function onPause() : void
      {
      }
      
      protected function onResume() : void
      {
      }
   }
}
