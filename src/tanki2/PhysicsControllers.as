package tanki2
{
   import tanki2.battle.PhysicsController;
   
   public class PhysicsControllers
   {
       
      
      private var controllers:Vector.<PhysicsController>;
      
      private var running:Boolean;
      
      private var deferredCommands:Vector.<DeferredCommand>;
      
      public function PhysicsControllers()
      {
         this.controllers = new Vector.<PhysicsController>();
         this.deferredCommands = new Vector.<DeferredCommand>();
         super();
      }
      
      public function add(controller:PhysicsController) : void
      {
         if(this.running)
         {
            this.deferredCommands.push(new DeferredAddition(this,controller));
         }
         else if(this.controllers.indexOf(controller) < 0)
         {
            this.controllers.push(controller);
         }
      }
      
      public function remove(controller:PhysicsController) : void
      {
         var num:int = 0;
         var i:int = 0;
         if(this.running)
         {
            this.deferredCommands.push(new DeferredRemoval(this,controller));
         }
         else
         {
            num = this.controllers.length;
            if(num > 0)
            {
               i = this.controllers.indexOf(controller);
               if(i >= 0)
               {
                  this.controllers[i] = this.controllers[num - 1];
                  this.controllers.length = num - 1;
               }
            }
         }
      }
      
      public function run(dt:Number) : void
      {
         var controller:PhysicsController = null;
         this.running = true;
         for each(controller in this.controllers)
         {
            controller.runBeforePhysicsUpdate(dt);
         }
         this.running = false;
         this.runDeferredCommands();
      }
      
      private function runDeferredCommands() : void
      {
         var command:DeferredCommand = null;
         var len:int = this.deferredCommands.length;
         if(len > 0)
         {
            for each(command in this.deferredCommands)
            {
               command.execute();
            }
            this.deferredCommands.length = 0;
         }
      }
   }
}

import tanki2.DeferredCommand;
import tanki2.PhysicsControllers;
import tanki2.battle.PhysicsController;

class DeferredAddition implements DeferredCommand
{
    
   
   private var controllers:PhysicsControllers;
   
   private var controller:PhysicsController;
   
   function DeferredAddition(controllers:PhysicsControllers, controller:PhysicsController)
   {
      super();
      this.controllers = controllers;
      this.controller = controller;
   }
   
   public function execute() : void
   {
      this.controllers.add(this.controller);
   }
}

import tanki2.DeferredCommand;
import tanki2.PhysicsControllers;
import tanki2.battle.PhysicsController;

class DeferredRemoval implements DeferredCommand
{
    
   
   private var controllers:PhysicsControllers;
   
   private var controller:PhysicsController;
   
   function DeferredRemoval(controllers:PhysicsControllers, controller:PhysicsController)
   {
      super();
      this.controllers = controllers;
      this.controller = controller;
   }
   
   public function execute() : void
   {
      this.controllers.remove(this.controller);
   }
}
