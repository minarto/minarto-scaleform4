package com.minarto.utils {
	import com.minarto.data.Binding;
	
	import de.polygonal.core.ObjectPool;
	
	import flash.utils.Dictionary;
	
    public class Alarm {
		private static var _dic:* = {};
		
		
		static public function addAlarm($date:Date, $handler:Function):void {
			var i:Number = $date.getTime();
			
			var dic:Dictionary = _dic[i] || (_dic[i] = new Dictionary(true));
			dic[$handler] =  $handler;
			
			Binding.addBind("date", _onDate);
		}
		
		
		static public function delAlarm($handler:Function):void {
			if(Boolean($handler)){
				for(var d:* in _dic){
					var dic:Dictionary = _dic[d];
					for(var f:* in dic){
						if(dic[f] == $handler){
							delete	dic[f];
						}
					}
				}
			}
			else{
				_dic = {};
			}
		}
		
		
		static public function addTimer($sec:Number, $handler:Function):void {
			var d:Date = Binding.getValue("date");
			$sec = d.getTime() + $sec * 1000;
			
			var dic:Dictionary = _dic[$sec] || (_dic[$sec] = new Dictionary(true));
			dic[$handler] =  $handler;
			
			Binding.addBind("date", _onDate);
		}
		
		
		static public function addRepeat($delay:Number, $handler:Function, $repeat:uint):void {
			$delay = $delay * 1000;
			
			var d:Date = Binding.getValue("date");
			
			var s:Number = d.getTime() + $delay;
			
			for (var i:uint = 0; i < $repeat; ++ i) {
				var j:Number = s + i * $delay;
				var dic:Dictionary = _dic[j] || (_dic[j] = new Dictionary(true));
				dic[$handler] =  $handler;
			}
			
			Binding.addBind("date", Alarm, "_onDate");
		}
		
		
		static private function _onDate($date:Date):void {
			var n:Number = $date.getTime();
			
			for (var d:* in _dic) {
				if (Number(d) < n) {
					var a:Array = _dic[d];
					for (var i:* in a) {
						a[i]($date);
					}
					
					delete	_dic[d];
				}
			}
		}
	}
}