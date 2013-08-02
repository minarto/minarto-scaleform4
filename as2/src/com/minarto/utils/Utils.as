import flash.external.ExternalInterface;
import flash.geom.Rectangle;


class com.minarto.utils.Utils {
	public static var rectangle:Rectangle = new Rectangle;
	
	
	public static var point = { x:0, y:0 };
	
	
	public static function error($type:String, $msg:String):Void {
		ExternalInterface.call("error", $type, $msg);
		trace("error - " + $type + " : " + $msg);
	}
	
	
	public static function addComma($n:Number, $cipher:Number):String {
		var r:String, s:String, c:Number, i:Number, t:String;
		
		if (isNaN($n))	return	s;
		
		s = "" + $n;
		
		$cipher || ($cipher = 3);

		c = s.length;
		i = s.indexOf(".", 0) - $cipher;
		if (i < - ($cipher - 1)) i = c - $cipher;
		
		while (i > 0) {
			t = s.substring(0, i);
			if(t === "-")	return	s;
			else	s = t + "," + s.substring(i, c ++);
			
			i -= $cipher;
		}
		
		return	s;
	}
	
	
	public static function locale($msg:String):String {
		var dic = { };
		
		locale = function($msg) {
			var r:String = dic[$msg];
			if(!r){
				r = "" + ExternalInterface.call("locale", $msg);
				if(r)	dic[$msg] = r;
				else	error("locale", $msg);
			}
			
			return	r;
		}
		
		return	locale($msg);
	}
	
	
	public static function cal($n0:Number, $operator:String, $n1:Number):Number {
		var s0:String, s1:String, n0:Number, n1:Number, p:Number, r:Number;
		
		if(isNaN($n0) || isNaN($n1) || ($operator != "+" && $operator != "-" && $operator != "*" && $operator != "/"))	return	r;
		else if(!$n0 || !$n1) {
			s0 = "" + $n0;
			n0 = s0.indexOf(".", 0);
			if(n0 < 0)	n0 = s0.length;
			n0 = s0.length - n0;
			
			s1 = "" + $n1;
			n1 = s1.indexOf(".", 0);
			if(n1 < 0)	n1 = s1.length;
			n1 = s1.length - n1;
			
			p = Math.max(n0, n1);
			n1 = Math.pow(10, p);
			n0 = (+s0.split(".").join("")) * n1;
			n1 = (+s1.split(".").join("")) * n1;
			
			switch($operator){
				case "+" :	return	(n0 + n1) / Math.pow(10, p);
				case "-" :	return	(n0 - n1) / Math.pow(10, p);
				case "*" :	return	(n0 * n1) / Math.pow(10, p << 1);
				case "/" :	return	n0 / n1;
			}
		}
		else if(!$n0){
			switch($operator){
				case "+" :	return	n1;
				case "-" :	return	- n1;
				default :	return	0;
			}
		}
		else {	//	$n1 === 0
			switch($operator){
				case "*" :	return	0;
				case "/" :	return	$n0 < 0 ? - Infinity : Infinity;
				default :	return	n0;
			}
		}
		
		return	r;
	}
	
	
	public static function loop($start:Number, $limit:Number, $handler:Function, $scope):Void {
		var l:Number;
		
		l = $limit - $start;
		if (l) {
			switch(l % 8) {
				case 7 :	$handler.call($scope, $start ++);
				case 6 :	$handler.call($scope, $start ++);
				case 5 :	$handler.call($scope, $start ++);
				case 4 :	$handler.call($scope, $start ++);
				case 3 :	$handler.call($scope, $start ++);
				case 2 :	$handler.call($scope, $start ++);
				case 1 :	$handler.call($scope, $start ++);
			}
		}
		
		while ($start < $limit) {
			$handler.call($scope, $start ++);
			$handler.call($scope, $start ++);
			$handler.call($scope, $start ++);
			$handler.call($scope, $start ++);
			
			$handler.call($scope, $start ++);
			$handler.call($scope, $start ++);
			$handler.call($scope, $start ++);
			$handler.call($scope, $start ++);
		}
	}
}