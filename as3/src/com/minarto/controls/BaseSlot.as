package com.minarto.controls {
	import com.minarto.manager.ToolTipManager;
	
	import flash.display.*;
	
	import scaleform.clik.controls.ListItemRenderer;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class BaseSlot extends ListItemRenderer {
		public var content:DisplayObject;
		
		
		override public function set data($v:*):void {
			if(_data == $v)	return;
			delBind();
			_data = $v;
			addBind();
		}
		
		
		override protected function configUI():void{
			super.configUI();
			ToolTipManager.add(this);
		}
		
		
		override public function setData($data:*):void {
			if(_data == $data)	return;
			delBind();
			_data = $data;
			addBind();
		}
		
		
		protected function delBind():void{
		}
		
		
		protected function addBind():void{
		}
		
		
		protected function onImageLoadComplete($bd:BitmapData):void {
		}
	}
}
