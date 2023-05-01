package tanki2.systems.gameobjectssystem
{
   import tanki2.systems.SystemPriority;
   import tanki2.systems.SystemTags;
   import tanki2.systems.physicssystem.PhysicsSystem;
   import tanki2.systems.timesystem.TimeSystem;
   import tanki2.taskmanager.GameTask;
   import tanki2.utils.GOList;
   import tanki2.utils.GOListItem;
   
   public class GameObjectsSystem extends GameTask
   {
       
      
      private var timeSystem:TimeSystem;
      
      private var physicsSystem:PhysicsSystem;
      
      private var gameObjects:GOList;
      
      public function GameObjectsSystem(objects:GOList)
      {
         super(SystemPriority.OBJECTS,SystemTags.OBJECTS);
         this.gameObjects = objects;
      }
      
      override public function onStart() : void
      {
         this.timeSystem = TimeSystem(taskManager.getTaskByTag(SystemTags.TIME));
         this.physicsSystem = PhysicsSystem(taskManager.getTaskByTag(SystemTags.PHYSICS));
      }
      
      override public function run() : void
      {
         var goListItem:GOListItem = this.gameObjects.head;
         while(goListItem != null)
         {
            goListItem.gameObject.update(this.timeSystem.time,this.timeSystem.deltaTimeMs,this.timeSystem.deltaTime,this.physicsSystem.interpolationCoefficient);
            goListItem = goListItem.next;
         }
      }
   }
}
