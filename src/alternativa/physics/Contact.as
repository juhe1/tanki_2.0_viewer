package alternativa.physics
{
   import alternativa.math.Vector3;
   
   public class Contact
   {
       
      
      private const MAX_POINTS:int = 8;
      
      public var body1:Body;
      
      public var body2:Body;
      
      public var normal:Vector3;
      
      public var points:Vector.<ContactPoint>;
      
      public var pcount:int;
      
      public var maxPenetration:Number = 0;
      
      public var satisfied:Boolean;
      
      public var next:Contact;
      
      public var index:int;
      
      public function Contact(index:int)
      {
         this.normal = new Vector3();
         this.points = new Vector.<ContactPoint>(this.MAX_POINTS,true);
         super();
         this.index = index;
         for(var i:int = 0; i < this.MAX_POINTS; i++)
         {
            this.points[i] = new ContactPoint();
         }
      }
   }
}
