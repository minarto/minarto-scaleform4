class com.minarto.utils.Math2 {
	public static function addComma($n:String, $cipher:Number):String {
		if (!$n)	return	$n;

		$cipher = $cipher || 3;
		
		var c:Number = $n.length;
		var i:Number = $n.indexOf(".", 0) - $cipher;
		if (i < - ($cipher - 1)) i = c - $cipher;
		
		while (i > 0) {
			var t:String = $n.substring(0, i);
			if(t == "-"){
				return	$n;
			}
			else{
				$n = t + "," + $n.substring(i, c ++);
			}
			
			i -= $cipher;
		}
		
		return	$n;
	}
}