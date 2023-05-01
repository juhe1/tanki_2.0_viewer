package tanki2.vehicles.tank.weapons.sfx
{
   import alternativa.tanks.sfx.TextureAnimation;
   import alternativa.tanks.sfx.UVFrame;
   
   class FreezeMuzzlePlane extends SimplePlane
   {
       
      
      private var animation:TextureAnimation;
      
      private var numFrames:int;
      
      private var currFrame:Number;
      
      function FreezeMuzzlePlane(width:Number, length:Number)
      {
         super(width,length,0.5,0);
      }
      
      public function init(animation:TextureAnimation) : void
      {
         this.animation = animation;
         setMaterialToAllFaces(animation.material);
         this.numFrames = animation.frames.length;
         this.currFrame = 0;
         this.setFrame(animation.frames[0]);
      }
      
      public function clear() : void
      {
         setMaterialToAllFaces(null);
         this.animation = null;
         this.numFrames = 0;
      }
      
      public function update(dt:Number) : void
      {
         this.currFrame += dt * this.animation.fps;
         if(this.currFrame >= this.numFrames)
         {
            this.currFrame = 0;
         }
         this.setFrame(this.animation.frames[int(this.currFrame)]);
      }
      
      private function setFrame(frame:UVFrame) : void
      {
         a.u = frame.topLeftU;
         a.v = frame.topLeftV;
         b.u = frame.topLeftU;
         b.v = frame.bottomRightV;
         c.u = frame.bottomRightU;
         c.v = frame.bottomRightV;
         d.u = frame.bottomRightU;
         d.v = frame.topLeftV;
      }
   }
}
