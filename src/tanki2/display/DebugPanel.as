package tanki2.display
{
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   
   public class DebugPanel extends Sprite
   {
       
      
      private var values:Dictionary;
      
      private var count:int;
      
      public function DebugPanel()
      {
         super();
         this.values = new Dictionary();
         mouseEnabled = false;
         tabEnabled = false;
         mouseChildren = false;
         tabChildren = false;
      }
      
      public function printValue(valueName:String, ... args) : void
      {
         var textField:TextField = this.values[valueName];
         if(textField == null)
         {
            textField = this.createTextField();
            this.values[valueName] = textField;
         }
         textField.text = valueName + ": " + args.join(" ");
      }
      
      public function printText(text:String) : void
      {
         this.createTextField().text = text;
      }
      
      private function createTextField() : TextField
      {
         var textField:TextField = new TextField();
         textField.autoSize = TextFieldAutoSize.LEFT;
         addChild(textField);
         textField.defaultTextFormat = new TextFormat("Tahoma",11,16777215);
         textField.y = this.count * 20;
         ++this.count;
         return textField;
      }
   }
}
