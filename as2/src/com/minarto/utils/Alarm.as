import com.minarto.data.Binding;

/*
 * use class after Binding.init
 */
class com.minarto.utils.Alarm {
	private static function _init() {
		var alarmDic:Array = [];
		
		Binding.dateInit("AlarmInterval", 0.1);
		
		has = function($handler:Function, $scope) {
			var i, o;
			
			for (i in alarmDic) {
				o = alarmDic[i];
				if ($handler === o.handler && $scope == o.scope) return	o;
			}
			return	0;
		};
		
		
		add = function($duration:Number, $handler:Function, $scope) {
			var s:Number, arg:Array, f:Function, o;
			
			s = Binding.get("AlarmInterval").getTime() + $duration * 1000;	//	start time
			arg = arguments.slice(3, arguments.length);
			
			f = function() {
				if (arguments[0].getTime() >= s) {
					$handler.apply($scope, arg);
					del($handler, $scope);
				}
			}
			
			for ($duration in alarmDic) {
				o = alarmDic[$duration];
				if ($handler === o.handler && $scope == o.scope) {
					Binding.del("AlarmInterval", o.func);
					o.func = f;
					Binding.add("AlarmInterval", f);
					return;
				}
			}
			
			o = { handler:$handler, scope:$scope, func:f };
			alarmDic.push(o);
			Binding.add("AlarmInterval", f);
		};
		
		
		addRepeat = function($interval:Number, $count:Number, $handler:Function, $scope) {
			var s:Number, arg:Array, f:Function, i, o;
			
			$interval = $interval * 1000;
			s = Binding.get("AlarmInterval").getTime() + $interval;	//	start time
			arg = arguments.slice(4, arguments.length);
			
			f = function() {
				if (arguments[0].getTime() >= s) {
					if ($count --) {
						s += $interval;
						$handler.apply($scope, arg);
						if(!$count)	del($handler, $scope);
					}
				}
			}
			
			for (i in alarmDic) {
				o = alarmDic[i];
				if ($handler === o.handler && $scope == o.scope) {
					Binding.del("AlarmInterval", o.func);
					o.func = f;
					Binding.add("AlarmInterval", f);
					return;
				}
			}
			
			o = { handler:$handler, scope:$scope, func:f };
			alarmDic.push(o);
			Binding.add("AlarmInterval", f);
		};
		
		del = function($handler:Function, $scope) {
			var i, o;
		
			if ($handler) {
				for (i in alarmDic) {
					o = alarmDic[i];
					if ($handler === o.handler && $scope == o.scope) {
						Binding.del("AlarmInterval", o.func);
						delete	alarmDic[i];
					}
				}
			}
			else	alarmDic = [];
		};
		
		delete	_init;
	}
	
	
	public static function has($handler:Function, $scope):Boolean {
		_init();
		return	has.apply(Alarm, arguments);
	}
	
	
	public static function add($duration:Number, $handler:Function, $scope):Void {
		_init();
		add.apply(Alarm, arguments);
	}
	
	
	public static function addRepeat($interval:Number, $count:Number, $handler:Function, $scope):Void {
		_init();
		addRepeat.apply(Alarm, arguments);
	}
	
	
	public static function del($handler:Function, $scope):Void {
		_init();
		del.apply(Alarm, arguments);
	}
}