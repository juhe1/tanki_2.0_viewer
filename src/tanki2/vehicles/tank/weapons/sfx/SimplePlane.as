package tanki2.vehicles.tank.weapons.sfx
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Vertex;
   import alternativa.engine3d.objects.Mesh;
   
   use namespace alternativa3d;
   
   public class SimplePlane extends Mesh
   {
       
      
      protected var a:Vertex;
      
      protected var b:Vertex;
      
      protected var c:Vertex;
      
      protected var d:Vertex;
      
      private var originX:Number;
      
      private var originY:Number;
      
      public function SimplePlane(width:Number, length:Number, originX:Number, originY:Number)
      {
         super();
         this.originX = originX;
         this.originY = originY;
         boundMinX = -originX * width;
         boundMaxX = boundMinX + width;
         boundMinY = -originY * length;
         boundMaxY = boundMinY + length;
         boundMinZ = 0;
         boundMaxZ = 0;
         var vertices:Vector.<Number> = Vector.<Number>([boundMinX,boundMinY,0,boundMaxX,boundMinY,0,boundMaxX,boundMaxY,0,boundMinX,boundMaxY,0]);
         var uvs:Vector.<Number> = Vector.<Number>([0,1,1,1,1,0,0,0]);
         var indices:Vector.<int> = Vector.<int>([4,0,1,2,3]);
         addVerticesAndFaces(vertices,uvs,indices,true);
         calculateFacesNormals();
         this.writeVertices();
      }
      
      private function writeVertices() : void
      {
         var vertices:Vector.<Vertex> = this.vertices;
         this.a = vertices[0];
         this.b = vertices[1];
         this.c = vertices[2];
         this.d = vertices[3];
      }
      
      public function setUVs(au:Number, av:Number, bu:Number, bv:Number, cu:Number, cv:Number, du:Number, dv:Number) : void
      {
         this.a.u = au;
         this.a.v = av;
         this.b.u = bu;
         this.b.v = bv;
         this.c.u = cu;
         this.c.v = cv;
         this.d.u = du;
         this.d.v = dv;
      }
      
      public function set width(value:Number) : void
      {
         boundMinX = this.a.x = this.d.x = -this.originX * value;
         boundMaxX = this.b.x = this.c.x = boundMinX + value;
      }
      
      public function get length() : Number
      {
         return boundMaxY - boundMinY;
      }
      
      public function set length(value:Number) : void
      {
         boundMinY = this.a.y = this.b.y = -this.originY * value;
         boundMaxY = this.d.y = this.c.y = boundMinY + value;
      }
   }
}
