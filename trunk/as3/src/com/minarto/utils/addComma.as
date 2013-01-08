package com.minarto.utils {
	public function addComma($n:String, $cipher:uint = 3):String {
		if (!$n)	return	$n;

		var c:uint = $n.length;
		var i:int = $n.indexOf(".", 0) - $cipher;
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