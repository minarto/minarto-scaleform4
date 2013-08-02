class com.minarto.manager.EventManager {
	private static function _init() {
		var dic = { };
		
		add = function($type:String, $handler:Function, $scope) {
			var a:Array = dic[$type], i, item:Array;
			
			arguments[3] = arguments.slice(2);
			
			if (a) {
				for (i in a) {
					item = a[i];
					if (item[1] == $handler && item[2] == $scope) {
						a[i] = arguments;
						return;
					}
				}
				
				a.push(arguments);
			}
			else	dic[$type] = a = [arguments];
		}
		
		
		del = function($type:String, $handler:Function, $scope) {
			var a:Array, i:Number, item:Array;
			
			if ($type) {
				a = dic[$type];
				i = a.length;
				
				if ($handler) {
					while (i --) {
						item = a[i];
						if (item[1] == $handler && item[2] == $scope) {
							a.splice(i, 1);
							if (!a.length)	delete	dic[$type];
							return;
						}
					}
				}
				else if($scope){
					while (i --) {
						item = a[i];
						if (item[2] == $scope)	a.splice(i, 1);
					}
					if (!a.length)	delete	dic[$type];
				}
				else	delete	dic[$type];
			}
			else	dic = { };
		}
		
		
		call = function($e) {
			var a:Array = dic[$type], i:Number, l:Number, item:Array, arg:Array;
			
			for (i = 0, l = a ? a.length : 0; i < l; ++i) {
				item = a[i];
				arg = item[3];
				arg[0] = $e;
				item[1].apply(item[2], arg);
			}
		}
	}
	
	
	public static function init():Void {
		_init();
		delete EventManager.init;
	}
		
		
	public static function add($type:String, $handler:Function, $scope):Void {
		_init();
		add.apply(EventManager, arguments);
	}
		
		
	public static function del($type:String, $handler:Function, $scope):Void {
		_init();
		del($type, $handler, $scope);
	}
		
		
	public static function call($e):Void {
		_init();
		call($e);
	}
}