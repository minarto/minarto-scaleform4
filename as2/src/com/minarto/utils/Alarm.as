import com.minarto.data.Binding;

/*
 * use class after Binding.init
 */
class com.minarto.utils.Alarm {
	private static var alarmDic:Array = [];
	
	
	public static function add($duration:Number, $handler:Function, $scope):Void {
		if (!Binding.get("AlarmInterval")) Binding.dateInit("AlarmInterval", 100);

		add = function($duration, $handler, $scope) {
			var s:Number, f:Function, arg:Array;
			
			s = Binding.get("AlarmInterval").getTime() + $duration * 1000;	//	start time
			arg = arguments.slice(3, arguments.length);
			
			f = function($date) {
				if ($date.getTime() > s) {
					$handler.apply($scope, arg);
					Binding.del("AlarmInterval", f);
					del($handler, $scope);
				}
			}
			Binding.add("AlarmInterval", f);
			
			alarmDic.push({ handler:$handler, scope:$scope, func:f });
		};
		
		add($duration, $handler, $scope);
	}
	
	
	public static function addRepeat($interval:Number, $count:Number, $handler:Function, $scope):Void {
		if (!Binding.get("AlarmInterval")) Binding.dateInit("AlarmInterval", 100);

		addRepeat = function($interval, $count, $handler, $scope) {
			var s:Number, f:Function, arg:Array;
		
			$interval = $interval * 1000;
			s = Binding.get("AlarmInterval").getTime() + $interval;	//	start time
			arg = arguments.slice(4, arguments.length);
			
			f = function($date) {
				if ($count) {
					if ($date.getTime() > s) {
						-- $count;
						$handler.apply($scope, arg);
						s += $interval;
					}
				}
				else {
					Binding.del("AlarmInterval", f);
					del($handler, $scope);
				}
			}
			Binding.add("AlarmInterval", f);
			
			alarmDic.push({ handler:$handler, scope:$scope, func:f });
		};
		
		addRepeat($interval, $count, $handler, $scope);
	}
	
	
	public static function del($handler:Function, $scope):Void {
		if (!Binding.get("AlarmInterval")) Binding.dateInit("AlarmInterval", 100);
		
		del = function($handler, $scope) {
			var i, o;
		
			if ($handler) {
				for (i in alarmDic) {
					o = alarmDic[i];
					if ($handler === o.handler && $scope == o.scope) {
						delete	alarmDic[i];
						Binding.del("AlarmInterval", o.func);
					}
				}
			}
			else	alarmDic = [];
		}
		
		del($handler, $scope);
	}
}