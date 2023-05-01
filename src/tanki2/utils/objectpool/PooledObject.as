package tanki2.utils.objectpool
{
   public class PooledObject
   {
       
      
      private var pool:Pool;
      
      public function PooledObject(pool:Pool)
      {
         super();
         this.pool = pool;
      }
      
      public final function recycle() : void
      {
         this.pool.putObject(this);
      }
   }
}
