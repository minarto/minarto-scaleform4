import com.minarto.manager.ImageManager;
import com.minarto.manager.list.*;
import gfx.controls.CoreList;
import gfx.events.EventTypes;


class com.minarto.manager.list.ListActionManager {
	private var listDic = {}, 
			dragTarget:MovieClip, dragIndex:Number, dragList:CoreList, dragListKey:String, dragData, _dragSize:Number, _dragPoint:Number,
			clickEvt = {type:EventTypes.ITEM_CLICK}, dropEvt = {type:EventTypes.DROP};
		
		
	public function addList($key:String, $list:CoreList, $param):void{
		delList($list);
		
		listDic[$key] = {key:$key, list:$list, param:$param};
		
		if($param){
			if($param.useEnable)	$list.addEventListener(EventTypes.ITEM_CLICK, this, "onItemClick");
			if($param.moveEnable){
				switch(ListActionBridge.itemMoveActionType){
					case  ItemMoveActionType.DOWN_AND_DOWN :
						$list.addEventListener(EventTypes.ITEM_CLICK, this, "dragStart");
						break;
					default :
						$list.addEventListener(EventTypes.ITEM_PRESS, "dragStart");
				}
			}
		}
	}
	
	
	public function delList($list:CoreList):Void{
		if($list){
			$list.removeEventListener(EventTypes.ITEM_CLICK, this, "dragStart");
			$list.removeEventListener(EventTypes.ITEM_PRESS, this, "dragStart");
			$list.removeEventListener(EventTypes.ITEM_CLICK, this, "onItemClick");
			
			for (var key in listDic) {
				var o = listDic[key];
				if (o.list == $list) {
					delete	listDic[key];
					return;
				}
			}
		}
		else{
			for(key in listDic){
				var o = listDic[key];
				$list = o.list;
				
				$list.removeEventListener(EventTypes.ITEM_CLICK, this, "dragStart");
				$list.removeEventListener(EventTypes.ITEM_PRESS, this, "dragStart");
				$list.removeEventListener(EventTypes.ITEM_CLICK, this, "onItemClick");
			}
			
			listDic = {};
		}
	}
	
	
	private function dragStart($e):Void{
		if ($e.buttonIdx != ListActionBridge.itemMoveButton)	return;

		dragData = $e.item;
		
		var key:String = ListActionBridge.keyMoveEnable;
		
		if (dragData && ((key && dragData[key]) || !key)) {
			dragList = $e.target as CoreList;
			for (key in listDic) {
				var o = listDic[key];
				if (o.list == dragList) {
					dragListKey = key;
					break;
				}
			}
			
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
		//ImageManager.load(dragData[key], onImgLoadComplete);
		
		var s:Stage = CLIK.stage;
		_root.addEventListener(Event.ENTER_FRAME, onDrag);
		_root.addEventListener(MouseEvent.MOUSE_UP, onDragEnd);
		
		dragTarget.visible = true;
	}
	
	
	private function onImgLoadComplete($bd:BitmapData):Void{
	}
	
	
	private function onDrag($e):Void {
		var s:Stage = CLIK.stage;
		dragTarget.x = s.mouseX + _dragPoint;
		dragTarget.y = s.mouseY + _dragPoint;
	}
	
	
	private function onDragEnd($e):Void {
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
	
	
	private function onItemClick($e):Void {
		if ($e.buttonIdx != ListActionBridge.itemUseMouseButton)	return;
		
		var d:* = $e.item;
		
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