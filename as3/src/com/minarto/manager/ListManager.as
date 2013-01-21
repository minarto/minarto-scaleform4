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
		protected var listDic:Dictionary = new Dictionary(true), 
			dragType:String = "drag&drop", moveButton:uint = 0, useMouseButton:uint = 1,
			
			keyURL:String, keyUseEnable:String, keyMoveEnable:String,
			
			dragTarget:DisplayObject, dragIndex:int, dragListKey:String, dragData:*, _dragSize:int, _dragPoint:int,
			clickEvt:SlotEvent = new SlotEvent(ListEvent.ITEM_CLICK), dropEvt:SlotEvent = new SlotEvent(DragEvent.DROP);
		
		
		public function ListManager() {
			trace("ListManager");
		}
		
		
		public function setDragType($type:String="drag&drop"):void{
			dragType = $type;
		}
		
		
		public function setMouseButton($move:uint = MouseEventEx.LEFT_BUTTON, $use:uint=MouseEventEx.RIGHT_BUTTON):void{
			moveButton = $move;
			useMouseButton = $use;
		}
		
		
		public function setDataKey($keyURL:String, $keyUseEnable:String, $keyMoveEnable:String):void{
			keyURL = $keyURL;
			keyUseEnable = $keyUseEnable;
			keyMoveEnable = $keyMoveEnable;
		}
		
		
		public function addList($list:CoreList, $param:*):void{
			if($param){
				if($param[keyMoveEnable])	$list.addEventListener(ListEvent.ITEM_PRESS, onItemPress);
				if($param[keyUseEnable])	$list.addEventListener(ListEvent.ITEM_CLICK, onItemClick);
			}
			else{
				$list.removeEventListener(ListEvent.ITEM_PRESS, onItemPress);
				$list.removeEventListener(ListEvent.ITEM_CLICK, onItemClick);
			}
			
			listDic[$list] = $param;
			ListBinding.addListBind($param.key, $list, $param);
		}
		
		
		public function delList($list:CoreList):void{
			if($list){
				$list.removeEventListener(ListEvent.ITEM_PRESS, onItemPress);
				$list.removeEventListener(ListEvent.ITEM_CLICK, onItemClick);
				
				$list.dataProvider = null;
				$list.invalidate();
				
				delete	listDic[$list];
			}
			else{
				for(var p:* in listDic){
					$list = listDic[p];
					$list.removeEventListener(ListEvent.ITEM_PRESS, onItemPress);
					$list.removeEventListener(ListEvent.ITEM_CLICK, onItemClick);
				}
				
				listDic = new Dictionary(true);
			}
			
			//ListBinding.getInstance().delListBind($key, $list);
		}
		
		
		protected function onItemPress($e:ListEvent):void {
			dragData = $e.itemData;
			
			if ($e.buttonIdx == moveButton && dragData && dragData[keyMoveEnable]) {
				
				var list:CoreList = $e.target as CoreList;
				var param:* = listDic[list];
				dragListKey = param.key;
				dragIndex = $e.index;
			}
			else{
				dragData = null;
			}
		}
		
		
		protected function dragStart():void{
			ImageManager.load(dragData[keyURL], onImgLoadComplete);
			
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