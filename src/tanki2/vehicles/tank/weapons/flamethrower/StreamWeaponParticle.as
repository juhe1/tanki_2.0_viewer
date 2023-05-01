package alternativa.tanks.vehicles.tank.weapons.flamethrower
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.math.Vector3;
   import alternativa.tanks.sfx.AnimatedSprite3D;
   import flash.geom.ColorTransform;
   
   use namespace alternativa3d;
   
   public class StreamWeaponParticle extends AnimatedSprite3D
   {
      
      private static var INITIAL_POOL_SIZE:int = 20;
      
      private static var pool:Vector.<StreamWeaponParticle> = new Vector.<StreamWeaponParticle>(INITIAL_POOL_SIZE);
      
      private static var poolIndex:int = -1;
       
      
      public var velocity:Vector3;
      
      public var particleDistance:Number = 0;
      
      public var currFrame:Number;
      
      public var rotationDirection:int;
      
      public function StreamWeaponParticle()
      {
         this.velocity = new Vector3();
         super(100,100);
         colorTransform = new ColorTransform();
      }
      
      public static function getParticle() : StreamWeaponParticle
      {
         if(poolIndex == -1)
         {
            return new StreamWeaponParticle();
         }
         var particle:StreamWeaponParticle = pool[poolIndex];
         var _loc2_:* = poolIndex--;
         pool[_loc2_] = null;
         return particle;
      }
      
      private static function interpolateColorTransform(ct1:ColorTransformEntry, ct2:ColorTransformEntry, t:Number, result:ColorTransform) : void
      {
         result.alphaMultiplier = ct1.alphaMultiplier + t * (ct2.alphaMultiplier - ct1.alphaMultiplier);
         result.alphaOffset = ct1.alphaOffset + t * (ct2.alphaOffset - ct1.alphaOffset);
         result.redMultiplier = ct1.redMultiplier + t * (ct2.redMultiplier - ct1.redMultiplier);
         result.redOffset = ct1.redOffset + t * (ct2.redOffset - ct1.redOffset);
         result.greenMultiplier = ct1.greenMultiplier + t * (ct2.greenMultiplier - ct1.greenMultiplier);
         result.greenOffset = ct1.greenOffset + t * (ct2.greenOffset - ct1.greenOffset);
         result.blueMultiplier = ct1.blueMultiplier + t * (ct2.blueMultiplier - ct1.blueMultiplier);
         result.blueOffset = ct1.blueOffset + t * (ct2.blueOffset - ct1.blueOffset);
      }
      
      private static function copyStructToColorTransform(source:ColorTransformEntry, result:ColorTransform) : void
      {
         result.alphaMultiplier = source.alphaMultiplier;
         result.alphaOffset = source.alphaOffset;
         result.redMultiplier = source.redMultiplier;
         result.redOffset = source.redOffset;
         result.greenMultiplier = source.greenMultiplier;
         result.greenOffset = source.greenOffset;
         result.blueMultiplier = source.blueMultiplier;
         result.blueOffset = source.blueOffset;
      }
      
      public function dispose() : void
      {
         removeFromParent();
         clear();
         var _loc1_:* = ++poolIndex;
         pool[_loc1_] = this;
      }
      
      public function updateColorTransofrm(maxDistance:Number, points:Vector.<ColorTransformEntry>) : void
      {
         var t:Number = NaN;
         var point1:ColorTransformEntry = null;
         var point2:ColorTransformEntry = null;
         var i:int = 0;
         if(points != null)
         {
            t = this.particleDistance / maxDistance;
            if(t <= 0)
            {
               point1 = points[0];
               copyStructToColorTransform(point1,colorTransform);
            }
            else if(t >= 1)
            {
               point1 = points[points.length - 1];
               copyStructToColorTransform(point1,colorTransform);
            }
            else
            {
               i = 1;
               point1 = points[0];
               point2 = points[1];
               while(point2.t < t)
               {
                  i++;
                  point1 = point2;
                  point2 = points[i];
               }
               t = (t - point1.t) / (point2.t - point1.t);
               interpolateColorTransform(point1,point2,t,colorTransform);
            }
            alpha = colorTransform.alphaMultiplier;
         }
      }
   }
}
