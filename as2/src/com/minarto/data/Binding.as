import flash.external.ExternalInterface;
import com.minarto.events.EventDispatcher;


class com.minarto.data.Binding {
	private static var _valueDic = { }, _bindingDic = { };
	
	
	public static function init($delegateObj):Void {
		if ($delegateObj) {
			$delegateObj.setValue = set;
			action = function() {
				$delegateObj.dispatchEvent.call($delegateObj, arguments[0]);
			};
		}
		else {
			EventDispatcher.initialize(Binding);
			action = function() {
				Binding["dispatchEvent"].call(Binding, arguments[0]);
			};
			ExternalInterface.call("Binding", Binding);
		}
		
		trace("Binding.init");
		
		delete Binding.init;
	}
	
	
	public static function dateInit($key:String, $interval:Number):Void {
		var keys;
		
		keys = { };
		
		dateInit = function($key, $interval) {
			var f:Function;
			
			clearInterval(keys[$key]);
			
			if ($interval) {
				f = function() {
					set($key, new Date);
				};
				
				
				keys[$key] = setInterval(f, $interval);
				
				f();
			}
		};
		
		dateInit($key, $interval);
	}
	
	
	public static function action($e) {}
		
		
	public static function set($key:String, $value):Void {
		if($key)	_set($key, $value);
		else{
			$value = undefined;
			for($key in _valueDic)	_set($key, $value);
		}
	}
		
		
	private static function _set($key:String, $value) {
		var arg, p, h:Array, i:Number;
		
		for(p in $value)	_set($key + "." + p, $value[p]);
		
		if (_valueDic[$key] === $value) return;
		_valueDic[$key] = $value;
		
		h = _bindingDic[$key];
		for (i = 0, p = h ? h.length : 0; i < p; ++ i) {
			arg = h[i];
			arg[1].call(arg[2], $value);
		}
	}
	
	
	public static function has($key:String, $handler:Function, $scope):Boolean {
		var h:Array, arg, i;
		
		h = _bindingDic[$key];
		for (i in h) {
			arg = h[i];
			if (arg[1] === $handler && arg[2] == $scope) return	true;
		}
		return	false;
	}
	
	
	public static function add($key:String, $handler:Function, $scope):Void {
		var h:Array, arg, i;
		
		h = _bindingDic[$key];
		if (h) {
			for (i in h) {
				arg = h[i];
				if (arg[1] === $handler && arg[2] == $scope) return;
			}
			h.push(arguments);
		}
		else _bindingDic[$key] = h = [arguments];
	}
		
	
	public static function del($key:String, $handler:Function, $scope):Void {
		var h:Array, arg, i;
		
		if($key){
			h = _bindingDic[$key];
			for (i in h) {
				arg = h[i];
				if (arg[1] === $handler && arg[2] == $scope) {
					h.splice(i, 1);
					if(!h.length)	delete	_bindingDic[$key];
					return;
				}
			}
		}
		else	_bindingDic = {};
	}
		
		
	public static function get($key:String) {
		return	_valueDic[$key];
	}
}