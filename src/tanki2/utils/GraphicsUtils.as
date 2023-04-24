package alternativa.tanks.utils
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.math.Vector3;
   import alternativa.tanks.sfx.UVFrame;
   import flash.display.BitmapData;
   
   public class GraphicsUtils
   {
       
      
      public function GraphicsUtils()
      {
         super();
      }
      
      public static function setObjectTransform(object:Object3D, position:Vector3, rotation:Vector3) : void
      {
         object.x = position.x;
         object.y = position.y;
         object.z = position.z;
         object.rotationX = rotation.x;
         object.rotationY = rotation.y;
         object.rotationZ = rotation.z;
      }
      
      public static function getSquareUVFramesFromTexture(texture:BitmapData, maxFrames:int = 0) : Vector.<UVFrame>
      {
         var size:int = texture.height;
         return getUVFramesFromTexture(texture,size,size,maxFrames);
      }
      
      public static function getUVFramesFromTexture(texture:BitmapData, frameWidth:int, frameHeight:int, maxFrames:int = 0) : Vector.<UVFrame>
      {
         var topY:int = 0;
         var bottomY:int = 0;
         var columIndex:int = 0;
         var leftX:int = 0;
         var rightX:int = 0;
         var textureWidth:int = texture.width;
         var actualFrameWidth:int = Math.min(frameWidth,textureWidth);
         var numColumns:int = textureWidth / actualFrameWidth;
         var textureHeight:int = texture.height;
         var actualFrameHeight:int = Math.min(frameHeight,textureHeight);
         var numRows:int = textureHeight / actualFrameHeight;
         var numFrames:int = numColumns * numRows;
         if(maxFrames > 0 && numFrames > maxFrames)
         {
            numFrames = maxFrames;
         }
         var frames:Vector.<UVFrame> = new Vector.<UVFrame>(numFrames);
         var frameIndex:int = 0;
         for(var rowIndex:int = 0; rowIndex < numRows; rowIndex++)
         {
            topY = rowIndex * actualFrameHeight;
            bottomY = topY + actualFrameHeight;
            for(columIndex = 0; columIndex < numColumns; columIndex++)
            {
               leftX = columIndex * actualFrameWidth;
               rightX = leftX + actualFrameWidth;
               var _loc20_:* = frameIndex++;
               frames[_loc20_] = new UVFrame(leftX / textureWidth,topY / textureHeight,rightX / textureWidth,bottomY / textureHeight);
               if(frameIndex == numFrames)
               {
                  return frames;
               }
            }
         }
         return frames;
      }
   }
}
