package tanki2.taskmanager
{
   import tanki2.utils.list.List;
   import tanki2.utils.list.ListIterator;
   import flash.utils.Dictionary;
   
   public class TaskManager
   {
       
      
      private const activeTasks:List = new List();
      
      private const addedTasks:Dictionary = new Dictionary();
      
      private const killedTasks:Dictionary = new Dictionary();
      
      private const taskByTag:Dictionary = new Dictionary();
      
      public function TaskManager()
      {
         super();
      }
      
      public function isTaskExist(tag:String) : Boolean
      {
         return this.taskByTag[tag] != null;
      }
      
      public function getTaskByTag(tag:String) : GameTask
      {
         if(this.taskByTag[tag] == null)
         {
            throw new TagNotFoundError(tag);
         }
         return this.taskByTag[tag];
      }
      
      public function addTask(task:GameTask) : void
      {
         if(this.taskByTag[task.tag] != null)
         {
            throw new TagAlreadyExistsError(task.tag);
         }
         if(this.activeTasks.contains(task))
         {
            throw new TaskAlreadyActiveError();
         }
         if(this.addedTasks[task] != null)
         {
            throw new TaskAlreadyScheduledError();
         }
         this.addedTasks[task] = true;
         this.taskByTag[task.tag] = task;
      }
      
      public function killTask(task:GameTask) : void
      {
         if(this.activeTasks.contains(task) && this.killedTasks[task] == null)
         {
            this.killedTasks[task] = true;
         }
      }
      
      public function killTaskWithTag(tag:String) : void
      {
         var task:GameTask = this.taskByTag[tag];
         if(task != null)
         {
            if(this.activeTasks.contains(task) && this.killedTasks[task] == null)
            {
               this.killedTasks[task] = true;
            }
         }
      }
      
      public function runTasks() : void
      {
         var task:GameTask = null;
         this.startAddedTasks();
         var iterator:ListIterator = this.activeTasks.listIterator();
         while(iterator.hasNext())
         {
            task = GameTask(iterator.next());
            if(!task.paused)
            {
               task.run();
            }
         }
         this.removeKilledTasks();
      }
      
      public function killAll() : void
      {
         var task:GameTask = null;
         var listIterator:ListIterator = this.activeTasks.listIterator();
         while(listIterator.hasNext())
         {
            task = GameTask(listIterator.next());
            this.killTask(task);
         }
      }
      
      private function startAddedTasks() : void
      {
         var key:* = undefined;
         var task:GameTask = null;
         for(key in this.addedTasks)
         {
            delete this.addedTasks[key];
            task = key;
            task.taskManager = this;
            task.onStart();
            this.insertActiveTask(task);
         }
      }
      
      private function insertActiveTask(task:GameTask) : void
      {
         var activeTask:GameTask = null;
         var iterator:ListIterator = this.activeTasks.listIterator();
         while(iterator.hasNext())
         {
            activeTask = GameTask(iterator.next());
            if(activeTask.priority > task.priority)
            {
               iterator.previous();
               break;
            }
         }
         iterator.add(task);
      }
      
      private function removeKilledTasks() : void
      {
         var key:* = undefined;
         var task:* = null;
         for(task in this.killedTasks)
         {
            this.activeTasks.remove(task);
            task.onStop();
            task.taskManager = null;
            delete this.killedTasks[key];
            delete this.taskByTag[task.tag];
         }
      }
   }
}
