package com.minarto.data
{
	public class DBindDic
	{
		static private const _dic:* = {};
		
		
		static public function get($interval:Number=0.1):DBind
		{
			var db:DBind = _dic[$interval];
			
			if(!db)
			{
				_dic[$interval] = db = new DBind;
				db.init($interval);
			}
			
			return	db;
		}
	}
}