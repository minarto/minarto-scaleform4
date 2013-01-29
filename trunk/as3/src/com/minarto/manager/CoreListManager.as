package com.minarto.manager {
	import com.minarto.data.ListBinding;
	import com.minarto.events.*;
	import com.minarto.manager.list.ItemMoveActionType;
	import com.minarto.manager.list.ListParam;
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
	
	
	public class CoreListManager {
		public var itemMoveActionType:String = ItemMoveActionType.DRAG_AND_DROP;	//	아이템 이동 방식
		public var itemMoveButton:uint = MouseEventEx.LEFT_BUTTON;	//	아이템 이동시 사용하는 마우스 버튼
		public var useMouseButton:uint = MouseEventEx.RIGHT_BUTTON;	//	아이템 사용시 사용하는 마우스 버튼
		
		
		protected var listDic:* = {}, paramDic:* = {}, 
			keyURL:String, keyUseEnable:String, keyMoveEnable:String,
			
			dragTarget:DisplayObject, dragIndex:int, dragListKey:String, dragData:*, _dragSize:int, _dragPoint:int,
			clickEvt:SlotEvent = new SlotEvent(ListEvent.ITEM_CLICK), dropEvt:SlotEvent = new SlotEvent(DragEvent.DROP);
		
		
		public function CoreListManager() {
			trace("CoreListManager");
		}
		
		
		public function addParam($paramKey:String, $param:ListParam):void{
			paramDic[$paramKey] = $param;
		}
		
		
		public function addList($listKey:String, $list:CoreList, $paramKey:String):void{
			delList($list);
			
			var dic:* = listDic[$paramKey] || (listDic[$paramKey] = {});
			dic[$listKey] = $list;
			
			ListBinding.addListBind($listKey, $list);
			
			var param:ListParam = paramDic[$paramKey];
			if(param){
				if(param.useEnable)	$list.addEventListener(ListEvent.ITEM_CLICK, onItemClick);
				if(param.moveEnable){
					switch(itemMoveActionType){
						case  ItemMoveActionType.DOWN_AND_DOWN :
							$list.addEventListener(ListEvent.ITEM_CLICK, dragStart);
							break;
						default :
							$list.addEventListener(ListEvent.ITEM_PRESS, dragStart);
					}
				}
			}
		}
		
		
		public function delList($list:CoreList):void{
			if($list){
				$list.removeEventListener(ListEvent.ITEM_CLICK, dragStart);
				$list.removeEventListener(ListEvent.ITEM_PRESS, dragStart);
				$list.removeEventListener(ListEvent.ITEM_CLICK, onItemClick);
				
				for(var paramKey:String in listDic){
					var dic:* = listDic[paramKey];
					for(var listKey:String in dic){
						if(dic[listKey] == $list){
							ListBinding.delListBind(listKey, $list);
							delete	dic[listKey];
							return;
						}
					}
				}				
			}
			else{
				for(paramKey in listDic){
					dic = listDic[paramKey];
					for(listKey in dic){
						$list = dic[listKey];
						$list.removeEventListener(ListEvent.ITEM_CLICK, dragStart);
						$list.removeEventListener(ListEvent.ITEM_PRESS, dragStart);
						$list.removeEventListener(ListEvent.ITEM_CLICK, onItemClick);
					}
				}
				
				ListBinding.delListBind(null, $list);
				
				listDic = {};
			}
		}
		
		
		protected function onItemPress($e:ListEvent):void {
			dragData = $e.itemData;
			
			if ($e.buttonIdx == itemMoveButton && dragData && dragData[keyMoveEnable]) {
				
				var list:CoreList = $e.target as CoreList;
				var param:* = listDic[list];
				dragListKey = param.key;
				dragIndex = $e.index;
			}
			else{
				dragData = null;
			}
		}
		
		
		protected function dragStart($e:ListEvent):void{
			dragData = $e.itemData;
			
			if ($e.buttonIdx == itemMoveButton && dragData && dragData[keyMoveEnable]) {
				var list:CoreList = $e.target as CoreList;
				var param:* = listDic[list];
				dragListKey = param.key;
				dragIndex = $e.index;
			}
			else{
				dragData = null;
			}
			
			ImageManager.load(dragData[keyURL], onImgLoadComplete);
			
			var s:Stage = CLIK.stage;
			s.addEventListener(Event.ENTER_FRAME, onDrag);
			switch(itemMoveActionType){
				case  ItemMoveActionType.DOWN_AND_DOWN :
					s.addEventListener(MouseEvent.MOUSE_UP, onDragEnd);
					break;
				default :
					s.addEventListener(MouseEvent.CLICK, onDragEnd);
			}
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
			var d:* = $e.itemData;
			if ($e.buttonIdx == useMouseButton && d && d[keyUseEnable]) {
				var list:CoreList = $e.target as CoreList;
				var param:* = listDic[list];
				
				clickEvt.data = d;
				clickEvt.index = $e.index;
				clickEvt.listKey = param.key;
				
				ListBinding.action(clickEvt);
			}
		}
	}
}