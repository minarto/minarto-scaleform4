import com.minarto.controls.*;
import com.minarto.data.Binding;
import gfx.events.*;


/**
 * ...
 * @author minarto
 */
class com.minarto.controls.BaseMain extends MovieClip {
	public var	addEventListener:Function, 
				removeEventListener:Function,
				hasEventListener:Function,
				removeAllEventListeners:Function,
				cleanUpEvents:Function,
				dispatchEvent:Function;
				
				
	private var onResize:Function;
	
	
	public function BaseMain($main:MovieClip) {
		_global.gfxExtensions = true;
		
		EventDispatcher.initialize(this);
		
		if ($main) {
			$main.__proto__ = this;
			this = Object($main);
		}
	}
	
	
	private function onLoad():Void {
		var e = { type:"reSize", target:this };
		onResize = function():Void {
			dispatchEvent(e);
		}
		Stage.addListener(this);
		
		Binding.init();
		
		configUI();
		if (_global.CLIK_loadCallback) { _global.CLIK_loadCallback("main", targetPath(this), this); }
	}
	
	
	private function configUI():Void {
		Stage.scaleMode = "noScale";
		Stage.align = "TL";
	}
}