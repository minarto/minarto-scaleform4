import flash.external.ExternalInterface;


class com.minarto.data.INI {
	public static function init($delegateObj):Void {
		_init();
		
		if ($delegateObj)	$delegateObj.setValue = set;
		else ExternalInterface.call("Binding", Binding);
		
		delete Binding.init;
	}
	
	
	private static function _init():Void {
		var valueDic = { }, bindingDic = { };
		
		
		set = function ($data:String) {
			var i:Number, a:Array = bindingDic[$key], item, arg:Array;

			valueDic[$key] = $value;
			
			for (i = 0, $key = a ? a.length : 0; i < $key; ++ i) {
				item = a[i];
				arg = item[3];
				arg[0] = $value;
				item[1].apply(item[2], arg);
			}
		}
		
		
		add = function ($section:String, $name:String, $handler:Function, $scope) {
			var d, v, a:Array = arguments.slice(3), item;
		
			arguments[3] = a;
			
			d = bindingDic[$section];
			if (!d)	bindingDic[$section] = d = { };
			a = d[$name];
			
			if (a) {
				for ($name in a) {
					item = a[$name];
					if (item[2] == $handler && item[3] == $scope) {
						a[$name] = arguments;
						return;
					}
				}
				a.push(arguments);
			}
			else d[$name] = a = [arguments];
			
			d = valueDic[$section];
			if (!d)	return;
			v = d[$name];
			if (v === undefined)	return;
			
			$handler.apply($scope, a);
		}
		
		
		del = function ($section:String, $name:String, $handler:Function, $scope) {
			var d, i;
			
			if($section){
				d = bindingDic[$section];
				if (!d)	return;
				d = d[$name];
				if (!d)	return;
				
				for (i in d) {
					item = d[i];
					if (item[1] == $handler && item[2] == $scope) {
						d.splice(i, 1);
						return;
					}
				}
			}
			else	bindingDic = {};
		}
		
		
		get = function($section:String, $name:String) {
			var d = valueDic[$section];
			return	d ? d[$name] : d;
		}
		
		
		delete _init;
	}
		
		
	public static function set($data:String):Void {
		_init();
		INI.set($data);
	}
	
	
	public static function add($section:String, $name:String, $handler:Function, $scope):Void {
		_init();
		add.apply(Binding, arguments);
	}
		
	
	public static function del($section:String, $name:String, $handler:Function, $scope):Void {
		_init();
		del($section, $name, $handler, $scope);
	}
		
		
	public static function get($section:String, $name:String) {
		_init();
		return	INI.get($section, $name);
	}
}