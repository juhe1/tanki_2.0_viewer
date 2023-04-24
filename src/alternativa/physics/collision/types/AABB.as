package alternativa.physics.collision.types
{
   public class AABB
   {
       
      
      public var minX:Number = 1.0E308;
      
      public var minY:Number = 1.0E308;
      
      public var minZ:Number = 1.0E308;
      
      public var maxX:Number = -1.0E308;
      
      public var maxY:Number = -1.0E308;
      
      public var maxZ:Number = -1.0E308;
      
      public function AABB()
      {
         super();
      }
      
      public function setSize(minX:Number, minY:Number, minZ:Number, maxX:Number, maxY:Number, maxZ:Number) : void
      {
         this.minX = minX;
         this.minY = minY;
         this.minZ = minZ;
         this.maxX = maxX;
         this.maxY = maxY;
         this.maxZ = maxZ;
      }
      
      public function addBoundBox(boundBox:AABB) : void
      {
         this.minX = boundBox.minX < this.minX ? Number(boundBox.minX) : Number(this.minX);
         this.minY = boundBox.minY < this.minY ? Number(boundBox.minY) : Number(this.minY);
         this.minZ = boundBox.minZ < this.minZ ? Number(boundBox.minZ) : Number(this.minZ);
         this.maxX = boundBox.maxX > this.maxX ? Number(boundBox.maxX) : Number(this.maxX);
         this.maxY = boundBox.maxY > this.maxY ? Number(boundBox.maxY) : Number(this.maxY);
         this.maxZ = boundBox.maxZ > this.maxZ ? Number(boundBox.maxZ) : Number(this.maxZ);
      }
      
      public function addPoint(x:Number, y:Number, z:Number) : void
      {
         if(x < this.minX)
         {
            this.minX = x;
         }
         if(x > this.maxX)
         {
            this.maxX = x;
         }
         if(y < this.minY)
         {
            this.minY = y;
         }
         if(y > this.maxY)
         {
            this.maxY = y;
         }
         if(z < this.minZ)
         {
            this.minZ = z;
         }
         if(z > this.maxZ)
         {
            this.maxZ = z;
         }
      }
      
      public function infinity() : void
      {
         this.minX = 1e+308;
         this.minY = 1e+308;
         this.minZ = 1e+308;
         this.maxX = -1e+308;
         this.maxY = -1e+308;
         this.maxZ = -1e+308;
      }
      
      public function intersects(bb:AABB, epsilon:Number) : Boolean
      {
         return !(this.minX > bb.maxX + epsilon || this.maxX < bb.minX - epsilon || this.minY > bb.maxY + epsilon || this.maxY < bb.minY - epsilon || this.minZ > bb.maxZ + epsilon || this.maxZ < bb.minZ - epsilon);
      }
      
      public function copyFrom(boundBox:AABB) : void
      {
         this.minX = boundBox.minX;
         this.minY = boundBox.minY;
         this.minZ = boundBox.minZ;
         this.maxX = boundBox.maxX;
         this.maxY = boundBox.maxY;
         this.maxZ = boundBox.maxZ;
      }
      
      public function clone() : AABB
      {
         var clone:AABB = new AABB();
         clone.copyFrom(this);
         return clone;
      }
      
      public function getSizeX() : Number
      {
         return this.maxX - this.minX;
      }
      
      public function getSizeY() : Number
      {
         return this.maxY - this.minY;
      }
      
      public function getSizeZ() : Number
      {
         return this.maxZ - this.minZ;
      }
   }
}
