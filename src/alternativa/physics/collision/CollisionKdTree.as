package alternativa.physics.collision
{
   import alternativa.physics.collision.types.AABB;
   
   public class CollisionKdTree
   {
      
      private static const boundBoxWithThreshold:AABB = new AABB();
      
      private static const splitCoordsX:Vector.<Number> = new Vector.<Number>();
      
      private static const splitCoordsY:Vector.<Number> = new Vector.<Number>();
      
      private static const splitCoordsZ:Vector.<Number> = new Vector.<Number>();
      
      private static var numSplitCoordsX:int;
      
      private static var numSplitCoordsY:int;
      
      private static var numSplitCoordsZ:int;
      
      private static const _nodeBB:Vector.<Number> = new Vector.<Number>(6);
      
      private static const _bb:Vector.<Number> = new Vector.<Number>(6);
       
      
      public var threshold:Number = 0.1;
      
      public var minPrimitivesPerNode:int = 1;
      
      public var rootNode:CollisionKdNode;
      
      public var staticChildren:Vector.<CollisionPrimitive>;
      
      public var numStaticChildren:int;
      
      public var staticBoundBoxes:Vector.<AABB>;
      
      private var splitAxis:int;
      
      private var splitCoord:Number;
      
      private var splitCost:Number;
      
      public function CollisionKdTree()
      {
         this.staticBoundBoxes = new Vector.<AABB>();
         super();
      }
      
      private static function cleanup() : void
      {
         splitCoordsX.length = 0;
         splitCoordsY.length = 0;
         splitCoordsZ.length = 0;
      }
      
      private static function removeChildPrimitivesFromNode(node:CollisionKdNode) : void
      {
         var indices:Vector.<int> = node.indices;
         var numPrimitives:int = indices.length;
         var j:int = 0;
         for(var i:int = 0; i < numPrimitives; i++)
         {
            if(indices[i] >= 0)
            {
               var _loc6_:* = j++;
               indices[_loc6_] = indices[i];
            }
         }
         if(j > 0)
         {
            indices.length = j;
         }
         else
         {
            node.indices = null;
         }
      }
      
      private static function getBoundBoxWithThreshold(boundBox:AABB, threshold:Number) : AABB
      {
         boundBoxWithThreshold.minX = boundBox.minX + threshold;
         boundBoxWithThreshold.minY = boundBox.minY + threshold;
         boundBoxWithThreshold.minZ = boundBox.minZ + threshold;
         boundBoxWithThreshold.maxX = boundBox.maxX - threshold;
         boundBoxWithThreshold.maxY = boundBox.maxY - threshold;
         boundBoxWithThreshold.maxZ = boundBox.maxZ - threshold;
         return boundBoxWithThreshold;
      }
      
      public function createTree(collisionPrimitives:Vector.<CollisionPrimitive>, boundBox:AABB = null) : void
      {
         this.staticChildren = collisionPrimitives.concat();
         this.numStaticChildren = this.staticChildren.length;
         this.createRootNode();
         this.calculateBoundBoxes(boundBox);
         this.splitNode(this.rootNode);
         cleanup();
      }
      
      private function createRootNode() : void
      {
         this.rootNode = new CollisionKdNode();
         this.rootNode.indices = new Vector.<int>(this.numStaticChildren);
         for(var i:int = 0; i < this.numStaticChildren; i++)
         {
            this.rootNode.indices[i] = i;
         }
      }
      
      private function calculateBoundBoxes(boundBox:AABB) : void
      {
         var child:CollisionPrimitive = null;
         var childBoundBox:AABB = null;
         this.rootNode.boundBox = boundBox == null ? new AABB() : boundBox;
         this.staticBoundBoxes = new Vector.<AABB>(this.numStaticChildren);
         for(var i:int = 0; i < this.numStaticChildren; i++)
         {
            child = this.staticChildren[i];
            childBoundBox = child.calculateAABB();
            this.staticBoundBoxes[i] = childBoundBox;
            this.rootNode.boundBox.addBoundBox(childBoundBox);
         }
      }
      
      private function splitNode(node:CollisionKdNode) : void
      {
         if(this.nodeHasEnoughPrimitives(node))
         {
            this.collectSplitCoordinates(node);
            this.findBestSplit(node);
            if(this.splitExists())
            {
               this.divideNode(node);
            }
         }
      }
      
      private function nodeHasEnoughPrimitives(node:CollisionKdNode) : Boolean
      {
         return node.indices.length > this.minPrimitivesPerNode;
      }
      
      private function collectSplitCoordinates(node:CollisionKdNode) : void
      {
         var boundBox:AABB = null;
         numSplitCoordsX = 0;
         numSplitCoordsY = 0;
         numSplitCoordsZ = 0;
         var doubleThreshold:Number = 2 * this.threshold;
         var nodeBoundBox:AABB = node.boundBox;
         var boundBoxWithThreshold:AABB = getBoundBoxWithThreshold(nodeBoundBox,this.threshold);
         var indices:Vector.<int> = node.indices;
         var numPrimitives:int = indices.length;
         for(var i:int = 0; i < numPrimitives; i++)
         {
            boundBox = this.staticBoundBoxes[indices[i]];
            if(boundBox.maxX - boundBox.minX <= doubleThreshold)
            {
               if(boundBox.minX <= boundBoxWithThreshold.minX)
               {
                  var _loc9_:* = numSplitCoordsX++;
                  splitCoordsX[_loc9_] = nodeBoundBox.minX;
               }
               else if(boundBox.maxX >= boundBoxWithThreshold.maxX)
               {
                  _loc9_ = numSplitCoordsX++;
                  splitCoordsX[_loc9_] = nodeBoundBox.maxX;
               }
               else
               {
                  _loc9_ = numSplitCoordsX++;
                  splitCoordsX[_loc9_] = (boundBox.minX + boundBox.maxX) * 0.5;
               }
            }
            else
            {
               if(boundBox.minX > boundBoxWithThreshold.minX)
               {
                  _loc9_ = numSplitCoordsX++;
                  splitCoordsX[_loc9_] = boundBox.minX;
               }
               if(boundBox.maxX < boundBoxWithThreshold.maxX)
               {
                  _loc9_ = numSplitCoordsX++;
                  splitCoordsX[_loc9_] = boundBox.maxX;
               }
            }
            if(boundBox.maxY - boundBox.minY <= doubleThreshold)
            {
               if(boundBox.minY <= boundBoxWithThreshold.minY)
               {
                  _loc9_ = numSplitCoordsY++;
                  splitCoordsY[_loc9_] = nodeBoundBox.minY;
               }
               else if(boundBox.maxY >= boundBoxWithThreshold.maxY)
               {
                  _loc9_ = numSplitCoordsY++;
                  splitCoordsY[_loc9_] = nodeBoundBox.maxY;
               }
               else
               {
                  _loc9_ = numSplitCoordsY++;
                  splitCoordsY[_loc9_] = (boundBox.minY + boundBox.maxY) * 0.5;
               }
            }
            else
            {
               if(boundBox.minY > boundBoxWithThreshold.minY)
               {
                  _loc9_ = numSplitCoordsY++;
                  splitCoordsY[_loc9_] = boundBox.minY;
               }
               if(boundBox.maxY < boundBoxWithThreshold.maxY)
               {
                  _loc9_ = numSplitCoordsY++;
                  splitCoordsY[_loc9_] = boundBox.maxY;
               }
            }
            if(boundBox.maxZ - boundBox.minZ <= doubleThreshold)
            {
               if(boundBox.minZ <= boundBoxWithThreshold.minZ)
               {
                  _loc9_ = numSplitCoordsZ++;
                  splitCoordsZ[_loc9_] = nodeBoundBox.minZ;
               }
               else if(boundBox.maxZ >= boundBoxWithThreshold.maxZ)
               {
                  _loc9_ = numSplitCoordsZ++;
                  splitCoordsZ[_loc9_] = nodeBoundBox.maxZ;
               }
               else
               {
                  _loc9_ = numSplitCoordsZ++;
                  splitCoordsZ[_loc9_] = (boundBox.minZ + boundBox.maxZ) * 0.5;
               }
            }
            else
            {
               if(boundBox.minZ > boundBoxWithThreshold.minZ)
               {
                  _loc9_ = numSplitCoordsZ++;
                  splitCoordsZ[_loc9_] = boundBox.minZ;
               }
               if(boundBox.maxZ < boundBoxWithThreshold.maxZ)
               {
                  _loc9_ = numSplitCoordsZ++;
                  splitCoordsZ[_loc9_] = boundBox.maxZ;
               }
            }
         }
      }
      
      private function findBestSplit(node:CollisionKdNode) : void
      {
         var nodeBoundBox:AABB = node.boundBox;
         this.splitAxis = -1;
         this.splitCost = 1e+308;
         _nodeBB[0] = nodeBoundBox.minX;
         _nodeBB[1] = nodeBoundBox.minY;
         _nodeBB[2] = nodeBoundBox.minZ;
         _nodeBB[3] = nodeBoundBox.maxX;
         _nodeBB[4] = nodeBoundBox.maxY;
         _nodeBB[5] = nodeBoundBox.maxZ;
         this.checkNodeAxis(node,0,numSplitCoordsX,splitCoordsX,_nodeBB);
         this.checkNodeAxis(node,1,numSplitCoordsY,splitCoordsY,_nodeBB);
         this.checkNodeAxis(node,2,numSplitCoordsZ,splitCoordsZ,_nodeBB);
      }
      
      private function splitExists() : Boolean
      {
         return this.splitAxis >= 0;
      }
      
      private function divideNode(node:CollisionKdNode) : void
      {
         var axisX:Boolean = this.splitAxis == 0;
         var axisY:Boolean = this.splitAxis == 1;
         node.axis = this.splitAxis;
         node.coord = this.splitCoord;
         this.createChildNodes(node,axisX,axisY);
         this.putPrimitivesInChildNodes(node,axisX,axisY);
         removeChildPrimitivesFromNode(node);
         if(node.splitIndices != null)
         {
            node.splitTree = new CollisionKdTree2D(this,node);
            node.splitTree.createTree();
         }
         if(node.negativeNode.indices != null)
         {
            this.splitNode(node.negativeNode);
         }
         if(node.positiveNode.indices != null)
         {
            this.splitNode(node.positiveNode);
         }
      }
      
      private function createChildNodes(node:CollisionKdNode, axisX:Boolean, axisY:Boolean) : void
      {
         var nodeBoundBox:AABB = node.boundBox;
         node.negativeNode = new CollisionKdNode();
         node.negativeNode.parent = node;
         node.negativeNode.boundBox = nodeBoundBox.clone();
         node.positiveNode = new CollisionKdNode();
         node.positiveNode.parent = node;
         node.positiveNode.boundBox = nodeBoundBox.clone();
         if(axisX)
         {
            node.negativeNode.boundBox.maxX = node.positiveNode.boundBox.minX = this.splitCoord;
         }
         else if(axisY)
         {
            node.negativeNode.boundBox.maxY = node.positiveNode.boundBox.minY = this.splitCoord;
         }
         else
         {
            node.negativeNode.boundBox.maxZ = node.positiveNode.boundBox.minZ = this.splitCoord;
         }
      }
      
      private function putPrimitivesInChildNodes(node:CollisionKdNode, axisX:Boolean, axisY:Boolean) : void
      {
         var boundBox:AABB = null;
         var min:Number = NaN;
         var max:Number = NaN;
         var indices:Vector.<int> = node.indices;
         var numPrimitives:int = indices.length;
         var coordMin:Number = this.splitCoord - this.threshold;
         var coordMax:Number = this.splitCoord + this.threshold;
         for(var i:int = 0; i < numPrimitives; i++)
         {
            boundBox = this.staticBoundBoxes[indices[i]];
            min = !!axisX ? Number(boundBox.minX) : (!!axisY ? Number(boundBox.minY) : Number(boundBox.minZ));
            max = !!axisX ? Number(boundBox.maxX) : (!!axisY ? Number(boundBox.maxY) : Number(boundBox.maxZ));
            if(max <= coordMax)
            {
               if(min < coordMin)
               {
                  if(node.negativeNode.indices == null)
                  {
                     node.negativeNode.indices = new Vector.<int>();
                  }
                  node.negativeNode.indices.push(indices[i]);
                  indices[i] = -1;
               }
               else
               {
                  if(node.splitIndices == null)
                  {
                     node.splitIndices = new Vector.<int>();
                  }
                  node.splitIndices.push(indices[i]);
                  indices[i] = -1;
               }
            }
            else if(min >= coordMin)
            {
               if(node.positiveNode.indices == null)
               {
                  node.positiveNode.indices = new Vector.<int>();
               }
               node.positiveNode.indices.push(indices[i]);
               indices[i] = -1;
            }
         }
      }
      
      private function checkNodeAxis(node:CollisionKdNode, axis:int, numSplitCoords:int, splitCoords:Vector.<Number>, bb:Vector.<Number>) : void
      {
         var currSplitCoord:Number = NaN;
         var minCoord:Number = NaN;
         var maxCoord:Number = NaN;
         var areaNegative:Number = NaN;
         var areaPositive:Number = NaN;
         var numNegative:int = 0;
         var numPositive:int = 0;
         var conflict:Boolean = false;
         var numObjects:int = 0;
         var j:int = 0;
         var cost:Number = NaN;
         var boundBox:AABB = null;
         var axis1:int = (axis + 1) % 3;
         var axis2:int = (axis + 2) % 3;
         var area:Number = (bb[axis1 + 3] - bb[axis1]) * (bb[axis2 + 3] - bb[axis2]);
         for(var i:int = 0; i < numSplitCoords; i++)
         {
            currSplitCoord = splitCoords[i];
            if(!isNaN(currSplitCoord))
            {
               minCoord = currSplitCoord - this.threshold;
               maxCoord = currSplitCoord + this.threshold;
               areaNegative = area * (currSplitCoord - bb[axis]);
               areaPositive = area * (bb[int(axis + 3)] - currSplitCoord);
               numNegative = 0;
               numPositive = 0;
               conflict = false;
               numObjects = node.indices.length;
               for(j = 0; j < numObjects; j++)
               {
                  boundBox = this.staticBoundBoxes[node.indices[j]];
                  _bb[0] = boundBox.minX;
                  _bb[1] = boundBox.minY;
                  _bb[2] = boundBox.minZ;
                  _bb[3] = boundBox.maxX;
                  _bb[4] = boundBox.maxY;
                  _bb[5] = boundBox.maxZ;
                  if(_bb[axis + 3] <= maxCoord)
                  {
                     if(_bb[axis] < minCoord)
                     {
                        numNegative++;
                     }
                  }
                  else
                  {
                     if(_bb[axis] < minCoord)
                     {
                        conflict = true;
                        break;
                     }
                     numPositive++;
                  }
               }
               cost = areaNegative * numNegative + areaPositive * numPositive;
               if(!conflict && cost < this.splitCost && numNegative > 0 && numPositive > 0)
               {
                  this.splitAxis = axis;
                  this.splitCost = cost;
                  this.splitCoord = currSplitCoord;
               }
               for(j = i + 1; j < numSplitCoords; j++)
               {
                  if(splitCoords[j] >= currSplitCoord - this.threshold && splitCoords[j] <= currSplitCoord + this.threshold)
                  {
                     splitCoords[j] = NaN;
                  }
               }
            }
         }
      }
      
      public function traceTree() : void
      {
         this.traceNode("",this.rootNode);
      }
      
      private function traceNode(str:String, node:CollisionKdNode) : void
      {
         if(node == null)
         {
            return;
         }
         trace(str,node.axis == -1 ? "end" : (node.axis == 0 ? "X" : (node.axis == 1 ? "Y" : "Z")),"splitCoord=" + this.splitCoord,"bound",node.boundBox,"objs:",node.indices);
         this.traceNode(str + "-",node.negativeNode);
         this.traceNode(str + "+",node.positiveNode);
      }
   }
}
