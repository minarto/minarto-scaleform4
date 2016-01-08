import com.minarto.data.*;


class com.minarto.DateBindingDic
{
  	static private var _dic = { };
	
	
	static public function get($delay:Number):DateBinding
	{
		if (!($delay > 0))	$delay = 0.1;
		return	_dic[$delay] || (_dic[$delay] = new DateBinding($delay));
	}
}
