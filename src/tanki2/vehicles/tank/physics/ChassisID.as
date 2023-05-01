package tanki2.vehicles.tank.physics
{
   import tanki2.utils.BitMask;
   
   public class ChassisID
   {
      
      private static const MAX_IDS:int = 32;
      
      private static const instance:ChassisID = new ChassisID();
       
      
      private const freeIds:BitMask = new BitMask(4294967295);
      
      private const ids:Vector.<int> = new Vector.<int>();
      
      public function ChassisID()
      {
         super();
         for(var i:int = 0; i < MAX_IDS; i++)
         {
            this.ids[i] = MAX_IDS - 1 - i;
         }
      }
      
      public static function getId() : int
      {
         return instance.get();
      }
      
      public static function releaseId(value:int) : void
      {
         instance.release(value);
      }
      
      public function get() : int
      {
         if(this.ids.length == 0)
         {
            throw new Error("No ids left");
         }
         var id:int = this.ids.pop();
         this.freeIds.clearBit(id);
         return id;
      }
      
      public function release(id:int) : void
      {
         if(id < 0 || id > MAX_IDS - 1)
         {
            throw new ArgumentError("Id " + id + " is out of bounds [0," + MAX_IDS + ")");
         }
         if(this.freeIds.getBitValue(id) == 0)
         {
            this.freeIds.setBit(id);
            this.ids.push(id);
         }
      }
   }
}
