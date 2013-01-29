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
			if(data as String){
				dataConvert();
			}
			else if(data){
				//ListBinding.delDataBind(data, dataConvert, HashKeyManager.url);
			}
		}
		
		
		protected function addBind():void{
			if(data as String){
				dataConvert();
			}
			else if(data){
				//ListBinding.addDataBind(data, dataConvert, HashKeyManager.url);
			}
		}
		
		
		protected function dataConvert():void{
		}
		
		
		override public function toString() : String {
			return "com.minarto.controls.ToolTipBase";
		}
	}
}
