package com.minarto.interfaces
{
	import scaleform.clik.interfaces.IUIComponent;
	
	public interface IContent extends IUIComponent
	{
		function setData(...$datas):void;
		//function setValue($key:String, ...$datas):void;
	}
}