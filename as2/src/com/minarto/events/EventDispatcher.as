class com.minarto.events.EventDispatcher {
	public static function init($target):Void {
		var events = { };
		
		$target.dispatchEvent = function($e):Void {
			var a:Array, i:Number, l:Number, arg:Array, arg2:Array;
			
			if (!$e)	return;

			$e.target || ($e.target = this);
			
			a = events[$e.type];
			for (i = 0, l = a ? a.length : 0; i < l; ++ i) {
				arg = a[i];
				arg2 = arg[3];
				arg2[0] = $e;
				arg[1].apply(arg[2], arg2);
			}
		};
		
		$target.hasEventListener = function() {
			return	events[arguments[0]];
		};
		
		
		$target.addEventListener = function($type:String, $handler:Function, $scope):Void {
			var a:Array, i, arg:Array;
			
			arguments[3] = arguments.slice(2, arguments.length);
			
			a = events[$type];
			for (i in a) {
				arg = a[i];
				if ($handler == arg[1] && $scope == arg[2]) {
					a[i] = arguments;
					return;
				}
			}
			if (!a)	events[$type] = a = [];
			
			a.push(arguments);
		};
		
		
		$target.removeEventListener = function($type:String, $handler:Function, $scope):Void {
			var a:Array, i, arg:Array;
			
			if ($type) {
				if ($handler) {
					a = events[$type];
					for (i in a) {
						arg = a[i];
						if ($handler == arg[1] && $scope == arg[2]) {
							a.splice(i, 1);
							if (!a.length)	delete	events[$type];
							return;
						}
					}
				}
				else	delete	events[$type];
			}
			else	events = { };
		};
	}
	
	
	public function EventDispatcher() {
		init(this);
	}
	
	
	public function hasEventListener($type:String):Boolean {
		return	$type;
	}
	
	
	public function addEventListener($type:String, $handler:Function, $scope):Void {
	}
	
	
	public function removeEventListener($type:String, $handler:Function, $scope):Void {
	}
	
	
	public function dispatchEvent($e):Void {
	}
}