package tanki2.battle.triggers
{
   import alternativa.physics.Body;
   import tanki2.battle.DeferredAction;
   import tanki2.battle.Trigger;
   
   public class Triggers
   {
       
      
      private const _triggers:Vector.<Trigger> = new Vector.<Trigger>();
      
      private const deferredActions:Vector.<DeferredAction> = new Vector.<DeferredAction>();
      
      private var running:Boolean;
      
      public function Triggers()
      {
         super();
      }
      
      public function add(trigger:Trigger) : void
      {
         if(this.running)
         {
            this.deferredActions.push(new DeferredTriggerAddition(this,trigger));
         }
         else if(this._triggers.indexOf(trigger) < 0)
         {
            this._triggers.push(trigger);
         }
      }
      
      public function remove(trigger:Trigger) : void
      {
         var num:int = 0;
         var i:int = 0;
         if(this.running)
         {
            this.deferredActions.push(new DeferredTriggerDeletion(this,trigger));
         }
         else
         {
            num = this._triggers.length;
            if(num > 0)
            {
               i = this._triggers.indexOf(trigger);
               if(i >= 0)
               {
                  this._triggers[i] = this._triggers[--num];
                  this._triggers.length = num;
               }
            }
         }
      }
      
      public function check(localBody:Body) : void
      {
         var numTriggers:int = 0;
         var i:int = 0;
         var trigger:Trigger = null;
         if(localBody != null)
         {
            this.running = true;
            numTriggers = this._triggers.length;
            for(i = 0; i < numTriggers; i++)
            {
               trigger = this._triggers[i];
               trigger.checkTrigger(localBody);
            }
            this.running = false;
            this.executeDeferredActions();
         }
      }
      
      private function executeDeferredActions() : void
      {
         var action:DeferredAction = null;
         while((action = this.deferredActions.pop()) != null)
         {
            action.execute();
         }
      }
   }
}
