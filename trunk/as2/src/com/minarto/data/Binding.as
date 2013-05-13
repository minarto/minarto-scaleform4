import flash.external.ExternalInterface;
import com.minarto.events.EventDispatcher;


class com.minarto.data.Binding {
	public static function init($delegateObj):Void {
		_init();
		
		if ($delegateObj) {
			$delegateObj.setValue = set;
			$delegateObj.setArg = setArg;
		}
		else ExternalInterface.call("Binding", Binding);
		
		trace("Binding.init");
		
		delete Binding.init;
	}
	
	
	public static function dateInit($key:String, $interval:Number):Void {
		var keys = { };
		
		_init();
		
		dateInit = function($$key, $$interval) {
			clearInterval(keys[$$key]);
			
			if ($$interval) {
				Binding.set($$key, new Date);
				
				keys[$$key] = setInterval(function() {
					Binding.set($$key, new Date);
				}, $$interval * 1000);
			}
		};
		
		dateInit.apply(Binding, arguments);
	}
	
	
	private static function _init():Void {
		var valueDic = { }, bindingDic = { }, _set:Function;
		
		
		_set = function ($key, $value) {
			var p, a:Array, arg, arg2;
		
			for(p in $value)	arguments.calee($key + "." + p, $value[p]);
			
			if (valueDic[$key] === $value) return;
			valueDic[$key] = $value;
			
			a = bindingDic[$key];
			for (p = 0, $key = a ? a.length : 0; p < $key; ++ p) {
				arg = a[p];
				arg2 = arg[3];
				arg2[0] = $value;
				arg[1].apply(arg[2], arg2);
			}
		}
		
		
		set = function ($key:String, $value) {
			if($key)	_set($key, $value);
			else	for($key in valueDic)	_set($key, $key);
		}
		
		setArg = function ($key) {
			var v:Array, a:Array, i:Number, arg, arg2:Array;
			
			if ($key) {
				v = arguments.slice(1, arguments.length);
				valueDic[$key] = v;
				
				a = bindingDic[$key];
				for (i = 0, $key = a ? a.length : 0; i < $key; ++ i) {
					arg = a[i];
					arg2 = arg[3];
					arg2 = v.concat(arg2.slice(1, arg2.length));
					arg[1].apply(arg[2], arg2);
				}
			}
			else	Binding.set();
		}
		
		
		has = function ($key:String, $handler:Function, $scope) {
			var a:Array, arg;
			
			a = bindingDic[$key];
			for ($key in a) {
				arg = a[$key];
				if (arg[1] === $handler && arg[2] == $scope) return	arg;
			}
			return	0;
		}
		
		
		add = function ($key:String, $handler:Function, $scope) {
			var a:Array, arg;
		
			arguments[3] = arguments.slice(2, arguments.length);
			
			a = bindingDic[$key];
			if (a) {
				for ($key in a) {
					arg = a[$key];
					if (arg[1] === $handler && arg[2] == $scope) {
						a[$key] = arguments;
						return;
					}
				}
				a.push(arguments);
			}
			else bindingDic[$key] = a = [arguments];
		}
		
		
		del = function ($key:String, $handler:Function, $scope) {
			var a:Array, arg, i;
		
			if($key){
				a = bindingDic[$key];
				for (i in a) {
					arg = a[i];
					if (arg[1] === $handler && arg[2] == $scope) {
						a.splice(i, 1);
						if(!a.length)	delete	bindingDic[$key];
						return;
					}
				}
			}
			else	bindingDic = {};
		}
		
		
		get = function($key:String) {
			return	valueDic[$key];
		}
		
		
		delete _init;
	}
		
		
	public static function setArg($key:String):Void {
		_init();
		setArg.apply(Binding, arguments);
	}
		
		
	public static function set($key:String, $value):Void {
		_init();
		set.apply(Binding, arguments);
	}
	
	
	public static function has($key:String, $handler:Function, $scope):Boolean {
		_init();
		return	has.apply(Binding, arguments);
	}
	
	
	public static function add($key:String, $handler:Function, $scope):Void {
		_init();
		add.apply(Binding, arguments);
	}
		
	
	public static function del($key:String, $handler:Function, $scope):Void {
		_init();
		del.apply(Binding, arguments);
	}
		
		
	public static function get($key:String) {
		_init();
		return	get.apply(Binding, arguments);
	}
}