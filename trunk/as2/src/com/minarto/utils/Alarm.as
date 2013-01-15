import com.minarto.data.Binding;
import com.minarto.utils.*;

/*
 * use class after Binding.init
 */
class com.minarto.utils.Alarm {
	private static var _dic = {}, _date:Date = new Date();
		
		
	static public function getDate($h:Number, $m:Number, $s:Number):Date {
		_date.setHours(++ $h, ++ $m, ++ $s);
		return	_date;
	}
	
	
	static public function addAlarm($date:Date, $scope, $handler:String):Void {
		var i = $date.getTime();
		
		var a = _dic[i] || (_dic[i] = []);
		a.push( { scope:$scope, handler:$handler } );
		
		Binding.addBind("date", Alarm, "_onDate");
	}
	
	
	static public function addTimer($sec:Number, $scope, $handler:String):Void {
		$sec = Binding.getValue("date").getTime() + $sec * 1000;
		
		var a = _dic[$sec] || (_dic[$sec] = []);
		a.push( { scope:$scope, handler:$handler } );

		Binding.addBind("date", Alarm, "_onDate");
	}
	
	
	static public function addRepeat($delay:Number, $scope, $handler:String, $repeat:Number):Void {
		$delay = $delay * 1000;
		
		var s = Binding.getValue("date").getTime() + $delay;
		
		for (var i = 0; i < $repeat; ++ i) {
			var j = s + i * $delay;
			var a = _dic[j] || (_dic[j] = []);
			a.push( { scope:$scope, handler:$handler } );
		}
		
		Binding.addBind("date", Alarm, "_onDate");
	}
	
	
	static public function delAlarm($scope, $handler:String):Void {
		if ($scope && $handler) {
			for (var d in _dic) {
				var a = _dic[d];
				for (var i:Number = 0, c:Number = a.length; i < c; ++ i) {
					var o = a[i];
					if (o.scope == $scope && o.handler == $handler) {
						a.splice(i--, 1);
					}
				}
			}
		}
		else if ($scope) {
			for (d in _dic) {
				a = _dic[d];
				for (var i:Number = 0, c:Number = a.length; i < c; ++ i) {
					o = a[i];
					if (o.scope == $scope) {
						a.splice(i--, 1);
					}
				}
			}
		}
		else {
			_dic = { };
		}
	}
	
	
	static private function _onDate($date:Date):Void {
		var n = $date.getTime();
		
		for (var d in _dic) {
			if (Number(d) < n) {
				var a = _dic[d];
				for (var i in a) {
					var o = a[i];
					o.scope[o.handler]($date);
				}
				
				delete	_dic[d];
			}
		}
	}
}