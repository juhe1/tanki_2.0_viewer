package tanki2.maploader 
{
	/**
    * ...
    * @author juhe
    */
   
   import flash.utils.ByteArray;
    
   public class MapData 
   {
      
      private var _data:Object;
      
      public function MapData(data:Object = null) 
      {
         super();
         this._data = data == null ? {} : data;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function getFileByName(key:String) : ByteArray
      {
         return this.data[key];
      }
      
      public function setFileDataByName(key:String, value:ByteArray) : void
      {
         this.data[key] = value;
      }
   }

}