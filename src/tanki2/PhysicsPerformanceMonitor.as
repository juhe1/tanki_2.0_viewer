package tanki2
{
   import tanki2.display.DebugPanel;
   import flash.utils.getTimer;
   
   public class PhysicsPerformanceMonitor
   {
       
      
      private const PHYSICS_FRAME_SAMPLES:int = 30;
      
      private var physicsFrameCounter:int;
      
      private var physicsFrameAccumulatedTime:Number = 0;
      
      private var debugPanel:DebugPanel;
      
      public function PhysicsPerformanceMonitor(debugPanel:DebugPanel)
      {
         super();
         this.debugPanel = debugPanel;
      }
      
      public function update(startTime:int) : void
      {
         var pt:Number = NaN;
         this.physicsFrameAccumulatedTime += getTimer() - startTime;
         ++this.physicsFrameCounter;
         if(this.physicsFrameCounter >= this.PHYSICS_FRAME_SAMPLES)
         {
            pt = this.physicsFrameAccumulatedTime / this.physicsFrameCounter;
            this.debugPanel.printValue("Physics time",pt.toFixed(2));
            this.debugPanel.printValue("Physics fps",Number(1000 / pt).toFixed(2));
            this.physicsFrameCounter = 0;
            this.physicsFrameAccumulatedTime = 0;
         }
      }
   }
}
