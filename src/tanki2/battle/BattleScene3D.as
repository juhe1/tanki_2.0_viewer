package tanki2.battle
{
   import alternativa.engine3d.core.Object3D;
   import tanki2.battle.Renderer;
   import alternativa.math.Vector3;
   import tanki2.display.GameCamera;
   
   public interface BattleScene3D
   {
       
      
      function addRenderer(param1:Renderer, param2:int) : void;
      
      function removeRenderer(param1:Renderer, param2:int) : void;
      
      function addObject(param1:Object3D) : void;
      
      function removeObject(param1:Object3D) : void;
      
      function getCamera() : GameCamera;
      
      function createBox(param1:Number, param2:uint, param3:Vector3) : void;
   }
}
