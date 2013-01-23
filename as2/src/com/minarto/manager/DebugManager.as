import com.minarto.manager.*;
import flash.external.ExternalInterface;
import gfx.events.EventDispatcher;


class com.minarto.manager.DebugManager extends EventDispatcher {
	private static var _instance:DebugManager = new DebugManager, _evt = {type:"error"};
	
	
	public static function getInstance():DebugManager{
		return	_instance;
	}
	
	
	public function DebugManager(){
		if(_instance)	throw	new Error("don't create instance");
		_instance = this;
	}
		
		
	public static function error($type:String, $message:String):Void {
		_evt.type = $type;
		_evt.message = $message;
		_instance.dispatchEvent(_evt);
		
		if(ExternalInterface.available)	ExternalInterface.call("error", $type, $message);
		trace("error - " + $type + " : " + $message);
	}
}