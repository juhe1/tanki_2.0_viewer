package alternativa.tanks.vehicles.tank.weapons.railgun
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Face;
   import alternativa.engine3d.core.Sorting;
   import alternativa.engine3d.core.Vertex;
   import alternativa.engine3d.core.Wrapper;
   import alternativa.engine3d.materials.Material;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.tanks.sfx.SFXUtils;
   import flash.geom.ColorTransform;
   
   use namespace alternativa3d;
   
   class Beam extends Mesh
   {
      
      private static const UNIT_LENGTH:Number = 500;
       
      
      private var a:Vertex;
      
      private var b:Vertex;
      
      private var c:Vertex;
      
      private var d:Vertex;
      
      private var face:Face;
      
      private var textureSpeed:Number;
      
      private var textureAcceleration:Number;
      
      private var textureOffset:Number = 0;
      
      function Beam()
      {
         super();
         this.a = this.createVertex(-1,0,0,0,1);
         this.b = this.createVertex(1,0,0,1,1);
         this.c = this.createVertex(1,1,0,1,0);
         this.d = this.createVertex(-1,1,0,0,0);
         this.face = this.createQuad(this.a,this.b,this.c,this.d);
         calculateFacesNormals();
         sorting = Sorting.DYNAMIC_BSP;
      }
      
      public function init(width:Number, length:Number, material:Material, colorTransform:ColorTransform, textureSpeed:Number, textureAcceleration:Number) : void
      {
         alpha = 1;
         var hw:Number = width / 2;
         boundMinX = this.a.x = this.d.x = -hw;
         boundMaxX = this.b.x = this.c.x = hw;
         boundMinY = 0;
         boundMaxY = this.d.y = this.c.y = length;
         this.a.v = this.b.v = length / UNIT_LENGTH;
         boundMinZ = boundMaxZ = 0;
         this.face.material = material;
         if(colorTransform == null)
         {
            this.colorTransform = null;
         }
         else
         {
            if(this.colorTransform == null)
            {
               this.colorTransform = new ColorTransform();
            }
            SFXUtils.copyColorTransform(colorTransform,this.colorTransform);
         }
         this.textureSpeed = textureSpeed;
         this.textureAcceleration = textureAcceleration;
         this.textureOffset = 0;
      }
      
      public function set width(value:Number) : void
      {
         var hw:Number = value / 2;
         boundMinX = this.a.x = this.d.x = -hw;
         boundMaxX = this.b.x = this.c.x = hw;
      }
      
      public function get length() : Number
      {
         return this.d.y;
      }
      
      public function set length(value:Number) : void
      {
         if(value < 10)
         {
            value = 10;
         }
         boundMaxY = this.d.y = this.c.y = value;
         this.a.v = this.b.v = value / UNIT_LENGTH;
      }
      
      public function update(timeDeltaMs:int) : void
      {
         var dt:Number = 0.001 * timeDeltaMs;
         this.textureOffset += this.textureSpeed * dt;
         if(this.textureSpeed >= 0)
         {
            while(this.textureOffset >= 1)
            {
               this.textureOffset -= 1;
            }
         }
         else
         {
            while(this.textureOffset <= -1)
            {
               this.textureOffset += 1;
            }
         }
         this.textureSpeed += this.textureAcceleration * dt;
         if(this.textureSpeed < 0)
         {
            this.textureSpeed = 0;
         }
         this.a.v = this.b.v = this.length / UNIT_LENGTH + this.textureOffset;
         this.c.v = this.d.v = this.textureOffset;
      }
      
      private function createVertex(x:Number, y:Number, z:Number, u:Number, v:Number) : Vertex
      {
         var newVertex:Vertex = new Vertex();
         newVertex.next = vertexList;
         vertexList = newVertex;
         newVertex.x = x;
         newVertex.y = y;
         newVertex.z = z;
         newVertex.u = u;
         newVertex.v = v;
         return newVertex;
      }
      
      private function createQuad(a:Vertex, b:Vertex, c:Vertex, d:Vertex) : Face
      {
         var newFace:Face = new Face();
         newFace.next = faceList;
         faceList = newFace;
         newFace.wrapper = new Wrapper();
         newFace.wrapper.vertex = a;
         newFace.wrapper.next = new Wrapper();
         newFace.wrapper.next.vertex = b;
         newFace.wrapper.next.next = new Wrapper();
         newFace.wrapper.next.next.vertex = c;
         newFace.wrapper.next.next.next = new Wrapper();
         newFace.wrapper.next.next.next.vertex = d;
         return newFace;
      }
   }
}
