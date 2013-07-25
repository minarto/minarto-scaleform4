import com.minarto.data.Binding;
import com.minarto.manager.widget.WidgetManager;
import com.minarto.ui.KeyBinding;
import gfx.events.EventDispatcher;


/**
 * ...
 * @author minarto
 */
class com.minarto.controls.BaseMain extends MovieClip {
	public var	addEventListener:Function, removeEventListener:Function, hasEventListener:Function, removeAllEventListeners:Function, cleanUpEvents:Function, dispatchEvent:Function;
	
	
	/**
	 * stage resource
	 */
	public var container:MovieClip;
	
	
	/**
	 * Binding.set 위임
	 * 
	 * @param	$key
	 * @param	$value
	 */
	public function setValue($key:String, $value):Void{};
	
	
	/**
	 * KeyBinding.set 위임
	 * 
	 * @param	$bindingKey
	 * @param	$keyCode
	 * @param	$combi
	 */
	public function setKey($bindingKey:String, $keyCode, $combi:Number):Void {};
	
	
	public function BaseMain($main) {
		_global.gfxExtensions = 1;
		
		$main.__proto__ = this.__proto__;
		this = $main;
		EventDispatcher.initialize(this);
		
		Binding.init(this);
		KeyBinding.init(this);
	}
	
	
	private function onLoad() {
		Stage.scaleMode = "noScale";
		Stage.align = "TL";
		
		Mouse.addListener(this);
		WidgetManager.init(container);
		
		delete onLoad;
	}
	
	
	private function onMouseDown ():Void {
		dispatchEvent({type:"mouseDown", controllerIdx:arguments[0], button:arguments[2]});
	}
	
	
	private function onMouseUp ():Void {
		dispatchEvent({type:"mouseUp", controllerIdx:arguments[0], button:arguments[2]});
	}
}