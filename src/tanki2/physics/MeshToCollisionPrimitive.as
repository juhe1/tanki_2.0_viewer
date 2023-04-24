package tanki2.physics 
{
   import alternativa.engine3d.objects.Mesh;
   import alternativa.math.Matrix4;
   import alternativa.math.Vector3;
   import alternativa.physics.PhysicsMaterial;
   import alternativa.physics.collision.CollisionPrimitive;
   import alternativa.engine3d.core.VertexAttributes;
   import alternativa.physics.collision.primitives.CollisionBox;
   import alternativa.physics.collision.primitives.CollisionRect;
   import alternativa.physics.collision.primitives.CollisionTriangle;
	/**
    * ...
    * @author juhe
    */
   public class MeshToCollisionPrimitive 
   {
      
      public function MeshToCollisionPrimitive() 
      {
         super();
      }
      
      
      public static function triangleMeshToCollisionPrimitive(mesh:Mesh, collisionPrimitives:Vector.<CollisionPrimitive>, collisionGroup:int, physicsMaterial:PhysicsMaterial) : int
      {
         var numTriangles:int = 0;
         var j:int = 0;
         var vertexBaseIndex:uint = 0;
         var v:Vector3 = null;
         var indices:Vector.<uint> = mesh.geometry.indices;
         var vertexCoordinates:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
         var vertices:Vector.<Vector3> = new Vector.<Vector3>(3);
         vertices[0] = new Vector3();
         vertices[1] = new Vector3();
         vertices[2] = new Vector3();
         for(var i:int = 0; i < indices.length; i += 3)
         {
            for(j = 0; j < 3; j++)
            {
               vertexBaseIndex = 3 * indices[i + j];
               v = vertices[j];
               v.x = vertexCoordinates[vertexBaseIndex];
               v.y = vertexCoordinates[vertexBaseIndex + 1];
               v.z = vertexCoordinates[vertexBaseIndex + 2];
               v.scale(mesh.scaleX);
            }
            numTriangles++;
            collisionPrimitives.push(createCollisionTriangle(vertices[0], vertices[1], vertices[2], mesh, collisionGroup, physicsMaterial));
         }
         return numTriangles;
      }
      
      private static function createCollisionTriangle(v0:Vector3, v1:Vector3, v2:Vector3, parentMesh:Mesh, collisionGroup:int, physicsMaterial:PhysicsMaterial) : CollisionTriangle
      {
         var midPoint:Vector3 = new Vector3();
         midPoint.x = (v0.x + v1.x + v2.x) / 3;
         midPoint.y = (v0.y + v1.y + v2.y) / 3;
         midPoint.z = (v0.z + v1.z + v2.z) / 3;
         var xAxis:Vector3 = new Vector3();
         xAxis.diff(v1,v0);
         v1.reset(xAxis.length(),0,0);
         xAxis.normalize();
         var yAxis:Vector3 = new Vector3();
         yAxis.diff(v2,v0);
         var x:Number = yAxis.dot(xAxis);
         var y:Number = Math.sqrt(yAxis.lengthSqr() - x * x);
         v2.reset(x,y,0);
         var zAxis:Vector3 = new Vector3();
         zAxis.cross2(xAxis,yAxis);
         zAxis.normalize();
         yAxis.cross2(zAxis,xAxis);
         yAxis.normalize();
         var transform:Matrix4 = new Matrix4();
         transform.a = xAxis.x;
         transform.e = xAxis.y;
         transform.i = xAxis.z;
         transform.b = yAxis.x;
         transform.f = yAxis.y;
         transform.j = yAxis.z;
         transform.c = zAxis.x;
         transform.g = zAxis.y;
         transform.k = zAxis.z;
         transform.d = midPoint.x;
         transform.h = midPoint.y;
         transform.l = midPoint.z;
         var meshMatrix:Matrix4 = new Matrix4();
         meshMatrix.setMatrix(parentMesh.x,parentMesh.y,parentMesh.z,parentMesh.rotationX,parentMesh.rotationY,parentMesh.rotationZ);
         transform.append(meshMatrix);
         x = (v1.x + v2.x) / 3;
         y = (v1.y + v2.y) / 3;
         v0.reset(-x,-y,0);
         v1.x -= x;
         v1.y -= y;
         v2.x -= x;
         v2.y -= y;
         var collisionTriangle:CollisionTriangle = new CollisionTriangle(v0,v1,v2,collisionGroup,physicsMaterial);
         collisionTriangle.transform = transform;
         return collisionTriangle;
      }
      
      public static function boxMeshToCollisionPrimitive(mesh:Mesh, collisionPrimitives:Vector.<CollisionPrimitive>, collisionGroup:int, physicsMaterial:PhysicsMaterial) : void
      {
         mesh.calculateBoundBox();
         var minX:Number = mesh.boundBox.minX * mesh.scaleX;
         var maxX:Number = mesh.boundBox.maxX * mesh.scaleX;
         var minY:Number = mesh.boundBox.minY * mesh.scaleX;
         var maxY:Number = mesh.boundBox.maxY * mesh.scaleX;
         var minZ:Number = mesh.boundBox.minZ * mesh.scaleX;
         var maxZ:Number = mesh.boundBox.maxZ * mesh.scaleX;
         var halfSize:Vector3 = new Vector3();
         halfSize.x = maxX - minX;
         halfSize.y = maxY - minY;
         halfSize.z = maxZ - minZ;
         halfSize.scale(0.5);
         var collisionBox:CollisionBox = new CollisionBox(halfSize, collisionGroup, physicsMaterial);
         collisionBox.transform.setMatrix(mesh.x,mesh.y,mesh.z,mesh.rotationX,mesh.rotationY,mesh.rotationZ);
         var midPoint:Vector3 = new Vector3(0.5 * (maxX + minX),0.5 * (maxY + minY),0.5 * (maxZ + minZ));
         midPoint.transform4(collisionBox.transform);
         collisionBox.transform.d = midPoint.x;
         collisionBox.transform.h = midPoint.y;
         collisionBox.transform.l = midPoint.z;
         collisionPrimitives.push(collisionBox);
      }
      
      public static function planeMeshToCollisionPrimitive(mesh:Mesh, collisionPrimitives:Vector.<CollisionPrimitive>, collisionGroup:int, physicsMaterial:PhysicsMaterial) : void
      {
         var i:int = 0;
         var baseIndex:uint = 0;
         var edge:Vector3 = null;
         var len:Number = NaN;
         var indices:Vector.<uint> = mesh.geometry.indices;
         var vertexCoordinates:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
         var faceVertexIndices:Vector.<uint> = Vector.<uint>([indices[0],indices[1],indices[2]]);
         var edges:Vector.<Vector3> = Vector.<Vector3>([new Vector3(),new Vector3(),new Vector3()]);
         var lengths:Vector.<Number> = new Vector.<Number>(3);
         var vertices:Vector.<Vector3> = new Vector.<Vector3>(3);
         for(i = 0; i < 3; i++)
         {
            baseIndex = 3 * faceVertexIndices[i];
            vertices[i] = new Vector3(vertexCoordinates[baseIndex],vertexCoordinates[baseIndex + 1],vertexCoordinates[baseIndex + 2]);
         }
         var max:Number = -1;
         var imax:int = 0;
         for(i = 0; i < 3; )
         {
            edge = edges[i];
            edge.diff(vertices[(i + 1) % 3],vertices[i]);
            len = lengths[i] = edge.length();
            if(len > max)
            {
               max = len;
               imax = i;
            }
            i++;
         }
         var ix:int = (imax + 2) % 3;
         var iy:int = (imax + 1) % 3;
         var xAxis:Vector3 = edges[ix];
         var yAxis:Vector3 = edges[iy];
         yAxis.reverse();
         var width:Number = lengths[ix];
         var length:Number = lengths[iy];
         var translation:Vector3 = vertices[(imax + 2) % 3].clone();
         translation.x += 0.5 * (xAxis.x + yAxis.x);
         translation.y += 0.5 * (xAxis.y + yAxis.y);
         translation.z += 0.5 * (xAxis.z + yAxis.z);
         xAxis.normalize();
         yAxis.normalize();
         var zAxis:Vector3 = new Vector3().cross2(xAxis,yAxis);
         var collisionRect:CollisionRect = new CollisionRect(new Vector3(width / 2,length / 2,0),collisionGroup,physicsMaterial);
         var transform:Matrix4 = collisionRect.transform;
         transform.a = xAxis.x;
         transform.e = xAxis.y;
         transform.i = xAxis.z;
         transform.b = yAxis.x;
         transform.f = yAxis.y;
         transform.j = yAxis.z;
         transform.c = zAxis.x;
         transform.g = zAxis.y;
         transform.k = zAxis.z;
         transform.d = translation.x;
         transform.h = translation.y;
         transform.l = translation.z;
         var matrix:Matrix4 = new Matrix4();
         matrix.setMatrix(mesh.x,mesh.y,mesh.z,mesh.rotationX,mesh.rotationY,mesh.rotationZ);
         transform.append(matrix);
         collisionPrimitives.push(collisionRect);
      }
      
   }

}