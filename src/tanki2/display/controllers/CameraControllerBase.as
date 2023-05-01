package tanki2.display.controllers
{
   import alternativa.math.Vector3;
   import tanki2.display.GameCamera;
   
   public class CameraControllerBase
   {
       
      
      private var camera:GameCamera;
      
      public function CameraControllerBase(camera:GameCamera)
      {
         super();
         if(camera == null)
         {
            throw new ArgumentError("Parameter camera cannot be null");
         }
         this.camera = camera;
      }
      
      public function setCamera(camera:GameCamera) : void
      {
         this.camera = camera;
      }
      
      protected function setPosition(position:Vector3) : void
      {
         this.camera.x = position.x;
         this.camera.y = position.y;
         this.camera.z = position.z;
      }
      
      protected function setOrientation(eulerAngles:Vector3) : void
      {
         this.camera.rotationX = eulerAngles.x;
         this.camera.rotationY = eulerAngles.y;
         this.camera.rotationZ = eulerAngles.z;
      }
      
      protected function setOrientationXYZ(rx:Number, ry:Number, rz:Number) : void
      {
         this.camera.rotationX = rx;
         this.camera.rotationY = ry;
         this.camera.rotationZ = rz;
      }
      
      protected function moveBy(dx:Number, dy:Number, dz:Number) : void
      {
         this.camera.x += dx;
         this.camera.y += dy;
         this.camera.z += dz;
      }
      
      protected function rotateBy(rx:Number, ry:Number, rz:Number) : void
      {
         this.camera.rotationX += rx;
         this.camera.rotationY += ry;
         this.camera.rotationZ += rz;
      }
      
      protected function getCameraPosition() : Vector3
      {
         return this.camera.position;
      }
      
      protected function getCameraRotationX() : Number
      {
         return this.camera.rotationX;
      }
      
      protected function getCameraRotationY() : Number
      {
         return this.camera.rotationY;
      }
      
      protected function getCameraRotationZ() : Number
      {
         return this.camera.rotationZ;
      }
   }
}
