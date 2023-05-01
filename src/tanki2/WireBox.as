package tanki2
{
   import alternativa.engine3d.materials.FillMaterial;
   import alternativa.engine3d.materials.Material;
   import alternativa.engine3d.objects.Surface;
   import alternativa.engine3d.primitives.Box;
   import alternativa.engine3d.alternativa3d;
   import flash.utils.Dictionary;
   
   use namespace alternativa3d;
   
   public class WireBox extends Box
   {
      
      private static const materials:Dictionary = new Dictionary();
       
      
      public function WireBox(width:Number, length:Number, height:Number, color:uint)
      {
         super(width,length,height);
         var material:Material = getMaterial(color);
         
         for each(var surface:Surface in this._surfaces)
         {
            surface.material = material;
         }
      }
      
      private static function getMaterial(color:uint) : Material
      {
         var material:Material = materials[color];
         if(material == null)
         {
            material = new FillMaterial(color);
            materials[color] = material;
         }
         return material;
      }
   }
}
