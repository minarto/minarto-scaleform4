import com.minarto.manager.*;
import flash.external.ExternalInterface;
import gfx.core.UIComponent;
import gfx.events.EventDispatcher;


class com.minarto.manager.MainInit {
	public static function init($root:MovieClip):Void {
		$root.__proto__ = EventDispatcher.prototype;
		
		Stage.align = "noScale";
		Stage.align = "TL";
		
		var e = { type:"reSize", target:$root };
		e.onResize = function():Void {
			$root.dispatchEvent(e);
		}
		
		Stage.addListener(e);
		
		if (_global.CLIK_loadCallback) { _global.CLIK_loadCallback("main", targetPath($root), $root); }
	}
}