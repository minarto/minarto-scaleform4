package com.minarto.manager {
	import flash.external.ExternalInterface;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class TranslateManager {
		private static var	_dic:* = { };
		
		
		public static function translate($msg:String):String{
			var r:String = _dic[$msg];
			if(!r){
				r = ExternalInterface.call("translate", $msg);
				
				if(r){
					_dic[$msg] = r;
				}
				else{
					DebugManager.error("translate", $msg);
				}				
				
			}
			return	r;	
		}
	}
}