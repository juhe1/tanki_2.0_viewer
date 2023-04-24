package alternativa.tanks.utils.objectpool
{
   import flash.utils.Dictionary;
   
   public class ObjectPool
   {
       
      
      private var pools:Dictionary;
      
      public function ObjectPool()
      {
         this.pools = new Dictionary();
         super();
      }
      
      public function getObject(objectClass:Class) : Object
      {
         return this.getPoolForClass(objectClass).getObject();
      }
      
      public function clear() : void
      {
         var key:* = undefined;
         for(key in this.pools)
         {
            Pool(this.pools[key]).clear();
            delete this.pools[key];
         }
      }
      
      [Obfuscation(rename="false")]
      public function toString() : String
      {
         var cls:* = undefined;
         var pool:Pool = null;
         var s:String = "";
         for(cls in this.pools)
         {
            pool = this.pools[cls];
            s += cls + ": " + pool.getNumObjects() + "\n";
         }
         return s;
      }
      
      private function getPoolForClass(objectClass:Class) : Pool
      {
         var pool:Pool = this.pools[objectClass];
         if(pool == null)
         {
            pool = new Pool(objectClass);
            this.pools[objectClass] = pool;
         }
         return pool;
      }
   }
}
