package com.minarto.data
{
	public class DateBindDic
	{
		static private const _dic:* = {};
		
		
		static public function get($interval:Number=0.1):DateBind
		{
			var db:DateBind = _dic[$interval];
			
			if(!db)
			{
				_dic[$interval] = db = new DateBind;
				db.init($interval);
			}
			
			return	db;
		}
	}
}