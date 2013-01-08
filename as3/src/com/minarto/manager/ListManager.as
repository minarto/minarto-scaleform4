package com.minarto.manager {
	import com.minarto.data.ListBinding;
	import com.minarto.events.*;
	import com.minarto.utils.GPool;
	
	import de.polygonal.core.ObjectPool;
	
	import flash.display.*;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	
	import scaleform.clik.controls.CoreList;
	import scaleform.clik.core.*;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.*;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.gfx.*;
	
	
	public class ListManager extends EventDispatcher {
		protected static var _instance:ListManager;
		
		
		protected var dic:* = {}, dicListProperties:Dictionary = new Dictionary, 
						dragTarget:Bitmap = new Bitmap, dragIndex:int, dragListKey:String, dragData:*, _dragSize:int = 42, _dragPoint:int = - 21,
						clickEvt:SlotEvent = new SlotEvent(ListEvent.ITEM_CLICK), dropEvt:SlotEvent = new SlotEvent(DragEvent.DROP);
		
		
		public function ListManager($stage:Stage) {
			if(_instance)	throw new Error("don't create instance");
			
			$stage.addEventListener("listRegist", onRegist);
			$stage.addEventListener("listUnRegist", onUnRegist);
			
			if(ExternalInterface.available && Extensions.isScaleform)	ExternalInterface.call("ListManager", this);
			trace("ListManager init");
		}
		
		
		protected function onRegist($e:CustomEvent):void {
			var param:* = $e.param;
			var list:CoreList = param.list;
			ListBinding.regist(param.key, list);
			dicListProperties[list] = param;
			
			list.addEventListener(ListEvent.ITEM_PRESS, onItemPress);
			list.addEventListener(ListEvent.ITEM_CLICK, onItemClick);
		}
		
		
		protected function onUnRegist($e:CustomEvent):void {
			var param:* = $e.param;
			var list:CoreList = param.list;
			var key:String = param.key;
			if(list){
				list.removeEventListener(ListEvent.ITEM_PRESS, onItemPress);
				list.removeEventListener(ListEvent.ITEM_CLICK, onItemClick);
				ListBinding.unregist(key, list);
				
				delete	dic[key];
				delete	dicListProperties[list];
			}
			else{
				for(key in dic){
					list = dic[key];
					list.removeEventListener(ListEvent.ITEM_PRESS, onItemPress);
					list.removeEventListener(ListEvent.ITEM_CLICK, onItemClick);
					
					ListBinding.unregist(key, list);
				}
			}
			
			dic = {};
			dicListProperties = new Dictionary;
		}
		
		
		protected function onItemPress($e:ListEvent):void {
		}
		
		
		protected function onComplete($bd:BitmapData):void{
			dragTarget.bitmapData = $bd;
			
			dragTarget.width = _dragSize;
			dragTarget.height = _dragSize;
			
			var s:Stage = CLIK.stage;
			s.addEventListener(Event.ENTER_FRAME, onDrag);
			s.addEventListener(MouseEvent.MOUSE_UP, onDragEnd);
			
			dragTarget.visible = true;
		}
		
		
		private function onDrag($e:Event):void {
			var s:Stage = CLIK.stage;
			dragTarget.x = s.mouseX + _dragPoint;
			dragTarget.y = s.mouseY + _dragPoint;
		}
		
		
		private function onDragEnd($e:Event):void {
			dragTarget.visible = false;
			
			var s:Stage = CLIK.stage;
			s.removeEventListener(Event.ENTER_FRAME, onDrag);
			s.removeEventListener(MouseEvent.MOUSE_UP, onDragEnd);
			
			dropEvt.fromIndex = dragIndex;
			dropEvt.fromData = dragData;
			dropEvt.fromListKey = dragListKey;
			
			var t:IListItemRenderer = $e.target as IListItemRenderer;
			if (t) {
				var list:CoreList = t.owner as CoreList;
				dropEvt.data = t["data"];
				dropEvt.index = t.index;
				dropEvt.listKey = dicListProperties[list].key;
			}
			else {
				dropEvt.data = null;
				dropEvt.index = - 1;
				dropEvt.listKey = null;
			}
			
			dispatchEvent(dropEvt);
		}
		
		
		protected function onItemClick($e:ListEvent):void {
		}
	}
}