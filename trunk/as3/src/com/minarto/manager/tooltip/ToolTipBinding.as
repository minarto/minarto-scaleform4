package com.minarto.manager.tooltip {
	import flash.external.ExternalInterface;
	
	import scaleform.gfx.Extensions;

	
	/**
	 * @author KIMMINHWAN
	 */
	public class ToolTipBinding {
		private static var _manager:IToolTipManager, _reservations:Array = [];
		
		
		public static function init($manager:IToolTipManager):void{
			_manager = $manager;
			if($manager)	$manager.regist.apply(null, _reservations);
			
			if(ExternalInterface.available && Extensions.isScaleform)	ExternalInterface.call("ToolTipBinding", ToolTipBinding);
			trace("ToolTipBinding.init");
		}
		
		
		public function ToolTipBinding(){
			throw new Error("don't create instance");
		}
		
		
		public static function regist(...$button):void{
			if(_manager){
				_manager.regist.apply(null, $button);
			}
			else{
				_reservations.push.apply(null, $button);
			}
		}
		
		
		public static function unRegist(...$button) : void {
			if(_manager){
				_manager.unRegist.apply(null, $button);
			}
			else{
				_reservations.length = 0;
			}
		}
		
		
		public static function addToolTip($d:*):void{
			_manager.addToolTip($d);
		}
		
		
		public static function delToolTip():void{
			_manager.delToolTip();
		}
	}
}