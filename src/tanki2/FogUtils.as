package tanki2 
{
   import alternativa.engine3d.materials.FogMode;
   import alternativa.engine3d.materials.StandardMaterial;
   import alternativa.engine3d.resources.BitmapTextureResource;
   import flash.display.BitmapData;
   import tanki2.maploader.MapMaterial;
   import tanki2.vehicles.tank.skin.TankMaterial;
   import tanki2.vehicles.tank.skin.TrackMaterial;
   import alternativa.engine3d.alternativa3d;
   
   use namespace alternativa3d;
   
	/**
    * ...
    * @author juhe
    */
   public class FogUtils 
   {
      
      public function FogUtils() 
      {
         
      }
      
      // textureString can be found from original tanki 2.0 demo's config file.
      public static function setFog(textureString:String, fogNear:Number, fogFar:Number, fogDensity:Number):void 
      {
         var fogBitmapData:BitmapData = createFogTexture(textureString, 128);
         var fogTexture:BitmapTextureResource = new BitmapTextureResource(fogBitmapData);
         
         StandardMaterial.fogMode = FogMode.ADVANCED
         StandardMaterial.fogTexture = fogTexture;
         StandardMaterial.fogMaxDensity = fogDensity;
         StandardMaterial.fogNear = fogNear;
         StandardMaterial.fogFar = fogFar;
         
         MapMaterial.fogMode = FogMode.ADVANCED
         MapMaterial.fogTexture = fogTexture;
         MapMaterial.fogMaxDensity = fogDensity;
         MapMaterial.fogNear = fogNear;
         MapMaterial.fogFar = fogFar;
         
         TankMaterial.fogMode = FogMode.ADVANCED
         TankMaterial.fogTexture = fogTexture;
         TankMaterial.fogMaxDensity = fogDensity;
         TankMaterial.fogNear = fogNear;
         TankMaterial.fogFar = fogFar;
         
         TrackMaterial.fogMode = FogMode.ADVANCED
         TrackMaterial.fogTexture = fogTexture;
         TrackMaterial.fogMaxDensity = fogDensity;
         TrackMaterial.fogNear = fogNear;
         TrackMaterial.fogFar = fogFar;
      }
      
      private static function createFogTexture(textureParams:String, textureWidth:int) : BitmapData
      {
         var i:int = 0;
         var angle:Number = NaN;
         var color:uint = 0;
         var bitmapData:BitmapData = null;
         var angles:Vector.<Number> = null;
         var colors:Vector.<uint> = null;
         var paramValues:Array = textureParams.split(" ");
         if(paramValues.length > 1)
         {
            bitmapData = new BitmapData(textureWidth,1,false,16777215);
            paramValues.sort(fogParamFilter);
            angles = new Vector.<Number>(paramValues.length);
            colors = new Vector.<uint>(paramValues.length);
            for(i = 0; i < paramValues.length; i++)
            {
               angle = parseFloat(paramValues[i].substr(0,paramValues[i].indexOf(":")));
               color = parseInt(paramValues[i].substr(paramValues[i].indexOf(":") + 1),16);
               angles[i] = angle;
               colors[i] = color;
            }
            for(i = 0; i < textureWidth; i++)
            {
               angle = i / textureWidth * 360;
               color = someColorFunction(angle,angles,colors);
               bitmapData.setPixel(i,0,color);
            }
         }
         else
         {
            color = parseInt(paramValues[0].substr(paramValues[0].indexOf(":") + 1),16);
            bitmapData = new BitmapData(1,1,false,color);
         }
         return bitmapData;
      }
      
      private static function fogParamFilter(a:String, b:String) : int
      {
         var valA:Number = parseFloat(a.substr(0,a.indexOf(":")));
         var valB:Number = parseFloat(b.substr(0,b.indexOf(":")));
         return valA > valB ? int(1) : (valA < valB ? int(-1) : int(0));
      }
      
      private static function someColorFunction(currAngle:Number, angles:Vector.<Number>, colors:Vector.<uint>) : uint
      {
         var leftAngle:Number = NaN;
         var rightAngle:Number = NaN;
         var leftColor:uint = 0;
         var rightColor:uint = 0;
         var weight:Number = NaN;
         var i:int = 0;
         if(currAngle <= angles[0] || currAngle >= angles[angles.length - 1])
         {
            leftAngle = angles[angles.length - 1];
            leftColor = colors[angles.length - 1];
            rightAngle = angles[0];
            rightColor = colors[0];
            if(currAngle <= rightAngle)
            {
               weight = 1 - (rightAngle - currAngle) / (rightAngle - leftAngle + 360);
            }
            else
            {
               weight = (currAngle - leftAngle) / (rightAngle - leftAngle + 360);
            }
         }
         else
         {
            leftAngle = angles[0];
            for(i = 1; i < angles.length; i++)
            {
               rightAngle = angles[i];
               if(currAngle >= leftAngle && currAngle <= rightAngle)
               {
                  leftColor = colors[i - 1];
                  rightColor = colors[i];
                  weight = (currAngle - leftAngle) / (rightAngle - leftAngle);
                  break;
               }
               leftAngle = rightAngle;
            }
         }
         var lR:uint = leftColor >> 16 & 255;
         var lG:uint = leftColor >> 8 & 255;
         var lB:uint = leftColor & 255;
         var rR:uint = rightColor >> 16 & 255;
         var rG:uint = rightColor >> 8 & 255;
         var rB:uint = rightColor & 255;
         var r:uint = rR * weight + lR * (1 - weight);
         var g:uint = rG * weight + lG * (1 - weight);
         var b:uint = rB * weight + lB * (1 - weight);
         return r << 16 | g << 8 | b;
      }
      
   }

}