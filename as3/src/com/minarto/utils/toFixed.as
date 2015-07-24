package com.minarto.utils
{
	/**
	 * @author minarto
	 */
	public function toFixed($n:Number, $fractionDigits:uint=2):String
	{
		var s:String = "" + $n, i:int = s.indexOf(".");
		
		if(isNaN($n))
		{
			return	null;
		}
		else 
		{
			if(i < 0)	i = s.length;
			i = $fractionDigits - i;
			
			while(i --)
			{
				s = "0" + s;
			}
			return	s;
		}
	}
}
