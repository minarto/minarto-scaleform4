import com.minarto.controls.widget.*;
import gfx.events.EventDispatcher;


/**
 * ...
 * @author minarto
 */
class com.minarto.controls.widget.Widget extends MovieClip {
	public var	addEventListener:Function, 
				removeEventListener:Function,
				hasEventListener:Function,
				removeAllEventListeners:Function,
				cleanUpEvents:Function,
				dispatchEvent:Function,
				
				background:MovieClip;
				
				
	private var widgetID:String;
	
	
	public function Widget($main:MovieClip) {
		EventDispatcher.initialize(this);
		
		if ($main) {
			$main.__proto__ = this;
			this = Object($main);
		}
	}
	
	
	private function onLoad():Void {
		configUI();
		if (_global.CLIK_loadCallback) { _global.CLIK_loadCallback(widgetID, targetPath(this), this); }
	}
	
	
	private function configUI():Void {
	}
		
		
	private function setTitle($s:String):Void {
		if (background)	background.title = $s;
	}
		
		
	public function open():Void{
		_visible = true;
	}
	
	
	public function close():Void{
		_visible = false;
	}
	
	
	public function destroy():Void{
	}
	
	
	public function toString() : String {
		return "com.minarto.controls.widget.Widget";
	}
}