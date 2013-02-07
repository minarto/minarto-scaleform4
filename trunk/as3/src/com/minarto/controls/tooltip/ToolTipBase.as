package com.minarto.controls.tooltip {
	import scaleform.clik.core.UIComponent;

	
	/**
	 * @author KIMMINHWAN
	 */
	public class ToolTipBase extends UIComponent {
		protected var data:*;
		
		
		public function setData($d:*) : void {
			if(data == $d)	return;
			delBind();
			data = $d;
			addBind();
		}
		
		
		protected function delBind():void{
			if(data && !(data as String)){
				//ListBinding.delDataBind(data, invalidate, HashKeyManager.url);
			}
		}
		
		
		protected function addBind():void{
			if(data as String){
				invalidate();
			}
			else if(data){
				//ListBinding.addDataBind(data, invalidate, HashKeyManager.url);
			}
		}
		
		
		override public function toString() : String {
			return "com.minarto.controls.tooltip.ToolTipBase";
		}
	}
}
