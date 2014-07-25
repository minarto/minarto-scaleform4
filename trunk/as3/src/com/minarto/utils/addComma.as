package com.minarto.utils {
	/**
	 * @author minarto
	 */
	public function addComma($n:Number, $cipher:uint=3):String {
		var s:String, c:uint, i:int, t:String;
		
		if (isNaN($n))	return	s;
		
		s = "" + $n;
		
		c = s.length;
		i = s.indexOf(".", 0) - $cipher;
		if (i < - ($cipher - 1)) i = c - $cipher;
		
		while (i > 0) {
			t = s.substring(0, i);
			if(t === "-")	return	s;
			else	s = t + "," + s.substring(i, c ++);
			
			i -= $cipher;
		}
		
		return s;
	}
}
