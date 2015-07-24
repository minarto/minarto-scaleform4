package com.minarto.controls
{
	import scaleform.clik.controls.DropdownMenu;
	
	
	public class DropdownMenuX extends DropdownMenu
	{
		override public function toString():String
		{
			return	"[com.minarto.controls.DropdownMenuX " + name + "]";
		}
		
		
		override public function get data():Object
		{
			return _data;
		}
		override public function set data(value:Object):void
		{
			_data = value;
		}
	}
}