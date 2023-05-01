package tanki2
{
   import tanki2.battle.Renderer;
   
   public class Renderers
   {
       
      
      private const renderers:Vector.<Renderer> = new Vector.<Renderer>();
      
      private const deferredCommands:Vector.<DeferredCommand> = new Vector.<DeferredCommand>();
      
      private var running:Boolean;
      
      public function Renderers()
      {
         super();
      }
      
      public function add(renderer:Renderer) : void
      {
         if(this.running)
         {
            this.deferredCommands.push(new DeferredAddition(this,renderer));
         }
         else
         {
            if(this.renderers.indexOf(renderer) > -1)
            {
               throw new Error("Already added");
            }
            this.renderers.push(renderer);
         }
      }
      
      public function remove(renderer:Renderer) : void
      {
         var len:int = 0;
         var i:int = 0;
         if(this.running)
         {
            this.deferredCommands.push(new DeferredRemoval(this,renderer));
         }
         else
         {
            len = this.renderers.length;
            if(len > 0)
            {
               i = this.renderers.indexOf(renderer);
               if(i > -1)
               {
                  this.renderers[i] = this.renderers[len - 1];
                  this.renderers.length = len - 1;
               }
            }
         }
      }
      
      public function run(time:int, timeDeltaMs:int) : void
      {
         var renderer:Renderer = null;
         this.running = true;
         for each(renderer in this.renderers)
         {
            renderer.render(time,timeDeltaMs);
         }
         this.running = false;
         this.runDeferredCommands();
      }
      
      private function runDeferredCommands() : void
      {
         var command:DeferredCommand = null;
         if(this.deferredCommands.length > 0)
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
import tanki2.Renderers;
import tanki2.battle.Renderer;

class DeferredAddition implements DeferredCommand
{
    
   
   private var renderers:Renderers;
   
   private var renderer:Renderer;
   
   function DeferredAddition(renderers:Renderers, renderer:Renderer)
   {
      super();
      this.renderers = renderers;
      this.renderer = renderer;
   }
   
   public function execute() : void
   {
      this.renderers.add(this.renderer);
   }
}

import tanki2.DeferredCommand;
import tanki2.Renderers;
import tanki2.battle.Renderer;

class DeferredRemoval implements DeferredCommand
{
    
   
   private var renderers:Renderers;
   
   private var renderer:Renderer;
   
   function DeferredRemoval(renderers:Renderers, renderer:Renderer)
   {
      super();
      this.renderers = renderers;
      this.renderer = renderer;
   }
   
   public function execute() : void
   {
      this.renderers.remove(this.renderer);
   }
}
