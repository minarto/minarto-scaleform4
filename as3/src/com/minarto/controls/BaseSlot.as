package com.minarto.controls {
	import com.minarto.manager.tooltip.ToolTipBinding;
	
	import flash.display.*;
	
	import scaleform.clik.controls.Button;
	import scaleform.clik.data.ListData;
	import scaleform.clik.interfaces.IListItemRenderer;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class BaseSlot extends Button implements IListItemRenderer {
		public var content:MovieClip;
		
		protected var _index:uint, _selectable:Boolean = true;
		
		public function get index():uint { return _index; }
		public function set index($v:uint):void { _index = $v; }
		
		
		public function get selectable():Boolean { return _selectable; }
		public function set selectable($v:Boolean):void { _selectable = $v; }
		
		
		public function setListData($listData:ListData):void {
			_index = $listData.index;
			_selected = $listData.selected;
		}
		
		
		override public function set data($v:Object):void {
			if(_data == $v)	return;
			delBind();
			_data = $v;
			addBind();
		}
		
		
		override protected function configUI():void{
			super.configUI();
			ToolTipBinding.regist(this);
		}
		
		
		public function setData($data:Object):void {
			if(_data == $data)	return;
			delBind();
			_data = $data;
			addBind();
		}
		
		
		protected function delBind():void{
		}
		
		
		protected function addBind():void{
		}
		
		
		override public function toString() : String {
			return "com.minarto.controls.slot.BaseSlot";
		}
		
		
		protected function onImageLoadComplete($bd:BitmapData):void {
		}
	}
}