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
	import alternativa.engine3d.materials.compiler.Linker;
	import alternativa.engine3d.materials.compiler.Procedure;
	import alternativa.engine3d.materials.compiler.VariableType;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.resources.Geometry;
	import alternativa.engine3d.resources.TextureResource;

	import avmplus.getQualifiedClassName;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.VertexBuffer3D;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	use namespace alternativa3d;

	/**
	 * The material fills surface with bitmap image in light-independent manner. Can draw a Skin with no more than 41 Joints per surface. See Skin.divide() for more details.
	 * 
	 * To be drawn with this material, geometry shoud have UV coordinates.
	 * @see alternativa.engine3d.objects.Skin#divide()
	 * @see alternativa.engine3d.core.VertexAttributes#TEXCOORDS
	 */
	public class BeamMaterial extends Material {

		private static var caches:Dictionary = new Dictionary(true);
		private var cachedContext3D:Context3D;
		private var programsCache:Dictionary;
      
      public static var fadeRadius:Number = 7000;
      
      public static var spotAngle:Number = 140 * Math.PI / 180;
      
      public static var fallofAngle:Number = 170 * Math.PI / 180;

		private static const passColorProcedure:Procedure = new Procedure(
      [
      
         "#a0=aUV",
         "#v0=vUV",
         "#v1=vCameraPos",
         "#v2=vNormal",
         "#c0=cCameraPos",
         "mov v0,a0",
         "sub v1, c0, i0",
         "mov v2, i1"
         
      ],"passColor");
      
      private static const outputProcedure:Procedure = new Procedure(
      [
      
         "#v0=vUV",
         "#v1=vCameraPos",
         "#v2=vNormal",
         "#c0=cZone",
         "#s0=sTexture",
         "dp3 t1.w, v1, v1",
         "rsq t1.w, t1.w",
         "mul t0.xyz, v1.xyz, t1.w",
         "nrm t1.xyz, v2", "dp3 t1.x, t0.xyz, t1.xyz",
         "add t1.x, t1.x, c0.z",
         "mul t1.x, t1.x, c0.y",
         "sat t1.x, t1.x",
         "div t1.w, c0.x, t1.w",
         "sat t1.w, t1.w",
         "mul t1.x, t1.x, t1.w",
         "tex t0, v0, s0 <2d, clamp, linear, miplinear>",
         "mul t0, t0.x, t1.x", "mov o0, t0"
         
      ],"output");
      
      public var texture:TextureResource;
		
		/**
		 * Creates a new TextureMaterial instance.
		 *
		 * @param diffuseMap Diffuse map.
		 * @param alpha Transparency.
		 */
		public function BeamMaterial(texture:TextureResource) 
      {
         super();
         this.texture = texture;
      }

		/**
		 * @private
		 */
		override alternativa3d function fillResources(resources:Dictionary, resourceType:Class):void {
			super.fillResources(resources,resourceType);
         if(this.texture != null && A3DUtils.checkParent(getDefinitionByName(getQualifiedClassName(this.texture)) as Class,resourceType))
         {
            resources[this.texture] = true;
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
		private function getProgram(object:Object3D, programs:Vector.<BeamMaterialProgram>, camera:Camera3D, opacityMap:TextureResource, alphaTest:int):BeamMaterialProgram {
			var key:int = (opacityMap != null ? 3 : 0) + alphaTest;
			var program:BeamMaterialProgram = programs[key];
			if (program == null) {
				// Make program
				// Vertex shader
				var vertexLinker:Linker = new Linker(Context3DProgramType.VERTEX);
				
				var positionVar:String = "aPosition";
            var normalVar:String = "aNormal";
				vertexLinker.declareVariable(positionVar, VariableType.ATTRIBUTE);
				if (object.transformProcedure != null) {
					positionVar = appendPositionTransformProcedure(object.transformProcedure, vertexLinker);
				}
            
            vertexLinker.declareVariable(normalVar, VariableType.ATTRIBUTE);
            if (object.deltaTransformProcedure != null) {
               vertexLinker.declareVariable("tTransformedNormal");
               vertexLinker.addProcedure(object.deltaTransformProcedure,normalVar);
               vertexLinker.setOutputParams(object.deltaTransformProcedure,"tTransformedNormal");
               normalVar = "tTransformedNormal"; 
            }
				vertexLinker.addProcedure(_projectProcedure);
				vertexLinker.setInputParams(_projectProcedure, positionVar);
				vertexLinker.addProcedure(passColorProcedure, positionVar, normalVar);

				// Pixel shader
				var fragmentLinker:Linker = new Linker(Context3DProgramType.FRAGMENT);
				fragmentLinker.addProcedure(outputProcedure);
				fragmentLinker.varyings = vertexLinker.varyings;
				
				program = new BeamMaterialProgram(vertexLinker, fragmentLinker);

				program.upload(camera.context3D);
				programs[key] = program;
			}
			return program;
		}
		
		private function getDrawUnit(program:BeamMaterialProgram, camera:Camera3D, surface:Surface, geometry:Geometry, opacityMap:TextureResource):DrawUnit {
			var positionBuffer:VertexBuffer3D = geometry.getVertexBuffer(VertexAttributes.POSITION);
			var uvBuffer:VertexBuffer3D = geometry.getVertexBuffer(VertexAttributes.TEXCOORDS[0]);
         var normalsBuffer:VertexBuffer3D = geometry.getVertexBuffer(VertexAttributes.NORMAL);

			var object:Object3D = surface.object;

			// Draw call
			var drawUnit:DrawUnit = camera.renderer.createDrawUnit(object, program.program, geometry._indexBuffer, surface.indexBegin, surface.numTriangles, program);

			// Streams
			drawUnit.setVertexBufferAt(program.aPosition, positionBuffer, geometry._attributesOffsets[VertexAttributes.POSITION], VertexAttributes.FORMATS[VertexAttributes.POSITION]);
			drawUnit.setVertexBufferAt(program.aUV, uvBuffer, geometry._attributesOffsets[VertexAttributes.TEXCOORDS[0]], VertexAttributes.FORMATS[VertexAttributes.TEXCOORDS[0]]);
			drawUnit.setVertexBufferAt(program.aNormal, normalsBuffer, geometry._attributesOffsets[VertexAttributes.NORMAL], VertexAttributes.FORMATS[VertexAttributes.NORMAL]);
         
			//Constants
			object.setTransformConstants(drawUnit, surface, program.vertexShader, camera);
			drawUnit.setProjectionConstants(camera, program.cProjMatrix, object.localToCameraTransform);
         
         var tm:Transform3D = object.cameraToLocalTransform;
         drawUnit.setVertexConstantsFromNumbers(program.cCameraPos,tm.d,tm.h,tm.l);
         
         var offset:Number = Math.cos(fallofAngle / 2);
         var mul:Number = Math.cos(spotAngle / 2) - offset;
         if(mul < 0.00001)
         {
            mul = 0.00001;
         }
         drawUnit.setFragmentConstantsFromNumbers(program.cZone, 1 / fadeRadius, (1 - offset) / mul, -offset);
         
			// Textures
			drawUnit.setTextureAt(program.sTexture, texture._texture);
			return drawUnit;
		}

		/**
		 * @private
		 */
		override alternativa3d function collectDraws(camera:Camera3D, surface:Surface, geometry:Geometry, lights:Vector.<Light3D>, lightsLength:int, useShadow:Boolean, objectRenderPriority:int = -1):void {
			var object:Object3D = surface.object;
			
			// Buffers
			var positionBuffer:VertexBuffer3D = geometry.getVertexBuffer(VertexAttributes.POSITION);
			var uvBuffer:VertexBuffer3D = geometry.getVertexBuffer(VertexAttributes.TEXCOORDS[0]);
			
			// Check validity
			if (positionBuffer == null || uvBuffer == null) return;
			
			// Refresh program cache for this context
			if (camera.context3D != cachedContext3D) {
				cachedContext3D = camera.context3D;
				programsCache = caches[cachedContext3D];
				if (programsCache == null) {
					programsCache = new Dictionary();
					caches[cachedContext3D] = programsCache;
				}
			}
			var optionsPrograms:Vector.<BeamMaterialProgram> = programsCache[object.transformProcedure];
			if(optionsPrograms == null) {
				optionsPrograms = new Vector.<BeamMaterialProgram>(6, true);
				programsCache[object.transformProcedure] = optionsPrograms;
			}
         

			var program:BeamMaterialProgram;
			var drawUnit:DrawUnit;
         
         // Alpha threshold
         //program = getProgram(object, optionsPrograms, camera, opacityMap, 2);
         //drawUnit = getDrawUnit(program, camera, surface, geometry, opacityMap);
         
         // There is no Alpha threshold or check z-buffer by previous pass
         program = getProgram(object, optionsPrograms, camera, texture, 0);
         drawUnit = getDrawUnit(program, camera, surface, geometry, texture);
         
         // Do not use z-buffer, draws with blending
         drawUnit.blendSource = Context3DBlendFactor.SOURCE_ALPHA;
         drawUnit.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
         camera.renderer.addDrawUnit(drawUnit, objectRenderPriority >= 0 ? objectRenderPriority : Renderer.TRANSPARENT_SORT);
			
		}

		/**
		 * @inheritDoc
		 */
		override public function clone():Material {
			var res:BeamMaterial = new BeamMaterial(texture);
			res.clonePropertiesFrom(this);
			return res;
		}

		/**
		 * @inheritDoc
		 */
		override protected function clonePropertiesFrom(source:Material):void {
			super.clonePropertiesFrom(source);
			var tex:BeamMaterial = source as BeamMaterial;
		}

	}
}

import alternativa.engine3d.materials.ShaderProgram;
import alternativa.engine3d.materials.compiler.Linker;

import flash.display3D.Context3D;

class BeamMaterialProgram extends ShaderProgram {

	public var aPosition:int = -1;
	public var aUV:int = -1;
   public var aNormal = -1;
	public var cProjMatrix:int = -1;
   public var cZone:int = -1;
   public var cCameraPos = -1;
	public var sTexture:int = -1;

	public function BeamMaterialProgram(vertex:Linker, fragment:Linker) {
		super(vertex, fragment);
	}

	override public function upload(context3D:Context3D):void {
		super.upload(context3D);

		aPosition = vertexShader.findVariable("aPosition");
		aUV = vertexShader.findVariable("aUV");
		aNormal = vertexShader.findVariable("aNormal");
		cProjMatrix = vertexShader.findVariable("cProjMatrix");
      cCameraPos = vertexShader.findVariable("cCameraPos");
      cZone = fragmentShader.findVariable("cZone");
		sTexture = fragmentShader.findVariable("sTexture");
	}

}
