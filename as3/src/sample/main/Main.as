package sample.main
{
	import flash.display.DisplayObject;
	import flash.events.*;
		
	import scaleform.clik.controls.Button;
	import scaleform.clik.core.UIComponent;
		
	
	public class Main extends UIComponent
	{
		public var btnHot:Button, btnNew:Button, btnTarget:Button;
		
		
		override protected function configUI():void
		{
         		super.configUI();
			
				btnTarget.data = { };
				btnTarget.label = "대상";
				
				btnHot.label = "hot";
				btnHot.addEventListener(MouseEvent.CLICK, _click);
				
				btnNew.label = "new";
				btnNew.addEventListener(MouseEvent.CLICK, _click);
	    }
		
		
		private function _click($e:Event):void
		{
			var data:* = btnTarget.data, key:String, type:String;
			
			switch($e.target)
			{
				case btnHot : 
					key = "isHot";
					type = "hot";
					break;
				default :
					key = "isNew";
					type = "new";
			}
			
			data[key] = !data[key];
			btnTarget.invalidate(type);
	    }
	}
}
