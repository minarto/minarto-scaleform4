package com.minarto.controls
{
	import scaleform.clik.controls.DropdownMenu;
	
	
	public class LabelDropdownMenu extends DropdownMenuX
	{
		override public function toString():String
		{
			return "[fcm.controls.LabelDropdownMenu " + name + "]";
		}
		
		
		override public function get label():String
		{
			return _label;
		}
		override public function set label($v:String):void
		{
			if (_label == $v || !$v)	return;
			_label = $v;
			invalidateData();
		}
		
		
		override protected function updateLabel(item:Object):void
		{
			//super.updateLabel(item);
		}
	}
}