import com.minarto.manager.LoadManager;
import gfx.controls.ListItemRenderer;
import gfx.events.EventTypes;
import gfx.utils.Delegate;


class com.minarto.manager.SlotManager {
	private static var fromSlot:ListItemRenderer, targetSlot:ListItemRenderer, dragSlot:MovieClip, mEvt:MovieClip;
	
	
	/**
	 * 
	 * @param	$slot
	 */
	public static function add($slot:ListItemRenderer):Void {
		for (var i in arguments) {
			$slot = arguments[i];
			
			$slot.trackAsMenu = true;
			$slot.addEventListener(EventTypes.PRESS, SlotManager, "hnPress");
			$slot.addEventListener("dragOver", SlotManager, "hnDragOver");
			$slot.addEventListener("dragOut", SlotManager, "hnDragOver");
		}
	}
	
	
	/**
	 * 
	 * @param	$slot
	 */
	public static function del($slot:ListItemRenderer):Void {
		for (var i in arguments) {
			$slot = arguments[i];
			$slot.removeAllEventListeners();
		}
	}
		
		
	private static function hnPress($e):Void {
		var data = $e.target.data, content:MovieClip;
		
		if (data) {
			fromSlot = $e.target;
			
			content = dragSlot["content"];
			content._visible = false;
			
			LoadManager.load(dragSlot, data.src, onComplete, SlotManager);
			
			mEvt.onEnterFrame = Delegate.create(SlotManager, onContentMove);
		}
	}
		
		
	private function hnDragOver($e):Void {
		targetSlot = $e.target;
	}
		
		
	private function hnDragOut($e):Void {
		targetSlot = null;
	}
	
	
	private static function onComplete():Void {
		//dragSlot._width = 64;
		//dragSlot._height = 64;
	}
	
	
	private static function onContentMove():Void {
		dragSlot._x = _root._xmouse;
		dragSlot._y = _root._ymouse;
	}
	
	
	private static function onMouseUp():Void {
		LoadManager.unLoad(dragSlot);

		delete	mEvt.onEnterFrame;
		
		Mouse.removeListener(SlotManager);
		
		if (targetSlot) {
			var d = targetSlot.data;
			targetSlot.setData(fromSlot.data);
			fromSlot.setData(d);
		}
		
		targetSlot = null;
		fromSlot = null;
	}
}