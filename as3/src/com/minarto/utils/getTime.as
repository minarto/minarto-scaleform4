package com.minarto.utils
{
	/**
	 * @author minarto
	 */
	public function getTime($ms:Number=0):Date
	{
		var date:Date = new Date($ms);
		
		date.date = date.date - 1;
		date.hours = date.hours - 9;
		//trace("warnning!! getTime's 31 date is 0 or 31 date");
		
		return date;
	}
}
