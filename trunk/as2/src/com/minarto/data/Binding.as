import flash.external.ExternalInterface;


class com.minarto.data.Binding {
	public static function init($delegateObj):Void {
		_init();
		
		if ($delegateObj)	$delegateObj.setValue = set;
		else ExternalInterface.call("Binding", Binding);
		
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
		
		dateInit($key, $interval);
	}
	
	
	private static function _init():Void {
		var valueDic = { }, bindingDic = { };
		
		
		set = function ($key, $value) {
			var i:Number, a:Array, item, arg:Array;
			
			if (valueDic[$key] == $value)	return;
			valueDic[$key] = $value;
			
			for (i = 0, a = bindingDic[$key], $key = a ? a.length : 0; i < $key; ++ i) {
				item = a[i];
				arg = item[3];
				arg[0] = $value;
				item[1].apply(item[2], arg);
			}
		}
		
		
		has = function ($key:String, $handler:Function, $scope) {
			var a:Array = bindingDic[$key], item;
			
			for ($key in a) {
				item = a[$key];
				if (item[1] == $handler && item[2] == $scope) return	1;
			}
			return	0;
		}
		
		
		add = function ($key:String, $handler:Function, $scope) {
			var a:Array = bindingDic[$key], arg:Array, item;
		
			arguments[3] = arg = arguments.slice(2, arguments.length);
			arg[0] = get($key);
			arguments.length = 4;
			
			if (a) {
				for ($key in a) {
					item = a[$key];
					if (item[1] == $handler && item[2] == $scope) {
						a[$key] = arguments;
						return;
					}
				}
				a.push(arguments);
			}
			else bindingDic[$key] = a = [arguments];
		}
		
		
		del = function ($key:String, $handler:Function, $scope) {
			var a:Array, i, item;
		
			if($key){
				a = bindingDic[$key];
				for (i in a) {
					item = a[i];
					if (item[1] == $handler && item[2] == $scope) {
						a.splice(i, 1);
						if(!a.length)	delete	bindingDic[$key];
						return;
					}
				}
			}
			else	bindingDic = {};
		}
		
		
		get = function() {
			return	valueDic[arguments[0]];
		}
		
		
		delete _init;
	}
		
		
	public static function set($key:String, $value):Void {
		_init();
		set($key, $value);
	}
	
	
	public static function has($key:String, $handler:Function, $scope):Boolean {
		_init();
		return	has($key, $handler, $scope);
	}
	
	
	public static function add($key:String, $handler:Function, $scope):Void {
		_init();
		add.apply(Binding, arguments);
	}
		
	
	public static function del($key:String, $handler:Function, $scope):Void {
		_init();
		del($key, $handler, $scope);
	}
		
		
	public static function get($key:String) {
		_init();
		return	get($key);
	}
}