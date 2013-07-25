import com.minarto.data.Binding;

/*
 * use class after Binding.init
 */
class com.minarto.utils.Alarm {
	var alarmDic = {}, alarmID:Number = 0;
		
		Binding.dateInit("AlarmInterval", 0.1);		
		
		add = function($duration:Number, $handler:Function, $scope) {
			var id:Number, s:Number, arg:Array, f:Function;
			
			id = alarmID ++;
			s = Binding.get("AlarmInterval").getTime() + $duration * 1000;	//	start time
			arg = arguments.slice(3);
			
			f = function() {
				if (arguments[0].getTime() >= s) {
					$handler.apply($scope, arg);
					del(id);
				}
			}
			
			alarmDic[id] = f;
			Binding.add("AlarmInterval", f);
			
			return	id;
		};
		
		
		addRepeat = function($interval:Number, $count:Number, $updateHandler:Function, $updateScope, $completeHandler:Function, $completeScope) {
			var id:Number, s:Number, arg:Array, f:Function;
			
			id = alarmID ++;
			$interval = $interval * 1000;
			s = Binding.get("AlarmInterval").getTime() + $interval;	//	start time
			arg = arguments.slice(6);
			
			f = function() {
				if (arguments[0].getTime() >= s) {
					if ($count --) {
						s += $interval;
						if($updateHandler)	$updateHandler.apply($updateScope, arg);
						if (!$count) {
							if($completeHandler)	$completeHandler.apply($completeScope, arg);
							del(id);
						}
					}
				}
			}
			
			alarmDic[id] = f;
			Binding.add("AlarmInterval", f);
			
			return	id;
		};
		
		del = function($id:Number) {
			if (!isNaN($id)) {
				var f = alarmDic[$id];
				if (f) {
					Binding.del("AlarmInterval", f);
					delete	alarmDic[$id];
				}
			}			
			else {
				alarmID = 0;
				alarmDic = {};
			}
		};
		
		delete	_init;
	}
	
	
	public static function add($duration:Number, $handler:Function, $scope):Number {
		_init();
		return	add.apply(Alarm, arguments);
	}
	
	
	public static function addRepeat($interval:Number, $count:Number, $updateHandler:Function, $updateScope, $completeHandler:Function, $completeScope):Number {
		_init();
		return	addRepeat.apply(Alarm, arguments);
	}
	
	
	public static function del($id:Number):Void {
		_init();
		del.call(Alarm, $id);
	}
}