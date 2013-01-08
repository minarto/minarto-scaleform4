import gfx.events.EventDispatcher;


/**
 * ...
 * @author minarto
 */
class com.minarto.controls.Document extends MovieClip {
	public var	addEventListener:Function, 
				removeEventListener:Function,
				hasEventListener:Function,
				removeAllEventListeners:Function,
				cleanUpEvents:Function,
				dispatchEvent:Function;
	
	
	public function Document($main:MovieClip) {
		EventDispatcher.initialize(this);
		
		if ($main) {
			$main.__proto__ = this;
			this = Object($main);
			if (!Stage.visibleRect) {
				onLoad();
			}
		}
	}
}