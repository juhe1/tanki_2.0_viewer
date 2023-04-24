package alternativa.physics.collision
{
   import alternativa.physics.collision.types.AABB;
   
   public class CollisionKdNode
   {
       
      
      public var indices:Vector.<int>;
      
      public var splitIndices:Vector.<int>;
      
      public var boundBox:AABB;
      
      public var parent:CollisionKdNode;
      
      public var splitTree:CollisionKdTree2D;
      
      public var axis:int = -1;
      
      public var coord:Number;
      
      public var positiveNode:CollisionKdNode;
      
      public var negativeNode:CollisionKdNode;
      
      public function CollisionKdNode()
      {
         super();
      }
      
      public function getDepth() : int
      {
         if(this.axis == -1)
         {
            return 0;
         }
         return 1 + Math.max(this.positiveNode.getDepth(),this.negativeNode.getDepth());
      }
   }
}
