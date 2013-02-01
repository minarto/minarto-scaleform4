package com.minarto.manager.list {
	import com.minarto.data.ListBinding;
	import com.minarto.events.SlotEvent;
	import com.minarto.manager.ImageManager;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.Dictionary;
	
	import scaleform.clik.controls.CoreList;
	import scaleform.clik.core.CLIK;
	import scaleform.clik.events.*;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.gfx.*;
	
	
	public class ListActionManager {
		protected var listDic:Dictionary = new Dictionary(true), 
			dragTarget:DisplayObject, dragIndex:int, dragList:CoreList, dragListKey:String, dragData:*, _dragSize:int, _dragPoint:int,
			clickEvt:SlotEvent = new SlotEvent(ListEvent.ITEM_CLICK), dropEvt:SlotEvent = new SlotEvent(DragEvent.DROP);
		
		
		public function addList($key:String, $list:CoreList, $param:*):void{
			delList($list);
			
			listDic[$list] = {key:$key, list:$list, param:$param};
			
			if($param){
				if($param.useEnable)	$list.addEventListener(ListEvent.ITEM_CLICK, onItemClick);
				if($param.moveEnable){
					switch(ListActionBridge.itemMoveActionType){
						case  ItemMoveActionType.DOWN_AND_DOWN :
							$list.addEventListener(ListEvent.ITEM_CLICK, dragStart);
							break;
						default :
							$list.addEventListener(ListEvent.ITEM_PRESS, dragStart);
					}
				}
			}
		}
		
		
		public function delList($list:CoreList=null):void{
			if($list){
				$list.removeEventListener(ListEvent.ITEM_CLICK, dragStart);
				$list.removeEventListener(ListEvent.ITEM_PRESS, dragStart);
				$list.removeEventListener(ListEvent.ITEM_CLICK, onItemClick);
				
				delete	listDic[$list];
			}
			else{
				for(var p:* in listDic){
					var o:* = listDic[p];
					$list = o.list;
					
					$list.removeEventListener(ListEvent.ITEM_CLICK, dragStart);
					$list.removeEventListener(ListEvent.ITEM_PRESS, dragStart);
					$list.removeEventListener(ListEvent.ITEM_CLICK, onItemClick);
				}
				
				listDic = new Dictionary(true);
			}
		}
		
		
		protected function dragStart($e:ListEvent):void{
			if ($e.buttonIdx != ListActionBridge.itemMoveButton)	return;

			dragData = $e.itemData;
			
			var key:String = ListActionBridge.keyMoveEnable;
			
			if (dragData && ((key && dragData[key]) || !key)) {
				dragList = $e.target as CoreList;
				var o:* = listDic[dragList];
				
				dragListKey = o.listKey;
				dragIndex = $e.index;
			}
			else{
				dragData = null;
				dragList = null;
				dragIndex = - 1;
				dragListKey = null;
				return;
			}
			
			key = ListActionBridge.keyURL;
			ImageManager.load(dragData[key], onImgLoadComplete);
			
			var s:Stage = CLIK.stage;
			s.addEventListener(Event.ENTER_FRAME, onDrag);
			s.addEventListener(MouseEvent.MOUSE_UP, onDragEnd);
			
			dragTarget.visible = true;
		}
		
		
		protected function onImgLoadComplete($bd:BitmapData):void{
		}
		
		
		protected function onDrag($e:Event):void {
			var s:Stage = CLIK.stage;
			dragTarget.x = s.mouseX + _dragPoint;
			dragTarget.y = s.mouseY + _dragPoint;
		}
		
		
		protected function onDragEnd($e:Event):void {
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
				var param:* = listDic[list];
				if(param){
					dropEvt.data = t["data"];
					dropEvt.index = t.index;
					dropEvt.listKey = param.key;
				}
			}
			else {
				dropEvt.data = null;
				dropEvt.index = - 1;
				dropEvt.listKey = null;
			}
			
			ListBinding.action(dropEvt);
		}
		
		
		protected function onItemClick($e:ListEvent):void {
			if ($e.buttonIdx != ListActionBridge.itemUseMouseButton)	return;
			
			var d:* = $e.itemData;
			
			var key:String = ListActionBridge.keyUseEnable;
			
			if (d && ((key && d[key]) || (!key))) {
				var list:CoreList = $e.target as CoreList;
				var o:* = listDic[list];
				
				clickEvt.data = d;
				clickEvt.index = $e.index;
				clickEvt.listKey = o.key;
				
				ListBinding.action(clickEvt);
			}
		}
	}
}