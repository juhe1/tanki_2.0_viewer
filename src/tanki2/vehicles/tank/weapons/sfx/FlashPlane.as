package tanki2.vehicles.tank.weapons.sfx
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Face;
   import alternativa.engine3d.core.Vertex;
   import alternativa.engine3d.core.Wrapper;
   import alternativa.engine3d.materials.Material;
   import alternativa.engine3d.objects.Mesh;
   
   use namespace alternativa3d;
   
   class FlashPlane extends Mesh
   {
       
      
      function FlashPlane(width:Number, length:Number)
      {
         super();
         var hw:Number = width / 2;
         var a:Vertex = this.createVertex(-hw,0,0,0,0);
         var b:Vertex = this.createVertex(hw,0,0,0,1);
         var c:Vertex = this.createVertex(hw,length,0,1,1);
         var d:Vertex = this.createVertex(-hw,length,0,1,0);
         this.createQuad(a,b,c,d);
         calculateFacesNormals();
         calculateBounds();
      }
      
      public function init(material:Material) : void
      {
         faceList.material = material;
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
      
      private function createQuad(a:Vertex, b:Vertex, c:Vertex, d:Vertex) : void
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
      }
   }
}
