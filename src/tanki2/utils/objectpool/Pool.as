package tanki2.utils.objectpool
{
   public class Pool
   {
       
      
      private var numObjects:int;
      
      private var objectClass:Class;
      
      private var objects:Vector.<Object>;
      
      public function Pool(objectClass:Class)
      {
         this.objects = new Vector.<Object>();
         super();
         this.objectClass = objectClass;
      }
      
      public final function getNumObjects() : int
      {
         return this.numObjects;
      }
      
      public final function getObject() : Object
      {
         if(this.numObjects == 0)
         {
            return new this.objectClass(this);
         }
         var object:Object = this.objects[--this.numObjects];
         this.objects[this.numObjects] = null;
         return object;
      }
      
      public final function putObject(object:Object) : void
      {
         if(this.objectClass != object.constructor)
         {
            throw new ArgumentError();
         }
         var _loc2_:* = this.numObjects++;
         this.objects[_loc2_] = object;
      }
      
      public final function clear() : void
      {
         this.objects.length = 0;
         this.numObjects = 0;
      }
   }
}
