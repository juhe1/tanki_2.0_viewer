package tanki2
{
   import tanki2.battle.PhysicsInterpolator;
   
   public class PhysicsInterpolators
   {
       
      
      private const interpolators:Vector.<PhysicsInterpolator> = new Vector.<PhysicsInterpolator>();
      
      public function PhysicsInterpolators()
      {
         super();
      }
      
      public function run(t:Number) : void
      {
         var interpolator:PhysicsInterpolator = null;
         for each(interpolator in this.interpolators)
         {
            interpolator.interpolatePhysicsState(t);
         }
      }
      
      public function add(interpolator:PhysicsInterpolator) : void
      {
         if(this.interpolators.indexOf(interpolator) > -1)
         {
            throw new Error("Interpolator is already added");
         }
         this.interpolators.push(interpolator);
      }
      
      public function remove(interpolator:PhysicsInterpolator) : void
      {
         var index:int = 0;
         var num:uint = this.interpolators.length;
         if(num > 0)
         {
            index = this.interpolators.indexOf(interpolator);
            if(index > -1)
            {
               this.interpolators[index] = this.interpolators[num - 1];
               this.interpolators.length = num - 1;
            }
         }
      }
   }
}
