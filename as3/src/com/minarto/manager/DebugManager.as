package com.minarto.manager {
	import flash.external.ExternalInterface;
	
	import scaleform.gfx.Extensions;
	
	
	public class DebugManager {
		public static function error($type:String, $message:String):void{
			if(ExternalInterface.available && Extensions.isScaleform)	ExternalInterface.call("error", $type, $message);
			trace("error", $type, $message);
		}
	}
}