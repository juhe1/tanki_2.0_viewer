package alternativa.utils
{
   import flash.utils.ByteArray;
   
   public class TARAParser
   {
      
      private var files:Object;
      
      public function TARAParser(param1:ByteArray)
      {
         super();
         if(param1 != null)
         {
            this.parse(param1);
         }
      }
      
      public function parse(param1:ByteArray) : void
      {
         var _loc4_:int = 0;
         var _loc5_:ByteArray = null;
         var _loc6_:FileInfo = null;
         var _loc2_:int = param1.readInt();
         var _loc3_:Vector.<FileInfo> = new Vector.<FileInfo>(_loc2_);
         _loc4_ = 0;
         while(_loc4_ < _loc2_)
         {
            _loc3_[_loc4_] = new FileInfo(param1.readUTF(),param1.readInt());
            _loc4_++;
         }
         this.files = {};
         _loc4_ = 0;
         while(_loc4_ < _loc2_)
         {
            _loc5_ = new ByteArray();
            _loc6_ = _loc3_[_loc4_];
            param1.readBytes(_loc5_,0,_loc6_.size);
            this.files[_loc6_.name] = _loc5_;
            _loc4_++;
         }
      }
      
      public function get data() : Object
      {
         return this.files;
      }
      
      public function getFileByName(param1:String) : ByteArray
      {
         if(this.files == null)
         {
            return null;
         }
         return ByteArray(this.files[param1]);
      }
   }
}

class FileInfo
{
    
   
   public var name:String;
   
   public var size:int;
   
   function FileInfo(param1:String, param2:int)
   {
      super();
      this.name = param1;
      this.size = param2;
   }
}
