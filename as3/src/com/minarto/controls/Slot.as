package com.minarto.controls {
	import com.minarto.data.ListBinding;
	import com.minarto.manager.ImageManager;
	import com.minarto.utils.GPool;
	import com.scaleform.mmo.events.TooltipEvent;
	
	import de.polygonal.core.ObjectPool;
	
	import flash.display.*;
	import flash.events.*;
	
	import scaleform.clik.controls.*;
	import scaleform.clik.core.*;
	import scaleform.clik.data.ListData;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.gfx.InteractiveObjectEx;

	
	/**
	 * @author KIMMINHWAN
	 */
	public class Slot extends Button implements IListItemRenderer {
		public var bm:Bitmap, content:MovieClip,
					isDrag:Boolean = true, isUse:Boolean = true;
		
					
		protected var _index:uint, _selectable:Boolean = true,
						tooltipEvt:TooltipEvent = new TooltipEvent(TooltipEvent.REGISTER_ELEMENT, true, false, this as UIComponent);
		
		
		public function get index():uint { return _index; }
        public function set index($v:uint):void { _index = $v; }
		
		
		public function get selectable():Boolean { return _selectable; }
        public function set selectable($v:Boolean):void { _selectable = $v; }
		
		
		public function setListData($listData:ListData):void {
            _index = $listData.index;
            _selected = $listData.selected;
        }
					
					
		override protected function configUI() : void {
			super.configUI();
			
			content.x = 3;
			content.y = 3;
			bm = GPool.getPool(Bitmap).object;
			content.addChild(bm);
			
			InteractiveObjectEx.setHitTestDisable(textField, true);
			InteractiveObjectEx.setHitTestDisable(content, true);
			
			constraints.removeAllElements();
		}
		
		
		override public function set data($v:Object):void {
			if(_data == $v)	return;
			delBind();
			super.data = $v;
			addBind();
		}
		
		
		public function destroy():void{
			delBind();
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
		
		
		override protected function draw():void {
			super.draw();
			
			bm.bitmapData = null;
			
			stage.dispatchEvent(_data ? tooltipEvt : new TooltipEvent(TooltipEvent.UNREGISTER_ELEMENT, true, false, this));
		}
		
		
		override public function toString() : String {
			return "com.minarto.controls.Slot";
		}
		
		
		protected function onImageLoadComplete($bd:BitmapData):void {
			if ($bd) {
				bm.bitmapData = $bd;
				bm.width = 64;
				bm.height = 64;
			}			
		}
	}
}
