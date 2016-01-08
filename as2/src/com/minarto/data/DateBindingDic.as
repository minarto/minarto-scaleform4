import com.minarto.data.*;


class com.minarto.DateBindingDic
{
  static private var _dic = { };
	
	
	static public function get($interval:Number):DateBinding
	{
		if (!($interval > 0))	$interval = 0.1;
		return	_dic[$interval] || (_dic[$interval] = new DateBinding($interval));
	}
}
