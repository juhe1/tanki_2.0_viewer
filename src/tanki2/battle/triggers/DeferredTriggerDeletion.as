package tanki2.battle.triggers
{
   import tanki2.battle.DeferredAction;
   import tanki2.battle.Trigger;
   
   public class DeferredTriggerDeletion implements DeferredAction
   {
       
      
      private var triggers:Triggers;
      
      private var trigger:Trigger;
      
      public function DeferredTriggerDeletion(triggers:Triggers, trigger:Trigger)
      {
         super();
         this.triggers = triggers;
         this.trigger = trigger;
      }
      
      public function execute() : void
      {
         this.triggers.remove(this.trigger);
      }
   }
}
