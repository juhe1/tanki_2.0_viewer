package alternativa.tanks.vehicles.tank.weapons.flamethrower
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Object3DContainer;
   import alternativa.math.Matrix3;
   import alternativa.math.Vector3;
   import alternativa.physics.Body;
   import alternativa.physics.collision.CollisionDetector;
   import alternativa.physics.collision.types.RayHit;
   import alternativa.tanks.Game;
   import alternativa.tanks.display.GameCamera;
   import alternativa.tanks.physics.CollisionGroup;
   import alternativa.tanks.sfx.GraphicEffect;
   import alternativa.tanks.sfx.TextureAnimation;
   import alternativa.tanks.utils.objectpool.Pool;
   import alternativa.tanks.utils.objectpool.PooledObject;
   import flash.utils.getTimer;
   
   public class FlamethrowerGraphicEffect extends PooledObject implements GraphicEffect
   {
      
      private static const ANIMATION_FPS:Number = 30;
      
      private static const PARTICLE_START_SIZE:Number = 50;
      
      public static const PARTICLE_END_SIZE:Number = 400;
      
      private static const matrix:Matrix3 = new Matrix3();
      
      private static const particlePosition:Vector3 = new Vector3();
      
      private static const barrelOrigin:Vector3 = new Vector3();
      
      private static const gunDirection:Vector3 = new Vector3();
      
      private static const xAxis:Vector3 = new Vector3();
      
      private static const globalMuzzlePosition:Vector3 = new Vector3();
      
      private static const intersection:RayHit = new RayHit();
       
      
      private var range:Number;
      
      private var sizePerDistance:Number;
      
      private var coneHalfAngleTan:Number;
      
      private var maxParticles:int;
      
      private var particleSpeed:Number;
      
      private var localMuzzlePosition:Vector3;
      
      private var turret:Object3D;
      
      private var container:Object3DContainer;
      
      private var particles:Vector.<StreamWeaponParticle>;
      
      private var numParticles:int;
      
      private var collisionDetector:CollisionDetector;
      
      private var dead:Boolean;
      
      private var emissionDelta:int;
      
      private var nextEmissionTime:int;
      
      private var time:int;
      
      private var shooterBody:Body;
      
      private var particleOffset:Number;
      
      private var particleRandomOffset:Number;
      
      private var colorTransformPoints:Vector.<ColorTransformEntry>;
      
      private var particleAnimation:TextureAnimation;
      
      public function FlamethrowerGraphicEffect(objectPool:Pool)
      {
         this.localMuzzlePosition = new Vector3();
         this.particles = new Vector.<StreamWeaponParticle>();
         super(objectPool);
      }
      
      public function init(shooterBody:Body, range:Number, coneAngle:Number, maxParticles:int, particleSpeed:Number, muzzleLocalPosition:Vector3, turret:Object3D, collisionDetector:CollisionDetector, particleAnimation:TextureAnimation, colorTransformPoints:Vector.<ColorTransformEntry>) : void
      {
         this.shooterBody = shooterBody;
         this.range = range;
         this.sizePerDistance = 2 * (PARTICLE_END_SIZE - PARTICLE_START_SIZE) / range;
         this.coneHalfAngleTan = Math.tan(0.5 * coneAngle);
         this.maxParticles = maxParticles;
         this.particleSpeed = particleSpeed;
         this.localMuzzlePosition.copy(muzzleLocalPosition);
         this.turret = turret;
         this.collisionDetector = collisionDetector;
         this.particleAnimation = particleAnimation;
         this.colorTransformPoints = colorTransformPoints;
         this.emissionDelta = 1000 * range / (maxParticles * particleSpeed);
         this.time = this.nextEmissionTime = getTimer();
         this.particles.length = maxParticles;
         this.dead = false;
         this.particleOffset = Number(Game.getInstance().config.xml.flamethrower.particleOffset);
         this.particleRandomOffset = Number(Game.getInstance().config.xml.flamethrower.particleRandomOffset);
      }
      
      public function addedToScene(container:Object3DContainer) : void
      {
         this.container = container;
      }
      
      public function play(millis:int, camera:GameCamera) : Boolean
      {
         var dt:Number = NaN;
         var particle:StreamWeaponParticle = null;
         var velocity:Vector3 = null;
         var particleSize:Number = NaN;
         if(!this.dead && this.numParticles < this.maxParticles && this.time >= this.nextEmissionTime)
         {
            this.nextEmissionTime += this.emissionDelta;
            this.tryToAddParticle();
         }
         dt = millis / 1000;
         for(var i:int = 0; i < this.numParticles; i++)
         {
            particle = this.particles[i];
            particlePosition.x = particle.x;
            particlePosition.y = particle.y;
            particlePosition.z = particle.z;
            if(particle.particleDistance > this.range || this.collisionDetector.raycastStatic(particlePosition,particle.velocity,CollisionGroup.WEAPON,dt,null,intersection))
            {
               this.removeParticle(i--);
            }
            else
            {
               velocity = particle.velocity;
               particle.x += dt * velocity.x;
               particle.y += dt * velocity.y;
               particle.z += dt * velocity.z;
               particle.particleDistance += this.particleSpeed * dt;
               particle.setFrameIndex(particle.currFrame);
               particle.currFrame += ANIMATION_FPS * dt;
               particleSize = PARTICLE_START_SIZE + this.sizePerDistance * particle.particleDistance;
               if(particleSize > PARTICLE_END_SIZE)
               {
                  particleSize = PARTICLE_END_SIZE;
               }
               particle.width = particleSize;
               particle.height = particleSize;
               particle.updateColorTransofrm(this.range,this.colorTransformPoints);
            }
         }
         this.time += millis;
         return !this.dead || this.numParticles > 0;
      }
      
      public function destroy() : void
      {
         while(this.numParticles > 0)
         {
            this.removeParticle(0);
         }
         this.collisionDetector = null;
         this.turret = null;
         this.shooterBody = null;
         recycle();
      }
      
      public function kill() : void
      {
         this.dead = true;
      }
      
      private function tryToAddParticle() : void
      {
         var offset:Number = NaN;
         var barrelLength:Number = NaN;
         matrix.setRotationMatrix(this.turret.rotationX,this.turret.rotationY,this.turret.rotationZ);
         barrelOrigin.x = 0;
         barrelOrigin.y = 0;
         barrelOrigin.z = this.localMuzzlePosition.z;
         barrelOrigin.transform3(matrix);
         barrelOrigin.x += this.turret.x;
         barrelOrigin.y += this.turret.y;
         barrelOrigin.z += this.turret.z;
         gunDirection.x = matrix.b;
         gunDirection.y = matrix.f;
         gunDirection.z = matrix.j;
         offset = this.particleOffset + Math.random() * this.particleRandomOffset;
         if(!this.collisionDetector.raycastStatic(barrelOrigin,gunDirection,CollisionGroup.STATIC,this.localMuzzlePosition.y + offset,null,intersection))
         {
            barrelLength = this.localMuzzlePosition.y;
            globalMuzzlePosition.x = barrelOrigin.x + gunDirection.x * barrelLength;
            globalMuzzlePosition.y = barrelOrigin.y + gunDirection.y * barrelLength;
            globalMuzzlePosition.z = barrelOrigin.z + gunDirection.z * barrelLength;
            xAxis.x = matrix.a;
            xAxis.y = matrix.e;
            xAxis.z = matrix.i;
            this.addParticle(globalMuzzlePosition,gunDirection,xAxis,offset);
         }
      }
      
      private function addParticle(globalMuzzlePosition:Vector3, direction:Vector3, gunAxisX:Vector3, offset:Number) : void
      {
         var particle:StreamWeaponParticle = StreamWeaponParticle.getParticle();
         particle.setAnimationData(this.particleAnimation);
         particle.rotationDirection = 0;
         particle.currFrame = Math.random() * particle.getNumFrames();
         var angle:Number = 2 * Math.PI * Math.random();
         matrix.fromAxisAngle(direction,angle);
         gunAxisX.transform3(matrix);
         var d:Number = this.range * this.coneHalfAngleTan * Math.random();
         direction.x = direction.x * this.range + gunAxisX.x * d;
         direction.y = direction.y * this.range + gunAxisX.y * d;
         direction.z = direction.z * this.range + gunAxisX.z * d;
         direction.normalize();
         particle.velocity.x = this.particleSpeed * direction.x;
         particle.velocity.y = this.particleSpeed * direction.y;
         particle.velocity.z = this.particleSpeed * direction.z;
         particle.velocity.add(this.shooterBody.state.velocity);
         particle.particleDistance = offset;
         particle.x = globalMuzzlePosition.x + offset * direction.x;
         particle.y = globalMuzzlePosition.y + offset * direction.y;
         particle.z = globalMuzzlePosition.z + offset * direction.z;
         var _loc8_:* = this.numParticles++;
         this.particles[_loc8_] = particle;
         this.container.addChild(particle);
      }
      
      private function removeParticle(index:int) : void
      {
         var particle:StreamWeaponParticle = this.particles[index];
         this.particles[index] = this.particles[--this.numParticles];
         this.particles[this.numParticles] = null;
         particle.dispose();
      }
   }
}
