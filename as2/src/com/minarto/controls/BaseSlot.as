import com.minarto.manager.LoadManager;
import com.minarto.utils.Util;
import gfx.controls.ListItemRenderer;
import gfx.events.EventTypes;


class com.minarto.controls.BaseSlot extends ListItemRenderer {
	public var content:MovieClip;
	
	
	private function configUI():Void {
		super.configUI();
		
		trackAsMenu = true;
		
		textField.hitTestDisable = true;
		content.hitTestDisable = true;
			
		constraints.removeElement(textField);
		
		
	}
	
	
	public function setData($d):Void {
		data = $d;
		if ($d) {
			LoadManager.load(content, $d.src, onImageLoadComplete, this);
			addEventListener(EventTypes.PRESS, this, "hnPress");
		}
		else {
			removeEventListener(EventTypes.PRESS, this, "hnPress");
		}
	}
		
		
	private function onImageLoadComplete($content:MovieClip):Void {
		$content._width = 64;
		$content._height = 64;
	}
		
		
	private function hnPress($e):Void {
		var p = Util.point;
		p.x = content._xmouse;
		p.y = content._ymouse;
		content.localToGlobal(p);
		
		content.onEnterFrame = onContentMove;
		Mouse.addListener(this);
		
		content.topmostLevel = true;
	}
	
	
	private static function onContentMove():Void {
		var p = Util.point;
		
		this._x = _root._xmouse - p.x;
		this._y = _root._xmouse - p.y;
	}
	
	
	private function onMouseUp():Void {
		delete	content.onEnterFrame;
		
		content._x = 0;
		content._y = 0;
		content.topmostLevel = false;
		
		Mouse.removeListener(this);
	}
}