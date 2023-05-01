package tanki2.vehicles.tank.physics
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Camera3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.math.Vector3;
   import alternativa.physics.collision.CollisionPrimitive;
   import alternativa.physics.collision.primitives.CollisionBox;
   import tanki2.WireBox;
   import tanki2.utils.Utils3D;
   import tanki2.vehicles.tank.Tank;
   import flash.display.Graphics;
   import flash.utils.Dictionary;
   
   use namespace alternativa3d;
   
   public class TankPhysicsVisualizer
   {
      
      private static const eulerAngles:Vector3 = new Vector3();
       
      
      public var showSuspension:Boolean = true;
      
      private var tank:Tank;
      
      private var container:Object3D;
      
      private var bbs:Dictionary;
      
      private var bodyWireBox:WireBox;
      
      private var _showCollisionPrimitives:Boolean = true;
      
      private var _showBody:Boolean = true;
      
      public function TankPhysicsVisualizer(tank:Tank)
      {
         this.bbs = new Dictionary();
         super();
         this.tank = tank;
         this.addWireBoxes(tank.chassis.collisionPrimitives,16777215);
         this.bodyWireBox = createWireBox(tank.hull.getSkinDimensions().scale(0.5),16711680);
      }
      
      private static function createWireBox(halfSize:Vector3, color:uint) : WireBox
      {
         return new WireBox(2 * halfSize.x,2 * halfSize.y,2 * halfSize.z,color);
      }
      
      public function get showCollisionPrimitives() : Boolean
      {
         return this._showCollisionPrimitives;
      }
      
      public function set showCollisionPrimitives(value:Boolean) : void
      {
         if(this._showCollisionPrimitives != value)
         {
            this._showCollisionPrimitives = value;
            if(this._showCollisionPrimitives)
            {
               this.addCollisionPrimitivesToContainer(this.container);
            }
            else
            {
               this.removeCollisionPrimitivesFromContainer(this.container);
            }
         }
      }
      
      public function get showBody() : Boolean
      {
         return this._showBody;
      }
      
      public function set showBody(value:Boolean) : void
      {
         if(this._showBody != value)
         {
            this._showBody = value;
            if(this.container != null)
            {
               if(this._showBody)
               {
                  this.container.addChild(this.bodyWireBox);
               }
               else
               {
                  this.bodyWireBox.removeFromParent();
               }
            }
         }
      }
      
      public function addToContainer(container:Object3D) : void
      {
         this.container = container;
         if(this._showCollisionPrimitives)
         {
            this.addCollisionPrimitivesToContainer(container);
         }
         if(this._showBody)
         {
            container.addChild(this.bodyWireBox);
         }
      }
      
      public function removeFromContainer() : void
      {
         if(this.container != null)
         {
            this.removeCollisionPrimitivesFromContainer(this.container);
            this.bodyWireBox.removeFromParent();
            this.container = null;
         }
      }
      
      public function update() : void
      {
         var key:* = undefined;
         var bb:WireBox = null;
         var pos:Vector3 = null;
         if(this._showCollisionPrimitives)
         {
            for(key in this.bbs)
            {
               bb = this.bbs[key];
               Utils3D.setObjectTransform(bb,CollisionBox(key).transform);
            }
         }
         if(this._showBody)
         {
            pos = this.tank.chassis.state.position;
            this.bodyWireBox.x = pos.x;
            this.bodyWireBox.y = pos.y;
            this.bodyWireBox.z = pos.z;
            this.tank.chassis.baseMatrix.getEulerAngles(eulerAngles);
            this.bodyWireBox.rotationX = eulerAngles.x;
            this.bodyWireBox.rotationY = eulerAngles.y;
            this.bodyWireBox.rotationZ = eulerAngles.z;
         }
         if(!this.showSuspension)
         {
         }
      }
      
      private function addWireBoxes(collisionPrimitives:Vector.<CollisionPrimitive>, color:uint) : void
      {
         var collisionPrimitive:CollisionPrimitive = null;
         for each(collisionPrimitive in collisionPrimitives)
         {
            this.bbs[collisionPrimitive] = createWireBox(CollisionBox(collisionPrimitive).hs,color);
         }
      }
      
      private function addCollisionPrimitivesToContainer(container:Object3D) : void
      {
         var bb:WireBox = null;
         if(container != null)
         {
            for each(bb in this.bbs)
            {
               container.addChild(bb);
            }
         }
      }
      
      private function removeCollisionPrimitivesFromContainer(container:Object3D) : void
      {
         var bb:WireBox = null;
         for each(bb in this.bbs)
         {
            bb.removeFromParent();
         }
      }
      
      private function drawRays(gfx:Graphics) : void
      {
      }
      
      private function drawTrackRays(gfx:Graphics, camera:Camera3D, rays:SuspensionRay) : void
      {
      }
   }
}
