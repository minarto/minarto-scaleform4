import gfx.events.EventDispatcher;


/**
 * ...
 * @author minarto
 */
class com.minarto.controls.widget.Widget extends MovieClip {
	public var	addEventListener:Function, removeEventListener:Function, hasEventListener:Function, removeAllEventListeners:Function, cleanUpEvents:Function, dispatchEvent:Function,
				background:MovieClip;
				
				
	private var _widgetID;
	
	
	public function get widgetID() {
		return _widgetID;
	}
	public function set widgetID($v):Void {
		if ($v == _widgetID)	return;
		_widgetID = $v;
		if (_global.CLIK_loadCallback) _global.CLIK_loadCallback(widgetID, targetPath(this), this);
	}
	
	
	public function Widget($main) {
		EventDispatcher.initialize(this);
		
		$main.__proto__ = this.__proto__;
		this = $main;
		onLoad = configUI;
	}
	
	
	private function configUI() {
		delete this.__proto__.configUI;
		delete onLoad;
		
		if (_widgetID && _global.CLIK_loadCallback) _global.CLIK_loadCallback(_widgetID, targetPath(this), this);
	}
		
		
	public function open(){
		_visible = true;
	}
	
	
	public function close(){
		_visible = false;
	}
	
	
	public function destroy() {
		removeAllEventListeners();
	}
}