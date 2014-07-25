package com.minarto.debug {
	import flash.external.ExternalInterface;
	
	/**
	 * @author minarto
	 */
	public class Debug {
		static public function INIT():void{
			ExternalInterface.call("Debug", Debug);
		}
		
		
		static public function LOG($msg:String):void{
			ExternalInterface.call("Debug.log", $msg);
			trace("Debug.log - " + $msg);
		}
	}
}