import com.minarto.utils.*;


class com.minarto.utils.NumberX
{
	/**
	 * 숫자에 자릿수를 붙여줌. 기본값 3자리
	 * @param	$n
	 * @param	$cipher
	 * @return
	 */
	static public function addComma($n:Number, $cipher:Number):String
	{
		var s:String, c:Number, i:Number, t:String;
		
		if (isNaN($n))	return	s;
		
		s = "" + $n;
		$cipher = $cipher || 3;
		
		c = s.length;
		i = s.indexOf(".", 0) - $cipher;
		if (i < - ($cipher - 1)) i = c - $cipher;
		
		while (i > 0)
		{
			t = s.substring(0, i);
			if(t === "-")	return	s;
			else	s = t + "," + s.substring(i, c ++);
			
			i -= $cipher;
		}
		
		return s;
	}
	
	
	/**
	 * 숫자를 고정 소수점 표기법으로 표현한 문자열을 반환. as3 의 Number.toFixed 와 동일
	 * @param	$n	변환할 숫자
	 * @param	$fractionDigits 자릿수
	 * @return
	 */
	static public function toFixed($n:Number, $fractionDigits:Number):String
	{
		var s:String, a:Array;
		
		if (isNaN($n))
		{
			return	"NaN";
		}
		else
		{
			s = "" + $n;
			a = s.split(".")
			s = a[1];
			if (s)
			{
				if (s.length > 1)
				{
					a[1] = s.substr(0, $fractionDigits);
				}
				else
				{
					while (-- $fractionDigits)
					{
						s += "0";
					}
					a[1] = s;
				}
			}
			else
			{
				s = "";
				
				while ($fractionDigits --)
				{
					s += "0";
				}
				a[1] = s;
			}
			
			return	a.join(".");
		}
	}
}
