package com.minarto.data
{
	public class DateBindingDic
	{
		static private const _dic:* = {};
		
		
		static public function get($delay:Number=0.1):DateBinding
		{
			return	_dic[$delay] || (_dic[$delay] = new DateBinding($delay));
		}
	}
}