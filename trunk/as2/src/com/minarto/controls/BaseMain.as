import com.minarto.data.Binding;
import com.minarto.ui.KeyBinding;
import gfx.events.EventDispatcher;


/**
 * ...
 * @author minarto
 */
class com.minarto.controls.BaseMain extends MovieClip {
	public var	addEventListener:Function, removeEventListener:Function, hasEventListener:Function, removeAllEventListeners:Function, cleanUpEvents:Function, dispatchEvent:Function;
	
	
	/**
	 * Binding.set 위임
	 * 
	 * @param	$key
	 * @param	$value
	 */
	public function setValue($key:String, $value):Void{};
	
	
	/**
	 * Binding.setArg 위임
	 * 
	 * @param	$key
	 */
	public function setArg($key:String):Void { };
	
	
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
		delete onLoad;
		
		Stage.scaleMode = "noScale";
		Stage.align = "TL";
		
		if (_global.CLIK_loadCallback) _global.CLIK_loadCallback("main", targetPath(this), this);
	}
}