package com.minarto.debug {
	import flash.external.ExternalInterface;
	
	/**
	 * @author minarto
	 */
	public class Debug {
		static public function init():void{
			ExternalInterface.call("Debug", Debug);
		}
		
		
		static public function log($msg:String):void{
			ExternalInterface.call("Debug.log", $msg);
			trace("Debug.log - " + $msg);
		}
		
		
		static public function error($type:String, $msg:String):void{
			ExternalInterface.call("Debug.error", $type, $msg);
			trace("Debug.error - " + $type + " : " + $msg);
		}
	}
}