package alternativa.tanks.vehicles.tank.weapons.isis
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Sorting;
   import alternativa.engine3d.core.Vertex;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.tanks.sfx.TextureAnimation;
   import alternativa.tanks.sfx.UVFrame;
   
   use namespace alternativa3d;
   
   class HealingGunShaft extends Mesh
   {
       
      
      private var a:Vertex;
      
      private var b:Vertex;
      
      private var c:Vertex;
      
      private var d:Vertex;
      
      private var frames:Vector.<UVFrame>;
      
      private var numFrames:int;
      
      function HealingGunShaft()
      {
         super();
         var vertices:Vector.<Number> = Vector.<Number>([-1,0,0,1,0,0,1,1,0,-1,1,0]);
         var uvs:Vector.<Number> = Vector.<Number>([0,1,1,1,1,0,0,0]);
         var indices:Vector.<int> = Vector.<int>([4,0,1,2,3]);
         addVerticesAndFaces(vertices,uvs,indices,true);
         sorting = Sorting.DYNAMIC_BSP;
         this.writeVertices();
         calculateFacesNormals();
      }
      
      private function writeVertices() : void
      {
         var vertices:Vector.<Vertex> = this.vertices;
         this.a = vertices[0];
         this.b = vertices[1];
         this.c = vertices[2];
         this.d = vertices[3];
      }
      
      public function init(width:Number, length:Number) : void
      {
         var hw:Number = width / 2;
         boundMinX = this.a.x = this.d.x = -hw;
         boundMaxX = this.b.x = this.c.x = hw;
         boundMinY = 0;
         boundMaxY = this.d.y = this.c.y = length;
         boundMinZ = boundMaxZ = 0;
      }
      
      public function setAnimationData(textureAnimation:TextureAnimation) : void
      {
         setMaterialToAllFaces(textureAnimation.material);
         this.frames = textureAnimation.frames;
         this.numFrames = this.frames.length;
      }
      
      public function clear() : void
      {
         setMaterialToAllFaces(null);
         this.frames = null;
         this.numFrames = 0;
      }
      
      public function setFrameIndex(frameIndex:int) : void
      {
         this.setFrame(this.frames[frameIndex % this.numFrames]);
      }
      
      private function setFrame(frame:UVFrame) : void
      {
         this.a.u = frame.topLeftU;
         this.a.v = frame.bottomRightV;
         this.b.u = frame.bottomRightU;
         this.b.v = frame.bottomRightV;
         this.c.u = frame.bottomRightU;
         this.c.v = frame.topLeftV;
         this.d.u = frame.topLeftU;
         this.d.v = frame.topLeftV;
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
      }
      
      public function setRandomFrame() : void
      {
         this.setFrameIndex(Math.random() * this.numFrames);
      }
   }
}
