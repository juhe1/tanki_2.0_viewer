package tanki2.vehicles.tank.weapons
{
   import alternativa.math.Matrix3;
   import alternativa.math.Vector3;
   import alternativa.physics.Body;
   import alternativa.physics.collision.CollisionDetector;
   import alternativa.physics.collision.types.RayHit;
   import tanki2.vehicles.tank.Tank;
   import tanki2.vehicles.tank.physics.Chassis;
   
   public class CommonTargetingSystem
   {
      
      private static var rayDir1:Vector3 = new Vector3();
      
      private static var rayDir2:Vector3 = new Vector3();
       
      
      private const collisionGroup:int = 1;
      
      private var nearestTank:Tank;
      
      private var tmin:Number;
      
      private var bestDir:Vector3;
      
      private var matrix:Matrix3;
      
      private var intersection:RayHit;
      
      private var predicate:GunPredicate;
      
      public function CommonTargetingSystem()
      {
         this.bestDir = new Vector3();
         this.matrix = new Matrix3();
         this.intersection = new RayHit();
         this.predicate = new GunPredicate();
         super();
      }
      
      public function getTarget(maxTime:Number, barrelOrigin:Vector3, gunDir:Vector3, xAxis:Vector3, upAngle:Number, upRaysNum:int, downAngle:Number, downRaysNum:int, collisionDetector:CollisionDetector, shooter:Tank, hitInfo:HitInfo) : Boolean
      {
         var chassis:Chassis = null;
         this.nearestTank = null;
         this.tmin = 10000000000;
         this.predicate.shooter = shooter.chassis;
         if(collisionDetector.raycast(barrelOrigin,gunDir,this.collisionGroup,10000000000,this.predicate,this.intersection))
         {
            this.tmin = this.intersection.t;
            this.bestDir.copy(gunDir);
            chassis = this.intersection.primitive.body as Chassis;
            if(chassis != null)
            {
               this.nearestTank = chassis.tank;
            }
         }
         if(upRaysNum > 0)
         {
            this.checkSector(barrelOrigin,gunDir,xAxis,upRaysNum,upAngle / upRaysNum,collisionDetector);
         }
         if(downRaysNum > 0)
         {
            this.checkSector(barrelOrigin,gunDir,xAxis,downRaysNum,-downAngle / downRaysNum,collisionDetector);
         }
         this.predicate.shooter = null;
         if(this.tmin < maxTime)
         {
            hitInfo.t = this.tmin;
            hitInfo.dir.copy(this.bestDir);
            hitInfo.pos.copy(barrelOrigin).addScaled(this.tmin,this.bestDir);
            hitInfo.body = this.nearestTank != null ? this.nearestTank.chassis : null;
            return true;
         }
         return false;
      }
      
      private function checkSector(origin:Vector3, dir:Vector3, xAxis:Vector3, raysNum:int, angleStep:Number, collisionDetector:CollisionDetector) : void
      {
         var chassis:Chassis = null;
         var tank:Tank = null;
         this.matrix.fromAxisAngle(xAxis,angleStep);
         rayDir2.copy(dir);
         for(var i:int = 1; i <= raysNum; i++)
         {
            rayDir1.copy(rayDir2);
            this.matrix.transformVector(rayDir1,rayDir2);
            if(collisionDetector.raycast(origin,rayDir2,this.collisionGroup,10000000000,this.predicate,this.intersection))
            {
               chassis = this.intersection.primitive.body as Chassis;
               if(chassis != null)
               {
                  tank = chassis.tank;
                  if(this.nearestTank == null || this.intersection.t < this.tmin)
                  {
                     this.tmin = this.intersection.t;
                     this.bestDir.copy(rayDir2);
                     this.nearestTank = tank;
                  }
               }
            }
         }
      }
   }
}

import alternativa.physics.Body;
import alternativa.physics.collision.IRayCollisionFilter;

class GunPredicate implements IRayCollisionFilter
{
    
   
   public var shooter:Body;
   
   function GunPredicate()
   {
      super();
   }
   
   public function considerBody(body:Body) : Boolean
   {
      return this.shooter != body;
   }
}
