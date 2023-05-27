/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/ 
 * */

package tanki2.maploader {

	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.DrawUnit;
	import alternativa.engine3d.core.Light3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Renderer;
   import alternativa.engine3d.core.Transform3D;
	import alternativa.engine3d.core.VertexAttributes;
   import alternativa.engine3d.materials.A3DUtils;
   import alternativa.engine3d.materials.Material;
   import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.materials.compiler.Linker;
	import alternativa.engine3d.materials.compiler.Procedure;
	import alternativa.engine3d.materials.compiler.VariableType;
	import alternativa.engine3d.objects.Surface;
   import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.resources.Geometry;
	import alternativa.engine3d.resources.TextureResource;
   import flash.display.BitmapData;

	import avmplus.getQualifiedClassName;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.VertexBuffer3D;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	use namespace alternativa3d;
    
	public class MapMaterial extends TextureMaterial {

		private static var caches:Dictionary = new Dictionary(true);
		private var cachedContext3D:Context3D;
		private var programsCache:Dictionary;
      
   /**
    * @private
    */
   alternativa3d static const DISABLED:int = 0;
   /**
    * @private
    */
   alternativa3d static const SIMPLE:int = 1;
   /**
    * @private
    */
   alternativa3d static const ADVANCED:int = 2;

   /**
    * @private
    */
   alternativa3d static var fogMode:int = DISABLED;
   /**
    * @private
    */
   alternativa3d static var fogNear:Number = 1000;
   /**
    * @private
    */
   alternativa3d static var fogFar:Number = 5000;

   /**
    * @private
    */
   alternativa3d static var fogMaxDensity:Number = 1;

   /**
    * @private
    */
   alternativa3d static var fogColorR:Number = 0xC8/255;
   /**
    * @private
    */
   alternativa3d static var fogColorG:Number = 0xA2/255;
   /**
    * @private
    */
   alternativa3d static var fogColorB:Number = 0xC8/255;

   /**
    * @private
    */
   alternativa3d static var fogTexture:TextureResource;

		// inputs: color
      // NOTE: original is miplinenar not mipnone
		private static const _applyLightMapProcedure:Procedure = new Procedure([
			"#v0=vUV1",
			"#s0=sLightMap",
			"tex t0, v0, s0 <2d,repeat,linear,mipnone>",
			"add t0, t0, t0",
			"mul i0.xyz, i0.xyz, t0.xyz",
			"mov o0, i0"
		], "applyLightMapProcedure");

		private static const _passLightMapUVProcedure:Procedure = new Procedure([
			"#a0=aUV1",
			"#v0=vUV1",
			"mov v0, a0"
		], "passLightMapUVProcedure");
      
      // inputs : position
		private static const passSimpleFogConstProcedure:Procedure = new Procedure([
			"#v0=vZDistance",
			"#c0=cFogSpace",
			"dp4 t0.z, i0, c0",
			"mov v0, t0.zzzz",
			"sub v0.y, i0.w, t0.z"
		], "passSimpleFogConst");

		// inputs : color
		private static const outputWithSimpleFogProcedure:Procedure = new Procedure([
			"#v0=vZDistance",
			"#c0=cFogColor",
			"#c1=cFogRange",
			// Restrict fog factor with the range
			"min t0.xy, v0.xy, c1.xy",
			"max t0.xy, t0.xy, c1.zw",
			"mul i0.xyz, i0.xyz, t0.y",
			"mul t0.xyz, c0.xyz, t0.x",
			"add i0.xyz, i0.xyz, t0.xyz",
			"mov o0, i0"
		], "outputWithSimpleFog");

		// inputs : position, projected
		private static const postPassAdvancedFogConstProcedure:Procedure = new Procedure([
			"#v0=vZDistance",
			"#c0=cFogSpace",
			"dp4 t0.z, i0, c0",
			"mov v0, t0.zzzz",
			"sub v0.y, i0.w, t0.z",
			// Screen x coordinate
			"mov v0.zw, i1.xwxw",
			"mov o0, i1"
		], "postPassAdvancedFogConst");

		// inputs : color
		private static const outputWithAdvancedFogProcedure:Procedure = new Procedure([
			"#v0=vZDistance",
			"#c0=cFogConsts",
			"#c1=cFogRange",
			"#s0=sFogTexture",
			// Restrict fog factor with the range
			"min t0.xy, v0.xy, c1.xy",
			"max t0.xy, t0.xy, c1.zw",
			"mul i0.xyz, i0.xyz, t0.y",
			// Calculate fog color
			"mov t1.xyzw, c0.yyzw",
			"div t0.z, v0.z, v0.w",
			"mul t0.z, t0.z, c0.x",
			"add t1.x, t1.x, t0.z",
			"tex t1, t1, s0 <2d, repeat, linear, miplinear>",
			"mul t0.xyz, t1.xyz, t0.x",
			"add i0.xyz, i0.xyz, t0.xyz",
			"mov o0, i0"
		], "outputWithAdvancedFog");

		/**
		 * Light map.
		 */
		public var lightMap:TextureResource;
		/**
		 * Number of the UV-channel for light map.
		 */
		public var lightMapChannel:uint = 0;

		/**
		 * Creates a new LightMapMaterial instance.
		 * @param diffuseMap Diffuse texture.
		 * @param lightMap  Light map.
		 * @param lightMapChannel Number of the UV-channel for light map.
		 */
		public function MapMaterial(diffuseMap:TextureResource = null, lightMap:TextureResource = null, lightMapChannel:uint = 0, opacityMap:TextureResource = null) {
			super(diffuseMap, opacityMap);
			this.lightMap = lightMap;
			this.lightMapChannel = lightMapChannel;
		}

		/**
		 * @inheritDoc
		 */
		override public function clone():Material {
			var res:MapMaterial = new MapMaterial(diffuseMap, lightMap, lightMapChannel, opacityMap);
			res.clonePropertiesFrom(this);
			return res;
		}

		/**
		 * @private 
		 */
		override alternativa3d function fillResources(resources:Dictionary, resourceType:Class):void {
			super.fillResources(resources, resourceType);

			if (lightMap != null &&
					A3DUtils.checkParent(getDefinitionByName(getQualifiedClassName(lightMap)) as Class, resourceType)) {
				resources[lightMap] = true;
			}
         
         if (fogTexture != null &&
					A3DUtils.checkParent(getDefinitionByName(getQualifiedClassName(fogTexture)) as Class, resourceType)) {
				resources[fogTexture] = true;
			}
		}

		/**
		 * @param object
		 * @param programs
		 * @param camera
		 * @param opacityMap
		 * @param alphaTest 0 - disabled, 1 - opaque, 2 - contours
		 * @return
		 */
		private function getProgram(object:Object3D, programs:Vector.<LightMapMaterialProgram>, camera:Camera3D, opacityMap:TextureResource, alphaTest:int):LightMapMaterialProgram {
			var key:int = (opacityMap != null ? 3 : 0) + alphaTest;
			var program:LightMapMaterialProgram = programs[key];
			if (program == null) {
				// Make program
				// Vertex shader
				var vertexLinker:Linker = new Linker(Context3DProgramType.VERTEX);

				var positionVar:String = "aPosition";
				vertexLinker.declareVariable(positionVar, VariableType.ATTRIBUTE);
				if (object.transformProcedure != null) {
					positionVar = appendPositionTransformProcedure(object.transformProcedure, vertexLinker);
				}
				vertexLinker.addProcedure(_projectProcedure);
				vertexLinker.setInputParams(_projectProcedure, positionVar);
				vertexLinker.addProcedure(_passUVProcedure);
				vertexLinker.addProcedure(_passLightMapUVProcedure);

				// Pixel shader
				var fragmentLinker:Linker = new Linker(Context3DProgramType.FRAGMENT);
				fragmentLinker.declareVariable("tColor");
				var outProcedure:Procedure = (opacityMap != null ? getDiffuseOpacityProcedure : getDiffuseProcedure);
				fragmentLinker.addProcedure(outProcedure);
				fragmentLinker.setOutputParams(outProcedure, "tColor");

				if (alphaTest > 0) {
					outProcedure = alphaTest == 1 ? thresholdOpaqueAlphaProcedure : thresholdTransparentAlphaProcedure;
					fragmentLinker.addProcedure(outProcedure, "tColor");
					fragmentLinker.setOutputParams(outProcedure, "tColor");
				}

				fragmentLinker.addProcedure(_applyLightMapProcedure, "tColor");
            
            if (fogMode == SIMPLE || fogMode == ADVANCED) {
					fragmentLinker.setOutputParams(_applyLightMapProcedure, "tColor");
				}
				if (fogMode == SIMPLE) {
					vertexLinker.addProcedure(passSimpleFogConstProcedure);
					vertexLinker.setInputParams(passSimpleFogConstProcedure, positionVar);
					fragmentLinker.addProcedure(outputWithSimpleFogProcedure);
					fragmentLinker.setInputParams(outputWithSimpleFogProcedure, "tColor");
					outProcedure = outputWithSimpleFogProcedure;
				} else if (fogMode == ADVANCED) {
					vertexLinker.declareVariable("tProjected");
					vertexLinker.setOutputParams(_projectProcedure, "tProjected");
					vertexLinker.addProcedure(postPassAdvancedFogConstProcedure);
					vertexLinker.setInputParams(postPassAdvancedFogConstProcedure, positionVar, "tProjected");
					fragmentLinker.addProcedure(outputWithAdvancedFogProcedure);
					fragmentLinker.setInputParams(outputWithAdvancedFogProcedure, "tColor");
					outProcedure = outputWithAdvancedFogProcedure;
				}

				fragmentLinker.varyings = vertexLinker.varyings;

				program = new LightMapMaterialProgram(vertexLinker, fragmentLinker);

				program.upload(camera.context3D);
				programs[key] = program;
			}
			return program;
		}

		private function getDrawUnit(program:LightMapMaterialProgram, camera:Camera3D, surface:Surface, geometry:Geometry, opacityMap:TextureResource):DrawUnit {
			var positionBuffer:VertexBuffer3D = geometry.getVertexBuffer(VertexAttributes.POSITION);
			var uvBuffer:VertexBuffer3D = geometry.getVertexBuffer(VertexAttributes.TEXCOORDS[0]);
			var lightMapUVBuffer:VertexBuffer3D = geometry.getVertexBuffer(VertexAttributes.TEXCOORDS[lightMapChannel]);

			var object:Object3D = surface.object;

			// Drawcall
			var drawUnit:DrawUnit = camera.renderer.createDrawUnit(object, program.program, geometry._indexBuffer, surface.indexBegin, surface.numTriangles, program);

			// Streams
			drawUnit.setVertexBufferAt(program.aPosition, positionBuffer, geometry._attributesOffsets[VertexAttributes.POSITION], VertexAttributes.FORMATS[VertexAttributes.POSITION]);
			drawUnit.setVertexBufferAt(program.aUV, uvBuffer, geometry._attributesOffsets[VertexAttributes.TEXCOORDS[0]], VertexAttributes.FORMATS[VertexAttributes.TEXCOORDS[0]]);
			drawUnit.setVertexBufferAt(program.aUV1, lightMapUVBuffer, geometry._attributesOffsets[VertexAttributes.TEXCOORDS[lightMapChannel]], VertexAttributes.FORMATS[VertexAttributes.TEXCOORDS[lightMapChannel]]);
			// Constants
			object.setTransformConstants(drawUnit, surface, program.vertexShader, camera);
			drawUnit.setProjectionConstants(camera, program.cProjMatrix, object.localToCameraTransform);
			drawUnit.setFragmentConstantsFromNumbers(program.cThresholdAlpha, alphaThreshold, 0, 0, alpha);
			// Textures
			drawUnit.setTextureAt(program.sDiffuse, diffuseMap._texture);
			drawUnit.setTextureAt(program.sLightMap, lightMap._texture);
			if (opacityMap != null) {
				drawUnit.setTextureAt(program.sOpacity, opacityMap._texture);
			}
         
         if (fogMode == SIMPLE || fogMode == ADVANCED) {
				var lm:Transform3D = object.localToCameraTransform;
				var dist:Number = fogFar - fogNear;
				drawUnit.setVertexConstantsFromNumbers(program.vertexShader.getVariableIndex("cFogSpace"), lm.i/dist, lm.j/dist, lm.k/dist, (lm.l - fogNear)/dist);
				drawUnit.setFragmentConstantsFromNumbers(program.fragmentShader.getVariableIndex("cFogRange"), fogMaxDensity, 1, 0, 1 - fogMaxDensity);
			}
			if (fogMode == SIMPLE) {
				drawUnit.setFragmentConstantsFromNumbers(program.fragmentShader.getVariableIndex("cFogColor"), fogColorR, fogColorG, fogColorB);
			}
			if (fogMode == ADVANCED) {
				if (fogTexture == null) {
					var bmd:BitmapData = new BitmapData(32, 1, false, 0xFF0000);
					for (var i:int = 0; i < 32; i++) {
						bmd.setPixel(i, 0, ((i/32)*255) << 16);
					}
					fogTexture = new BitmapTextureResource(bmd);
					fogTexture.upload(camera.context3D);
				}
				var cLocal:Transform3D = camera.localToGlobalTransform;
				var halfW:Number = camera.view.width/2;
				var leftX:Number = -halfW*cLocal.a + camera.focalLength*cLocal.c;
				var leftY:Number = -halfW*cLocal.e + camera.focalLength*cLocal.g;
				var rightX:Number = halfW*cLocal.a + camera.focalLength*cLocal.c;
				var rightY:Number = halfW*cLocal.e + camera.focalLength*cLocal.g;
				// Finding UV
				var angle:Number = (Math.atan2(leftY, leftX) - Math.PI/2);
				if (angle < 0) angle += Math.PI*2;
				var dx:Number = rightX - leftX;
				var dy:Number = rightY - leftY;
				var lens:Number = Math.sqrt(dx*dx + dy*dy);
				leftX /= lens;
				leftY /= lens;
				rightX /= lens;
				rightY /= lens;
				var uScale:Number = Math.acos(leftX*rightX + leftY*rightY)/Math.PI/2;
				var uRight:Number = angle/Math.PI/2;

				drawUnit.setFragmentConstantsFromNumbers(program.fragmentShader.getVariableIndex("cFogConsts"), 0.5*uScale, 0.5 - uRight, 0);
				drawUnit.setTextureAt(program.fragmentShader.getVariableIndex("sFogTexture"), fogTexture._texture);
			}

			return drawUnit;
		}

		/**
		 * @private
		 */
		override alternativa3d function collectDraws(camera:Camera3D, surface:Surface, geometry:Geometry, lights:Vector.<Light3D>, lightsLength:int, useShadow:Boolean, objectRenderPriority:int = -1):void {
			if (diffuseMap == null || lightMap == null || diffuseMap._texture == null || lightMap._texture == null) return;
			if (opacityMap != null && opacityMap._texture == null) return;

			var object:Object3D = surface.object;

			// Buffers
			var positionBuffer:VertexBuffer3D = geometry.getVertexBuffer(VertexAttributes.POSITION);
			var uvBuffer:VertexBuffer3D = geometry.getVertexBuffer(VertexAttributes.TEXCOORDS[0]);
			var lightMapUVBuffer:VertexBuffer3D = geometry.getVertexBuffer(VertexAttributes.TEXCOORDS[lightMapChannel]);

			if (positionBuffer == null || uvBuffer == null || lightMapUVBuffer == null) return;

			if (camera.context3D != cachedContext3D) {
				cachedContext3D = camera.context3D;
				programsCache = caches[cachedContext3D];
				if (programsCache == null) {
					programsCache = new Dictionary();
					caches[cachedContext3D] = programsCache;
				}
			}

			var optionsPrograms:Vector.<LightMapMaterialProgram> = programsCache[object.transformProcedure];
			if(optionsPrograms == null) {
				optionsPrograms = new Vector.<LightMapMaterialProgram>(6, true);
				programsCache[object.transformProcedure] = optionsPrograms;
			}

			var program:LightMapMaterialProgram;
			var drawUnit:DrawUnit;
			// Opaque pass
			if (opaquePass && alphaThreshold <= alpha) {
				if (alphaThreshold > 0) {
					// Alpha test
					// use opacityMap if it is presented
					program = getProgram(object, optionsPrograms, camera, opacityMap, 1);
					drawUnit = getDrawUnit(program, camera, surface, geometry, opacityMap);
				} else {
					// do not use opacityMap at all
					program = getProgram(object, optionsPrograms, camera, null, 0);
					drawUnit = getDrawUnit(program, camera, surface, geometry, null);
				}
				// Use z-buffer within DrawCall, draws without blending
				camera.renderer.addDrawUnit(drawUnit, objectRenderPriority >= 0 ? objectRenderPriority : Renderer.OPAQUE);
			}
			// Transparent pass
			if (transparentPass && alphaThreshold > 0 && alpha > 0) {
				// use opacityMap if it is presented
				if (alphaThreshold <= alpha && !opaquePass) {
					// Alpha threshold
					program = getProgram(object, optionsPrograms, camera, opacityMap, 2);
					drawUnit = getDrawUnit(program, camera, surface, geometry, opacityMap);
				} else {
					// There is no Alpha threshold or check z-buffer by previous pass
					program = getProgram(object, optionsPrograms, camera, opacityMap, 0);
					drawUnit = getDrawUnit(program, camera, surface, geometry, opacityMap);
				}
				// Do not use z-buffer, draws with blending
				drawUnit.blendSource = Context3DBlendFactor.SOURCE_ALPHA;
				drawUnit.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
				camera.renderer.addDrawUnit(drawUnit, objectRenderPriority >= 0 ? objectRenderPriority : Renderer.TRANSPARENT_SORT);
			}
		}

	}
}

import alternativa.engine3d.materials.ShaderProgram;
import alternativa.engine3d.materials.compiler.Linker;

import flash.display3D.Context3D;

class LightMapMaterialProgram extends ShaderProgram {

	public var aPosition:int = -1;
	public var aUV:int = -1;
	public var aUV1:int = -1;
	public var cProjMatrix:int = -1;
	public var cThresholdAlpha:int = -1;
	public var sDiffuse:int = -1;
	public var sLightMap:int = -1;
	public var sOpacity:int = -1;

	public function LightMapMaterialProgram(vertex:Linker, fragment:Linker) {
		super(vertex, fragment);
	}

	override public function upload(context3D:Context3D):void {
		super.upload(context3D);

		aPosition = vertexShader.findVariable("aPosition");
		aUV = vertexShader.findVariable("aUV");
		aUV1 = vertexShader.findVariable("aUV1");
		cProjMatrix = vertexShader.findVariable("cProjMatrix");
		cThresholdAlpha = fragmentShader.findVariable("cThresholdAlpha");
		sDiffuse = fragmentShader.findVariable("sDiffuse");
		sLightMap = fragmentShader.findVariable("sLightMap");
		sOpacity = fragmentShader.findVariable("sOpacity");
	}

}
