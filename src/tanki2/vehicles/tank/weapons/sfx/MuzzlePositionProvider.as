package tanki2.vehicles.tank.weapons.sfx
{
   import alternativa.math.Vector3;
   import alternativa.tanks.vehicles.tank.Tank;
   
   public class MuzzlePositionProvider implements PositionProvider
   {
       
      
      private var tank:Tank;
      
      private var offset:Number;
      
      public function MuzzlePositionProvider(tank:Tank, offset:Number)
      {
         super();
         this.tank = tank;
         this.offset = offset;
      }
      
      public function readPosition(position:Vector3) : void
      {
         this.tank.getWeapon().calculateTurretParams();
         position.copy(this.tank.getWeapon().getMuzzlePosition());
         position.addScaled(this.offset,this.tank.getWeapon().getBarrelDirection());
      }
   }
}
