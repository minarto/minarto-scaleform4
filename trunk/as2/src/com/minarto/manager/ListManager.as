import com.minarto.manager.*;
import flash.external.ExternalInterface;
import gfx.events.*;

class com.minarto.manager.ListManager extends EventDispatcher {
	private static var _instance:ListManager;
		
		
	private var dic = {}, dicListProperties = {}, 
					dragTarget:MovieClip = new Bitmap, dragIndex:Number, dragListKey:String, dragData, _dragSize:Number = 42, _dragPoint:Number = - 21,
					clickEvt = {type:EventTypes.ITEM_CLICK}, dropEvt = {type:EventTypes.DROP};
						
						
	public function ListManager($root:MovieClip) {
		if(_instance)	throw new Error("don't create instance");
		
		clickEvt.target = this;
		dropEvt.target = this;
		
		EventDispatcher.initialize($root);
		$root.addEventListener("listRegist", "onRegist", this);
		$root.addEventListener("listUnRegist", "onUnRegist", this);
		
		if(ExternalInterface.available)	ExternalInterface.call("ListManager", this);
		trace("ListManager init");
	}
		
		
	private function onRegist($e):Void {
		var list:CoreList = $e.list;
		ListBinding.regist($e.key, list);
		dicListProperties[list] = $e;
		
		list.addEventListener(EventTypes.ITEM_PRESS, onItemPress);
		list.addEventListener(EventTypes.ITEM_CLICK, onItemClick);
	}
		
		
	private function onUnRegist($e):Void {
		var list:CoreList = $e.list;
		var key:String = $e.key;
		if(list){
			list.removeEventListener(EventTypes.ITEM_PRESS, onItemPress);
			list.removeEventListener(EventTypes.ITEM_CLICK, onItemClick);
			ListBinding.unregist(key, list);
			
			delete	dic[key];
			delete	dicListProperties[list];
		}
		else{
			for(key in dic){
				list = dic[key];
				list.removeEventListener(EventTypes.ITEM_PRESS, onItemPress);
				list.removeEventListener(EventTypes.ITEM_CLICK, onItemClick);
				
				ListBinding.unregist(key, list);
			}
		}
		
		dic = {};
		dicListProperties = {};
	}
		
		
	private function onItemPress($e:ListEvent):Void {
	}
	
	private function onComplete($bd:BitmapData):Void{
		dragTarget.bitmapData = $bd;
		
		dragTarget.width = _dragSize;
		dragTarget.height = _dragSize;
		
		var s:Stage = CLIK.stage;
		s.addEventListener(Event.ENTER_FRAME, onDrag);
		s.addEventListener(MouseEvent.MOUSE_UP, onDragEnd);
		
		dragTarget.visible = true;
	}
	
	
	private function onDrag($e:Event):Void {
		var s:Stage = CLIK.stage;
		dragTarget.x = s.mouseX + _dragPoint;
		dragTarget.y = s.mouseY + _dragPoint;
	}
	
	
	private function onDragEnd($e:Event):Void {
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
	
	
	private function onItemClick($e:ListEvent):Void {
	}
}