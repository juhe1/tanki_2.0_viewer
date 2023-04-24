package tanki2.maploader 
{
   import alternativa.engine3d.materials.Material;
	/**
    * ...
    * @author juhe
    */
   
   import alternativa.engine3d.resources.BitmapTextureResource;
   import alternativa.engine3d.resources.Geometry;
   import alternativa.engine3d.resources.TextureResource;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.DrawUnit;
   import tanki2.maploader.Tanki2MaterialType;
   import alternativa.engine3d.core.Camera3D;
   import alternativa.engine3d.core.VertexAttributes;
   import alternativa.engine3d.core.Transform3D;
   import alternativa.engine3d.objects.Surface;
   import alternativa.engine3d.materials.compiler.VariableType;
   import alternativa.engine3d.materials.compiler.Procedure;
   import alternativa.engine3d.materials.compiler.Linker;
   import alternativa.engine3d.materials.A3DUtils;
   import alternativa.engine3d.materials.Material;
   import §_-Z2§.§_-ZC§;
   import alternativa.engine3d.alternativa3d;
   import avmplus.getQualifiedClassName;
   import flash.display.BitmapData;
   import flash.display3D.Context3DBlendFactor;
   import flash.display3D.Context3DProgramType;
   import flash.display3D.VertexBuffer3D;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   
   use namespace alternativa3d;
    
   public class MapMaterial extends Material
   {
      
      public static const DISABLED:int = 0;
      
      public static const SIMPLE:int = 1;
      
      public static const ADVANCED:int = 2;
      
      public static var fogMode:int = DISABLED;
      
      public static var fogNear:Number = 1000;
      
      public static var fogFar:Number = 5000;
      
      public static var fogMaxDensity:Number = 1;
      
      public static var fogColorR:Number = 200 / 255;
      
      public static var fogColorG:Number = 162 / 255;
      
      public static var fogColorB:Number = 200 / 255;
      
      private static var fogTexture:TextureResource;
      
      private static var _programs:Dictionary = new Dictionary();
      
      private static const getLightMapProcedure:Procedure = Procedure.§_-En§(["#v0=vUV1","#s0=sLightMap","tex o0, v0, s0 <2d,repeat,linear,mipnone>"],"getLightMap");
      
      private static const minShadowProcedure:Procedure = Procedure.§_-En§(["min o0, o0, i0"],"minShadowProc");
      
      private static const mulShadowProcedure:Procedure = Procedure.§_-En§(["mul o0, o0, i0"],"mulShadowProc");
      
      private static const applyLightMapProcedure:Procedure = Procedure.§_-En§(["add i1, i1, i1","mul i0.xyz, i0.xyz, i1.xyz","mov o0, i0"],"applyLightMap");
      
      private static const _passLightMapUVProcedure:Procedure = new Procedure(["#a0=aUV1","#v0=vUV1","mov v0, a0"],"passLightMapUV");
      
      private static const passSimpleFogConstProcedure:Procedure = new Procedure(["#v0=vZDistance","#c0=cFogSpace","dp4 t0.z, i0, c0","mov v0, t0.zzzz","sub v0.y, i0.w, t0.z"],"passSimpleFogConst");
      
      private static const applyLightMapAndSimpleFogProcedure:Procedure = new Procedure(["#v0=vZDistance","#c0=cFogColor","#c1=cFogRange","add i1, i1, i1","mul i0.xyz, i0.xyz, i1.xyz","min t0.xy, v0.xy, c1.xy","max t0.xy, t0.xy, c1.zw","mul i0.xyz, i0.xyz, t0.y","mul t0.xyz, c0.xyz, t0.x","add i0.xyz, i0.xyz, t0.xyz","mov o0, i0"],"applyLightMapAndSimpleFog");
      
      private static const passAdvancedFogConstProcedure:Procedure = new Procedure(["#v0=vZDistance","#c0=cFogSpace","dp4 t0.z, i0, c0","mov v0, t0.zzzz","sub v0.y, i0.w, t0.z","mov v0.zw, i1.xwxw","mov o0, i1"],"projAndPassAdvancedFogConst");
      
      private static const applyLightMapAndAdvancedFogProcedure:Procedure = new Procedure(["#v0=vZDistance","#c0=cFogConsts","#c1=cFogRange","#s0=sFogTexture","add i1, i1, i1","mul i0.xyz, i0.xyz, i1.xyz","min t0.xy, v0.xy, c1.xy","max t0.xy, t0.xy, c1.zw","mul i0.xyz, i0.xyz, t0.y","mov t1.xyzw, c0.yyzw","div t0.z, v0.z, v0.w","mul t0.z, t0.z, c0.x","add t1.x, t1.x, t0.z","tex t1, t1, s0 <2d, repeat, linear, miplinear>","mul t0.xyz, t1.xyz, t0.x","add i0.xyz, i0.xyz, t0.xyz","mov o0, i0"],"applyLightMapAndAdvancedFog");
      
      alternativa3d static const outputOpacity:Procedure = new Procedure(["#v0=vUV","#s0=sTexture","#s1=sOpacity","#c0=cAlpha","tex t0, v0, s0 <2d, linear,repeat, miplinear>","tex t1, v0, s1 <2d, linear,repeat, miplinear>","mov t0.w, t1.x","sub t1.x, t1.x, c0.w","kil t1.x","mov o0, t0"],"samplerSetProcedureOpacity");
      
      private static const passUVProcedure:Procedure = new Procedure(["#v0=vUV","#a0=aUV","mov v0, a0"],"passUVProcedure");
      
      private static const diffuseProcedure:Procedure = new Procedure(["#v0=vUV","#s0=sTexture","#c0=cAlpha","tex t0, v0, s0 <2d, linear,repeat, miplinear>","mov t0.w, c0.w","mov o0, t0"],"diffuseProcedure");
      
      private static const diffuseOpacityProcedure:Procedure = new Procedure(["#v0=vUV","#s0=sTexture","#s1=sOpacity","#c0=cAlpha","tex t0, v0, s0 <2d, linear,repeat, miplinear>","tex t1, v0, s1 <2d, linear,repeat, miplinear>","mov t0.w, t1.x","mul t0.w, t0.w, c0.w","mov o0, t0"],"diffuseOpacityProcedure");
       
      
      public var diffuseMap:TextureResource;
      
      public var lightMap:TextureResource;
      
      public var lightMapChannel:uint = 0;
      
      public var opacityMap:TextureResource;
      
      public var alpha:Number = 1;
      
      public function MapMaterial() 
      {
         super();
         this.diffuseMap = diffuseMap;
         this.lightMap = lightMap;
         this.lightMapChannel = lightMapChannel;
         this.opacityMap = opacityMap;
      }
      
      public static function §_-RX§(texture:TextureResource) : void
      {
         fogTexture = texture;
      }
      
      override alternativa3d function fillResources(resources:Dictionary, resourceType:Class) : void
      {
         super.fillResources(resources,resourceType);
         if(this.diffuseMap != null && A3DUtils.§_-EU§(getDefinitionByName(getQualifiedClassName(this.diffuseMap)) as Class,resourceType))
         {
            resources[this.diffuseMap] = true;
         }
         if(this.lightMap != null && A3DUtils.§_-EU§(getDefinitionByName(getQualifiedClassName(this.lightMap)) as Class,resourceType))
         {
            resources[this.lightMap] = true;
         }
         if(this.opacityMap != null && A3DUtils.§_-EU§(getDefinitionByName(getQualifiedClassName(this.opacityMap)) as Class,resourceType))
         {
            resources[this.opacityMap] = true;
         }
      }
      
      private function final(targetObject:Object3D, shadows:Vector.<§_-ZC§>, numShadows:int) : MapMaterialProgram
      {
         var i:int = 0;
         var renderer:§_-ZC§ = null;
         var sProc:§_-Xk§ = null;
         var vertexLinker:Linker = new Linker(Context3DProgramType.VERTEX);
         var positionVar:String = "aPosition";
         vertexLinker.§_-LU§(positionVar,VariableType.ATTRIBUTE);
         if(targetObject.transformProcedure != null)
         {
            positionVar = §_-di§(targetObject.transformProcedure,vertexLinker);
         }
         vertexLinker.§_-on§(_projectProcedure);
         vertexLinker.§_-FS§(_projectProcedure,positionVar);
         vertexLinker.§_-on§(passUVProcedure);
         vertexLinker.§_-on§(_passLightMapUVProcedure);
         if(fogMode == SIMPLE)
         {
            vertexLinker.§_-on§(passSimpleFogConstProcedure);
            vertexLinker.§_-FS§(passSimpleFogConstProcedure,positionVar);
         }
         else if(fogMode == ADVANCED)
         {
            vertexLinker.§_-LU§("tProjected");
            vertexLinker.§_-qd§(_projectProcedure,"tProjected");
            vertexLinker.§_-on§(passAdvancedFogConstProcedure);
            vertexLinker.§_-FS§(passAdvancedFogConstProcedure,positionVar,"tProjected");
         }
         var fragmentLinker:Linker = new Linker(Context3DProgramType.FRAGMENT);
         var procedure:§_-Xk§ = this.opacityMap == null ? diffuseProcedure : diffuseOpacityProcedure;
         fragmentLinker.§_-LU§("tOutColor");
         fragmentLinker.§_-on§(procedure);
         fragmentLinker.§_-qd§(procedure,"tOutColor");
         if(shadows != null)
         {
            fragmentLinker.§_-LU§("tLight");
            fragmentLinker.§_-on§(getLightMapProcedure);
            fragmentLinker.§_-qd§(getLightMapProcedure,"tLight");
            fragmentLinker.§_-LU§("tShadow");
            for(i = 0; i < numShadows; i++)
            {
               renderer = shadows[i];
               vertexLinker.§_-on§(renderer.getVShader(i));
               sProc = renderer.getFShader(i);
               fragmentLinker.§_-on§(sProc);
               fragmentLinker.§_-qd§(sProc,"tShadow");
               if(renderer.§_-cu§)
               {
                  fragmentLinker.§_-on§(mulShadowProcedure);
                  fragmentLinker.§_-FS§(mulShadowProcedure,"tShadow");
                  fragmentLinker.§_-qd§(mulShadowProcedure,"tLight");
               }
               else
               {
                  fragmentLinker.§_-on§(minShadowProcedure);
                  fragmentLinker.§_-FS§(minShadowProcedure,"tShadow");
                  fragmentLinker.§_-qd§(minShadowProcedure,"tLight");
               }
            }
         }
         else
         {
            fragmentLinker.§_-LU§("tLight");
            fragmentLinker.§_-on§(getLightMapProcedure);
            fragmentLinker.§_-qd§(getLightMapProcedure,"tLight");
         }
         if(fogMode == SIMPLE)
         {
            fragmentLinker.§_-on§(applyLightMapAndSimpleFogProcedure);
            fragmentLinker.§_-FS§(applyLightMapAndSimpleFogProcedure,"tOutColor","tLight");
         }
         else if(fogMode == ADVANCED)
         {
            fragmentLinker.§_-on§(applyLightMapAndAdvancedFogProcedure);
            fragmentLinker.§_-FS§(applyLightMapAndAdvancedFogProcedure,"tOutColor","tLight");
         }
         else
         {
            fragmentLinker.§_-on§(applyLightMapProcedure);
            fragmentLinker.§_-FS§(applyLightMapProcedure,"tOutColor","tLight");
         }
         fragmentLinker.§_-NA§(vertexLinker);
         return new MapMaterialProgram(vertexLinker,fragmentLinker);
      }
      
      override alternativa3d function collectDraws(camera:Camera3D, surface:§_-a2§, geometry:Geometry, lights:Vector.<Light3D>, lightsLength:int, objectRenderPriority:int = -1) : void
      {
         var i:int = 0;
         var renderer:§_-ZC§ = null;
         var lm:Transform3D = null;
         var dist:Number = NaN;
         var cLocal:Transform3D = null;
         var halfW:Number = NaN;
         var leftX:Number = NaN;
         var leftY:Number = NaN;
         var rightX:Number = NaN;
         var rightY:Number = NaN;
         var angle:Number = NaN;
         var dx:Number = NaN;
         var dy:Number = NaN;
         var len:Number = NaN;
         var uScale:Number = NaN;
         var uRight:Number = NaN;
         var bmd:BitmapData = null;
         if(this.diffuseMap == null || this.diffuseMap._texture == null || this.lightMap == null || this.lightMap._texture == null)
         {
            return;
         }
         if(this.opacityMap != null && this.opacityMap._texture == null)
         {
            return;
         }
         var positionBuffer:VertexBuffer3D = geometry.getVertexBuffer(VertexAttributes.POSITION);
         var uvBuffer:VertexBuffer3D = geometry.getVertexBuffer(VertexAttributes.TEXCOORDS[0]);
         var lightMapUVBuffer:VertexBuffer3D = geometry.getVertexBuffer(VertexAttributes.TEXCOORDS[this.lightMapChannel]);
         if(positionBuffer == null || uvBuffer == null || lightMapUVBuffer == null)
         {
            return;
         }
         var object:Object3D = surface.object;
         var optionsPrograms:Vector.<MapMaterialProgram> = _programs[object.transformProcedure];
         if(optionsPrograms == null)
         {
            optionsPrograms = new Vector.<MapMaterialProgram>(32,true);
            _programs[object.transformProcedure] = optionsPrograms;
         }
         var index:int = this.opacityMap == null ? int(0) : int(1);
         if(fogMode > 0)
         {
            index |= 1 << fogMode;
         }
         var numShadows:int = object.numShadowRenderers;
         index |= numShadows << 3;
         var program:MapMaterialProgram = optionsPrograms[index];
         if(program == null)
         {
            program = this.final(object,object.shadowRenderers,numShadows);
            program.upload(camera.context3D);
            optionsPrograms[index] = program;
         }
         var drawUnit:DrawUnit = camera.renderer.§_-2s§(object,program.program,geometry.§_-EM§,surface.indexBegin,surface.numTriangles,program);
         drawUnit.setVertexBufferAt(program.aPosition,positionBuffer,geometry._attributesOffsets[VertexAttributes.POSITION],VertexAttributes.FORMATS[VertexAttributes.POSITION]);
         drawUnit.setVertexBufferAt(program.aUV,uvBuffer,geometry._attributesOffsets[VertexAttributes.TEXCOORDS[0]],VertexAttributes.FORMATS[VertexAttributes.TEXCOORDS[0]]);
         drawUnit.setVertexBufferAt(program.aUV1,lightMapUVBuffer,geometry._attributesOffsets[VertexAttributes.TEXCOORDS[this.lightMapChannel]],VertexAttributes.FORMATS[VertexAttributes.TEXCOORDS[this.lightMapChannel]]);
         object.setTransformConstants(drawUnit,surface,program.vertexShader,camera);
         drawUnit.§_-mQ§(camera,program.cProjMatrix,object.localToCameraTransform);
         drawUnit.§_-Ry§(program.cAlpha,0,0,0,this.alpha);
         drawUnit.setTextureAt(program.sTexture,this.diffuseMap._texture);
         drawUnit.setTextureAt(program.sLightMap,this.lightMap._texture);
         if(this.opacityMap != null)
         {
            drawUnit.setTextureAt(program.sOpacity,this.opacityMap._texture);
         }
         for(i = 0; i < numShadows; )
         {
            renderer = object.shadowRenderers[i];
            renderer.applyShader(drawUnit,program,object,camera,i);
            i++;
         }
         if(fogMode == SIMPLE || fogMode == ADVANCED)
         {
            lm = object.localToCameraTransform;
            dist = fogFar - fogNear;
            drawUnit.§ if§(program.cFogSpace,lm.i / dist,lm.j / dist,lm.k / dist,(lm.l - fogNear) / dist);
            drawUnit.§_-Ry§(program.cFogRange,fogMaxDensity,1,0,1 - fogMaxDensity);
         }
         if(fogMode == SIMPLE)
         {
            drawUnit.§_-Ry§(program.cFogColor,fogColorR,fogColorG,fogColorB);
         }
         if(fogMode == ADVANCED)
         {
            if(fogTexture == null)
            {
               bmd = new BitmapData(32,1,false,16711680);
               for(i = 0; i < 32; i++)
               {
                  bmd.setPixel(i,0,i / 32 * 255 << 16);
               }
               fogTexture = new BitmapTextureResource(bmd);
               fogTexture.upload(camera.context3D);
            }
            cLocal = camera.localToGlobalTransform;
            halfW = camera.view.width / 2;
            leftX = -halfW * cLocal.a + camera.focalLength * cLocal.c;
            leftY = -halfW * cLocal.e + camera.focalLength * cLocal.g;
            rightX = halfW * cLocal.a + camera.focalLength * cLocal.c;
            rightY = halfW * cLocal.e + camera.focalLength * cLocal.g;
            angle = Math.atan2(leftY,leftX) - Math.PI / 2;
            if(angle < 0)
            {
               angle += Math.PI * 2;
            }
            dx = rightX - leftX;
            dy = rightY - leftY;
            len = Math.sqrt(dx * dx + dy * dy);
            leftX /= len;
            leftY /= len;
            rightX /= len;
            rightY /= len;
            uScale = Math.acos(leftX * rightX + leftY * rightY) / Math.PI / 2;
            uRight = angle / Math.PI / 2;
            drawUnit.§_-Ry§(program.cFogConsts,0.5 * uScale,0.5 - uRight,0);
            drawUnit.setTextureAt(program.sFogTexture,fogTexture._texture);
         }
         if(this.opacityMap != null || this.alpha < 1)
         {
            drawUnit.blendSource = Context3DBlendFactor.SOURCE_ALPHA;
            drawUnit.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
            camera.renderer.§_-SH§(drawUnit,objectRenderPriority >= 0 ? int(objectRenderPriority) : int(Tanki2MaterialType.TRANSPARENT_SORT));
         }
         else
         {
            camera.renderer.§_-SH§(drawUnit,objectRenderPriority >= 0 ? int(objectRenderPriority) : int(Tanki2MaterialType.OPAQUE));
         }
      }
   }
}

