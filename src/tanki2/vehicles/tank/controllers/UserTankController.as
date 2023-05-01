package tanki2.vehicles.tank.controllers
{
   import alternativa.math.Matrix3;
   import alternativa.math.Quaternion;
   import alternativa.math.Vector3;
   import tanki2.GameObject;
   import tanki2.vehicles.tank.Tank;
   import alternativa.utils.KeyMapper;
   import flash.events.IEventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   
   public class UserTankController extends CommonTankController
   {
      
      private static const KEY_TURRET_LEFT:int = 0;
      
      private static const KEY_TURRET_RIGHT:int = 1;
      
      private static const KEY_FORWARD:int = 2;
      
      private static const KEY_BACKWARD:int = 3;
      
      private static const KEY_TURN_LEFT:int = 4;
      
      private static const KEY_TURN_RIGHT:int = 5;
      
      private static const KEY_FIRE_WEAPON:int = 6;
      
      private static const KEY_MOVE_FX:int = 7;
      
      private static const KEY_MOVE_BX:int = 8;
      
      private static const KEY_MOVE_FY:int = 9;
      
      private static const KEY_MOVE_BY:int = 10;
      
      private static const KEY_MOVE_FZ:int = 11;
      
      private static const KEY_MOVE_BZ:int = 12;
       
      
      private var keyMapper:KeyMapper;
      
      private var keyActionMap:Dictionary;
      
      private var flip:Boolean;
      
      public function UserTankController(eventDispatcher:IEventDispatcher)
      {
         this.keyActionMap = new Dictionary();
         super();
         this.keyMapper = new KeyMapper();
         this.keyMapper.startListening(eventDispatcher);
         this.mapKey(KEY_TURRET_LEFT,CommonTankController.BIT_TURRET_LEFT,90);
         this.mapKey(KEY_TURRET_RIGHT,CommonTankController.BIT_TURRET_RIGHT,88);
         this.mapKey(KEY_FORWARD,CommonTankController.BIT_FORWARD,Keyboard.UP);
         this.mapKey(KEY_BACKWARD,CommonTankController.BIT_BACKWARD,Keyboard.DOWN);
         this.mapKey(KEY_TURN_LEFT,CommonTankController.BIT_TURN_LEFT,Keyboard.LEFT);
         this.mapKey(KEY_TURN_RIGHT,CommonTankController.BIT_TURN_RIGHT,Keyboard.RIGHT);
         this.mapKey(KEY_FIRE_WEAPON,CommonTankController.BIT_FIRE_WEAPON,Keyboard.SPACE);
         eventDispatcher.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
      }
      
      private function onKeyDown(event:KeyboardEvent) : void
      {
         if(event.keyCode == Keyboard.K)
         {
            this.flip = true;
         }
         
      }
      
      override public function update(object:GameObject, time:uint, deltaMsec:uint, deltaSec:Number) : void
      {
         var key:int = undefined;
         var tank:Tank = null;
         var keyIndex:* = 0;
         var actionBit:int = 0;
         var m:Matrix3 = null;
         for(keyIndex in this.keyActionMap)
         {
            actionBit = this.keyActionMap[keyIndex];
            if(this.keyMapper.getKeyState(keyIndex) == 1)
            {
               startAction(actionBit);
            }
            else
            {
               stopAction(actionBit);
            }
         }
         super.update(object,time,deltaMsec,deltaSec);
         tank = Tank(object);
         if(this.flip)
         {
            this.flip = false;
            m = tank.chassis.baseMatrix;
            tank.chassis.state.orientation.append(Quaternion.createFromAxisAngleComponents(m.b,m.f,m.j,Math.PI));
         }
         var offset:Number = 20;
         this.move(tank,getInput(KEY_MOVE_FX,KEY_MOVE_BX) * offset,getInput(KEY_MOVE_FY,KEY_MOVE_BY) * offset,getInput(KEY_MOVE_FZ,KEY_MOVE_BZ) * offset);
      }
      
      private function mapKey(keyIndex:int, tankActionBit:int, keyCode:uint) : void
      {
         this.keyActionMap[keyIndex] = tankActionBit;
         this.keyMapper.mapKey(keyIndex,keyCode);
      }
      
      private function move(tank:Tank, dx:Number, dy:Number, dz:Number) : void
      {
         tank.chassis.state.position.add(new Vector3(dx,dy,dz));
      }
   }
}
