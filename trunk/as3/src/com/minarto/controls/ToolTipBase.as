package com.minarto.controls {
	import scaleform.clik.core.UIComponent;

	
	/**
	 * @author KIMMINHWAN
	 */
	public class ToolTipBase extends UIComponent {
		protected var data:*;
		
		
		public function setData($d:*) : void {
			delBind();
			data = $d;
			addBind();
		}
		
		
		protected function delBind():void{
			//ListBinding.delDataBind(data, dataConvert, HashKeyManager.url);
		}
		
		
		protected function addBind():void{
			//ListBinding.addDataBind(data, dataConvert, HashKeyManager.url);
		}
		
		
		protected function dataConvert():void{
			if(data){
				invalidate();
			}
		}
		
		
		override public function toString() : String {
			return "com.minarto.controls.ToolTipBase";
		}
	}
}
