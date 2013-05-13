class com.minarto.events.EventDispatcher {
	public static function init($target):Void {
		$target.__events__ = { };
		_global.ASSetPropFlags($target, "__events__", 1);
		$target.dispatchEvent = EventDispatcher.prototype.dispatchEvent;
		$target.hasEventListener = EventDispatcher.prototype.hasEventListener;
		$target.addEventListener = EventDispatcher.prototype.addEventListener;
		$target.removeEventListener = EventDispatcher.prototype.removeEventListener;
	}
	
	
	private var __events__ = { };
	
	
	public function hasEventListener($type:String):Boolean {
		return	__events__[$type];
	}
	
	
	public function addEventListener($type:String, $handler:Function, $scope):Void {
		var listeners:Array, i, arg;
		
		if (!$type || !$handler)	return;
		
		listeners = __events__[$type];
		for (i in listeners) {
			arg = listeners[i];
			if ($handler === arg[1] && $scope === arg[2]) {
				return;
			}
		}
		if (!listeners) {
			listeners = [];
			__events__[$type] = listeners;
		}
		
		listeners.push(arguments);
	}
	
	
	public function removeEventListener($type:String, $handler:Function, $scope):Void {
		var listeners:Array, i, arg;
		
		if ($type) {
			if ($handler) {
				listeners = __events__[$type];
				for (i in listeners) {
					arg = listeners[i];
					if ($handler === arg[1] && $scope === arg[2]) {
						listeners.splice(i, 1);
						if (!listeners.length) {
							delete	__events__[$type];
						}
						return;
					}
				}
			}
			else {
				delete	__events__[$type];
			}
		}
		else {
			__events__ = { };
		}
	}
	
	
	public function dispatchEvent($e):Void {
		var listeners:Array, i:Number, c:Number, arg;
		
		if (!$e)	return;
		
		$e.target || ($e.target = this);
		
		listeners = __events__[$e.type];
		c = listeners ? listeners.length : 0;
		for (i = 0; i < c; ++ i) {
			arg = listeners[i];
			arg[1].call(arg[2], $e);
		}
	}
}