import com.minarto.controls.*;
import com.minarto.data.Binding;
import gfx.events.*;


/**
 * ...
 * @author minarto
 */
class com.minarto.controls.BaseMain extends MovieClip {
	public var	addEventListener:Function, removeEventListener:Function, hasEventListener:Function, removeAllEventListeners:Function, cleanUpEvents:Function, dispatchEvent:Function,
				onResize:Function;
	
	
	public function BaseMain($main:MovieClip) {
		_global.gfxExtensions = true;
		
		EventDispatcher.initialize(this);
		
		if ($main) {
			$main.__proto__ = this.__proto__;
			this = Object($main);
		}
		
		onLoad = configUI;
	}
	
	
	private function configUI() {
		var e;
		
		delete this.__proto__.configUI;
		delete onLoad;
		
		Stage.scaleMode = "noScale";
		Stage.align = "TL";
		Stage.addListener(this);
		
		e = { type:"resize", target:this };
		onResize = function() {
			dispatchEvent(e);
		}
		
		if (_global.CLIK_loadCallback) _global.CLIK_loadCallback("main", targetPath(this), this);
		Binding.init();
	}
}