package tanki2
{
   public class GameObject
   {
      
      private static var lastId:int;
       
      
      public var id:int;
      
      public var game:Game;
      
      public var name:String;
      
      public var controller:IGameObjectController;
      
      public function GameObject(id:int, name:String = "")
      {
         super();
         this.id = id;
         this.name = name;
      }
      
      public static function getId() : int
      {
         return lastId++;
      }
      
      public function addToGame(game:Game) : void
      {
         this.game = game;
      }
      
      public function removeFromGame() : void
      {
         this.game = null;
      }
      
      public function update(time:uint, deltaMsec:uint, deltaSec:Number, t:Number) : void
      {
      }
   }
}
