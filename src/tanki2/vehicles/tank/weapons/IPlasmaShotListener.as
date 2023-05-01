package tanki2.vehicles.tank.weapons
{
   import alternativa.math.Vector3;
   import alternativa.physics.Body;
   import alternativa.tanks.vehicles.tank.weapons.sfx.PlasmaShot;
   
   public interface IPlasmaShotListener
   {
       
      
      function shotDissolved(param1:PlasmaShot) : void;
      
      function shotHit(param1:PlasmaShot, param2:Vector3, param3:Vector3, param4:Body, param5:Number) : void;
   }
}
