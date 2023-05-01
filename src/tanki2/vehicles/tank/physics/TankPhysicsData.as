package tanki2.vehicles.tank.physics
{
   
   public class TankPhysicsData
   {
      
      public static var fields:Array = ["mass","springDamping","power","maxForwardSpeed","maxBackwardSpeed","maxTurnSpeed","drivingForceOffsetZ","smallVelocity","rayLength","dynamicFriction","brakeFriction","sideFriction","spotTurnPowerCoeff","spotTurnDynamicFriction","spotTurnSideFriction","moveTurnPowerCoeffInner","moveTurnPowerCoeffOuter","moveTurnDynamicFrictionInner","moveTurnDynamicFrictionOuter","moveTurnSideFriction","moveTurnSpeedCoeffInner","moveTurnSpeedCoeffOuter"];
       
      
      public var mass:Number = 6000;
      
      public var power:Number = 1000000;
      
      public var maxForwardSpeed:Number = 1500;
      
      public var maxBackwardSpeed:Number = 1500;
      
      public var maxTurnSpeed:Number = 0.5;
      
      public var springDamping:Number = 1000;
      
      public var drivingForceOffsetZ:Number = 0;
      
      public var smallVelocity:Number = 50;
      
      public var rayLength:Number = 50;
      
      public var dynamicFriction:Number = 0.05;
      
      public var brakeFriction:Number = 2;
      
      public var sideFriction:Number = 2;
      
      public var spotTurnPowerCoeff:Number = 1.9;
      
      public var spotTurnDynamicFriction:Number = 0.05;
      
      public var spotTurnSideFriction:Number = 1;
      
      public var moveTurnPowerCoeffOuter:Number = 1.17;
      
      public var moveTurnPowerCoeffInner:Number = 0.39;
      
      public var moveTurnDynamicFrictionInner:Number = 0.5;
      
      public var moveTurnDynamicFrictionOuter:Number = 0.05;
      
      public var moveTurnSideFriction:Number = 1;
      
      public var moveTurnSpeedCoeffInner:Number = 0.39;
      
      public var moveTurnSpeedCoeffOuter:Number = 1.17;
      
      public function TankPhysicsData()
      {
         super();
      }
      
      public function copy(param1:TankPhysicsData) : void
      {
         this.mass = param1.mass;
         this.power = param1.power;
         this.maxForwardSpeed = param1.maxForwardSpeed;
         this.maxBackwardSpeed = param1.maxBackwardSpeed;
         this.maxTurnSpeed = param1.maxTurnSpeed;
         this.springDamping = param1.springDamping;
         this.drivingForceOffsetZ = param1.drivingForceOffsetZ;
         this.smallVelocity = param1.smallVelocity;
         this.rayLength = param1.rayLength;
         this.dynamicFriction = param1.dynamicFriction;
         this.brakeFriction = param1.brakeFriction;
         this.sideFriction = param1.sideFriction;
         this.spotTurnPowerCoeff = param1.spotTurnPowerCoeff;
         this.spotTurnDynamicFriction = param1.spotTurnDynamicFriction;
         this.spotTurnSideFriction = param1.spotTurnSideFriction;
         this.moveTurnPowerCoeffOuter = param1.moveTurnPowerCoeffOuter;
         this.moveTurnPowerCoeffInner = param1.moveTurnPowerCoeffInner;
         this.moveTurnDynamicFrictionInner = param1.moveTurnDynamicFrictionInner;
         this.moveTurnDynamicFrictionOuter = param1.moveTurnDynamicFrictionOuter;
         this.moveTurnSideFriction = param1.moveTurnSideFriction;
         this.moveTurnSpeedCoeffInner = param1.moveTurnSpeedCoeffInner;
         this.moveTurnSpeedCoeffOuter = param1.moveTurnSpeedCoeffOuter;
      }
      
      public function setDataFromJsonObject(physicsData:Object):void 
      {
         this.mass = physicsData.mass;
         this.power = physicsData.power;
         this.maxForwardSpeed = physicsData.maxForwardSpeed;
         this.maxBackwardSpeed = physicsData.maxBackwardSpeed;
         this.maxTurnSpeed = physicsData.maxTurnSpeed;
         this.springDamping = physicsData.springDamping;
         this.dynamicFriction = physicsData.dynamicFriction;
         this.brakeFriction = physicsData.brakeFriction;
         this.sideFriction = physicsData.sideFriction;
      }
      
      public function clone() : TankPhysicsData
      {
         var _loc1_:TankPhysicsData = new TankPhysicsData();
         _loc1_.copy(this);
         return _loc1_;
      }
   }
}
