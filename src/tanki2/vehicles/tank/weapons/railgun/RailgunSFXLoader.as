package alternativa.tanks.vehicles.tank.weapons.railgun
{
   import alternativa.engine3d.materials.TextureMaterial;
   import alternativa.tanks.Game;
   import alternativa.tanks.config.TextureLibrary;
   import alternativa.tanks.sfx.TextureAnimation;
   import alternativa.tanks.sfx.UVFrame;
   import alternativa.tanks.utils.GraphicsUtils;
   import alternativa.tanks.vehicles.tank.weapons.WeaponUtils;
   import flash.display.BitmapData;
   import flash.display.BlendMode;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   
   public class RailgunSFXLoader
   {
      
      private static const CHARGE_FRAME_SIZE:int = 210;
      
      private static const NUM_FRAMES:int = 30;
       
      
      public var chargeAnimation:TextureAnimation;
      
      public var sfxParams:Vector.<RailgunSFXData>;
      
      public var chargeSpriteSize:Number;
      
      public var beamMaterial:TextureMaterial;
      
      public var powMaterial:TextureMaterial;
      
      public function RailgunSFXLoader()
      {
         super();
         this.createChargeAnimation();
         this.loadSFXParams();
         this.createBeamMaterial();
      }
      
      private static function createSFXData(effectXML:XML) : RailgunSFXData
      {
         return new RailgunSFXData(effectXML.@id,WeaponUtils.parseColorTransform(effectXML),Number(effectXML.@maxBeamScale),Number(effectXML.@beamLifeTime));
      }
      
      private static function drawPart1(sourceBitmapData:BitmapData, destBitmapData:BitmapData, frameIndex:int, frameSize:int, blendMode:String) : void
      {
         var colorTransform:ColorTransform = new ColorTransform();
         if(frameIndex < 14)
         {
            colorTransform.alphaMultiplier = frameIndex / 14;
         }
         else if(frameIndex < 25)
         {
            colorTransform.alphaMultiplier = 1;
         }
         else
         {
            colorTransform.alphaMultiplier = 1 - (frameIndex - 24) / 5;
         }
         var matrix:Matrix = new Matrix();
         matrix.tx = frameIndex * frameSize + 0.5 * (frameSize - sourceBitmapData.width);
         matrix.ty = 0.5 * (frameSize - sourceBitmapData.height);
         destBitmapData.draw(sourceBitmapData,matrix,colorTransform,blendMode,null,true);
      }
      
      private static function drawPart2(sourceBitmapData:BitmapData, destBitmapData:BitmapData, frameIndex:int, frameSize:int, blendMode:String) : void
      {
         var colorTransform:ColorTransform = new ColorTransform();
         if(frameIndex < 5)
         {
            colorTransform.alphaMultiplier = frameIndex / 5;
         }
         else if(frameIndex < 25)
         {
            colorTransform.alphaMultiplier = 1;
         }
         else
         {
            colorTransform.alphaMultiplier = 1 - (frameIndex - 24) / 5;
         }
         var matrix:Matrix = new Matrix();
         matrix.translate(-0.5 * sourceBitmapData.width,-0.5 * sourceBitmapData.height);
         matrix.rotate(2 * frameIndex * Math.PI / 180);
         matrix.translate(frameIndex * frameSize + 0.5 * frameSize,0.5 * frameSize);
         destBitmapData.draw(sourceBitmapData,matrix,colorTransform,blendMode,null,true);
      }
      
      private static function drawPart3(sourceBitmapData:BitmapData, destBitmapData:BitmapData, frameIndex:int, frameSize:int, blendMode:String) : void
      {
         var k:Number = NaN;
         var scale:Number = NaN;
         var colorTransform:ColorTransform = new ColorTransform();
         if(frameIndex < 24)
         {
            k = frameIndex / 24;
            colorTransform.alphaMultiplier = k;
            scale = 0.4 + 0.6 * k;
         }
         else if(frameIndex < 25)
         {
            colorTransform.alphaMultiplier = 1;
            scale = 1;
         }
         else
         {
            k = 1 - (frameIndex - 24) / 5;
            colorTransform.alphaMultiplier = k;
            scale = 0.2 + 0.8 * k;
         }
         var matrix:Matrix = new Matrix();
         matrix.translate(-0.5 * sourceBitmapData.width,-0.5 * sourceBitmapData.height);
         matrix.scale(scale,scale);
         matrix.rotate(2 * -frameIndex * Math.PI / 180);
         matrix.translate(frameIndex * frameSize + 0.5 * frameSize,0.5 * frameSize);
         destBitmapData.draw(sourceBitmapData,matrix,colorTransform,blendMode,null,true);
      }
      
      private function createBeamMaterial() : void
      {
         var textureLibrary:TextureLibrary = Game.getInstance().config.textureLibrary;
         var texture:BitmapData = textureLibrary.getTexture("railgun/beam");
         this.beamMaterial = new TextureMaterial(texture);
         this.beamMaterial.repeat = true;
         this.beamMaterial.smooth = true;
         this.beamMaterial.resolution = texture.width / BeamEffect.BASE_WIDTH;
      }
      
      private function createChargeAnimation() : void
      {
         var textureLibrary:TextureLibrary = Game.getInstance().config.textureLibrary;
         var chargingPart1:BitmapData = textureLibrary.getTexture("railgun/part1");
         var chargingPart2:BitmapData = textureLibrary.getTexture("railgun/part2");
         var chargingPart3:BitmapData = textureLibrary.getTexture("railgun/part3");
         var texture:BitmapData = new BitmapData(CHARGE_FRAME_SIZE * NUM_FRAMES,CHARGE_FRAME_SIZE,true,0);
         var blendMode:String = BlendMode.NORMAL;
         for(var i:int = 0; i < NUM_FRAMES; i++)
         {
            drawPart1(chargingPart1,texture,i,CHARGE_FRAME_SIZE,blendMode);
            drawPart2(chargingPart2,texture,i,CHARGE_FRAME_SIZE,blendMode);
            drawPart3(chargingPart3,texture,i,CHARGE_FRAME_SIZE,blendMode);
         }
         var material:TextureMaterial = new TextureMaterial(texture);
         var railgunXML:XML = Game.getInstance().config.xml.railgun[0];
         this.chargeSpriteSize = Number(railgunXML.chargeSpriteSize);
         var frameSize:int = texture.height;
         material.resolution = this.chargeSpriteSize / frameSize;
         var frames:Vector.<UVFrame> = GraphicsUtils.getUVFramesFromTexture(texture,frameSize,frameSize);
         this.chargeAnimation = new TextureAnimation("",material,frames,Number(railgunXML.chargeEffectFPS));
      }
      
      private function loadSFXParams() : void
      {
         var effectXML:XML = null;
         this.sfxParams = new Vector.<RailgunSFXData>();
         var effectsXML:XMLList = Game.getInstance().config.xml.railgun.effect;
         for each(effectXML in effectsXML)
         {
            this.sfxParams.push(createSFXData(effectXML));
         }
      }
   }
}
