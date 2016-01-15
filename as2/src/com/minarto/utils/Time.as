import com.minarto.utils.*;


class com.minarto.utils.Time
{
	/**
	 * ms > hour
	 * @param	$ms
	 * @return
	 */
	static public function getHours($ms:Number):Number
	{
		return Math.floor($ms / 3600000);
	}
	
	
	/**
	 * ms > min
	 * @param	$ms
	 * @return
	 */
	static public function getMinutes($ms:Number):Number
	{
		return Math.floor($ms % 3600000 / 60000);
	}
	
	
	/**
	 * ms > sec
	 * @param	$ms
	 * @return
	 */
	static public function getSeconds($ms:Number):Number
	{
		return Math.floor($ms % 60000 * 0.001);
	}
}
