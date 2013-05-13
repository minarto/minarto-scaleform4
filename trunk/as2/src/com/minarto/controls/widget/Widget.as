import gfx.events.EventDispatcher;


/**
 * ...
 * @author minarto
 */
class com.minarto.controls.widget.Widget extends MovieClip {
	public var	addEventListener:Function, removeEventListener:Function, hasEventListener:Function, removeAllEventListeners:Function, cleanUpEvents:Function, dispatchEvent:Function,
				background:MovieClip, widgetID:String;
	
	
	public function Widget($main:MovieClip) {
		EventDispatcher.initialize(this);
		
		$main.__proto__ = this.__proto__;
		this = Object($main);
		onLoad = configUI;
	}
	
	
	private function configUI() {
		delete this.__proto__.configUI;
		delete onLoad;
		
		if (_global.CLIK_loadCallback) _global.CLIK_loadCallback(widgetID, targetPath(this), this);
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
		
		
	private function setTitle($title:String):Void {
		if (background)	background.title = $title;
	}
}