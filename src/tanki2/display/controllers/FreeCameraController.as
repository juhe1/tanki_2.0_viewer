package tanki2.display.controllers
{
   import alternativa.engine3d.controllers.SimpleObjectController;
   import alternativa.engine3d.core.Object3D;
   import alternativa.tanks.display.ICameraController;
   import flash.display.InteractiveObject;
   import flash.ui.Keyboard;
   
   public class FreeCameraController extends SimpleObjectController implements ICameraController
   {
       
      
      public function FreeCameraController(eventSource:InteractiveObject, object:Object3D, speed:Number)
      {
         super(eventSource,object,speed);
         unbindKey(Keyboard.LEFT);
         unbindKey(Keyboard.RIGHT);
         unbindKey(Keyboard.UP);
         unbindKey(Keyboard.DOWN);
      }
      
      public function updateCamera(time:uint, deltaMsec:uint, deltaSec:Number) : void
      {
         update();
      }
   }
}
