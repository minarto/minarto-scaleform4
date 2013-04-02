import flash.external.ExternalInterface;
import com.minarto.data.*;
import gfx.events.EventDispatcher;


class com.minarto.data.Binding {
	private static var _valueDic = { }, _bindingDic = { };
	
	
	public static function init() {
		EventDispatcher.initialize(Binding);
		ExternalInterface.call("Binding", Binding);
		trace("Binding.init");
		delete Binding.init;
	}
		
		
	public static function set($key:String, $value) {
		if($key){
			_set($key, $value);
		}
		else{
			$value = undefined;
			for($key in _valueDic){
				_set($key, $value);
			}
		}
	}
	
	
	
	public static function action($e) {
		Binding["dispatchEvent"]($e);
	}
		
		
	private static function _set($key:String, $value) {
		var arg, p, h;
		
		for(p in $value)	_set($key + "." + p, $value[p]);
		
		if (_valueDic[$key] === $value) return;
		_valueDic[$key] = $value;
		
		h = _bindingDic[$key];
		for (p in h){
			arg = h[p];
			arg[1].call(arg[2], $value);
		}
	}
	
	
	public static function add($key:String, $handler:Function, $scope) {
		var h:Array, arg;
		
		if(!$key)	return;
		
		h = _bindingDic[$key];
		if (h) {
			for ($key in h) {
				arg = h[$key];
				if (arg[1] === $handler && arg[2] === $scope) {
					return;
				}
			}
			h.push(arguments);
		}
		else {
			h = [arguments];
			_bindingDic[$key] = h;
		}
	}
		
		
	public static function del($key:String, $handler:Function, $scope) {
		var h:Array, arg;
		
		if($key){
			h = _bindingDic[$key];
			for ($key in h) {
				arg = h[$key];
				if (arg[1] === $handler && arg[2] === $scope) {
					h.splice(+$key, 1);
					return;
				}
			}
		}
		else{
			_bindingDic = {};
		}
	}
		
		
	public static function get($key:String) {
		return	_valueDic[$key];
	}
}