import §_-M8§.Linker;
import §_-Vh§.§_-RB§;

class MapMaterialProgram extends §_-RB§
{
    
   
   public var aPosition:int;
   
   public var aUV:int;
   
   public var aUV1:int;
   
   public var cProjMatrix:int;
   
   public var cAlpha:int;
   
   public var sTexture:int;
   
   public var sLightMap:int;
   
   public var sOpacity:int;
   
   public var cFogSpace:int;
   
   public var cFogRange:int;
   
   public var cFogColor:int;
   
   public var cFogConsts:int;
   
   public var sFogTexture:int;
   
   function MapMaterialProgram(vertex:Linker, fragment:Linker)
   {
      super(vertex,fragment);
      this.aPosition = vertex.§_-Dj§("aPosition");
      this.aUV = vertex.§_-Dj§("aUV");
      this.aUV1 = vertex.§_-Dj§("aUV1");
      this.cProjMatrix = vertex.§_-Dj§("cProjMatrix");
      this.cAlpha = fragment.§_-Dj§("cAlpha");
      this.sTexture = fragment.§_-Dj§("sTexture");
      this.sLightMap = fragment.§_-Dj§("sLightMap");
      this.sOpacity = fragment.§_-Dj§("sOpacity");
      this.cFogSpace = vertex.§_-Dj§("cFogSpace");
      this.cFogRange = fragment.§_-Dj§("cFogRange");
      this.cFogColor = fragment.§_-Dj§("cFogColor");
      this.cFogConsts = fragment.§_-Dj§("cFogConsts");
      this.sFogTexture = fragment.§_-Dj§("sFogTexture");
   }
}