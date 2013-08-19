import flash.external.ExternalInterface;


class com.minarto.data.Binding {
	public static function init($delegateObj):Void {
		if(_init)	_init();
		
		if ($delegateObj)	$delegateObj.setValue = Binding.set;
		else ExternalInterface.call("Binding", Binding);
		
		delete init;
	}
	
	
	public static function dateInit($key:String, $interval:Number):Void {
		var keys = { };
		
		if(_init)	_init();
		
		dateInit = function($key:String, $interval:Number) {
			clearInterval(keys[$key]);
			
			if ($interval) {
				Binding.set($key, new Date);
				
				keys[$key] = setInterval(function() {
					Binding.set($key, new Date);
				}, $interval * 1000);
			}
		};
		
		dateInit($key, $interval);
	}
	
	
	private static function _init():Void {
		var valueDic = { }, bindingDic = { };
		
		
		Binding.set = function ($key, $value) {
			var i:Number, a:Array = bindingDic[$key], item, arg:Array;

			valueDic[$key] = $value;
			
			for (i = 0, $key = a ? a.length : 0; i < $key; ++ i) {
				item = a[i];
				arg = item[3];
				arg[0] = $value;
				item[1].apply(item[2], arg);
			}
		}
		
		
		add = function ($key:String, $handler:Function, $scope) {
			var a:Array = arguments.slice(2), item;
		
			a[0] = valueDic[$key];
			arguments[3] = a;
			
			a = bindingDic[$key];
			
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
		
		
		addNPlay = function ($key:String, $handler:Function, $scope) {
			var a:Array = arguments.slice(2), item;
			
			a[0] = valueDic[$key];
			arguments[3] = a;
			
			a = bindingDic[$key];
			
			if (a) {
				for ($key in a) {
					item = a[$key];
					if (item[1] == $handler && item[2] == $scope) {
						a[$key] = arguments;
						$handler.apply($scope, arguments[3]);
						return;
					}
				}
				a.push(arguments);
			}
			else bindingDic[$key] = a = [arguments];

			$handler.apply($scope, arguments[3]);
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
		
		
		Binding.get = function($key:String) {
			return	valueDic[$key];
		}
		
		
		delete _init;
	}
		
		
	public static function set($key:String, $value):Void {
		_init();
		Binding.set($key, $value);
	}
	
	
	public static function add($key:String, $handler:Function, $scope):Void {
		_init();
		add.apply(Binding, arguments);
	}
	
	
	public static function addNPlay($key:String, $handler:Function, $scope):Void {
		_init();
		addNPlay.apply(Binding, arguments);
	}
		
	
	public static function del($key:String, $handler:Function, $scope):Void {
		_init();
		del($key, $handler, $scope);
	}
		
		
	public static function get($key:String) {
		_init();
		return	Binding.get($key);
	}
}