package com.minarto.manager {
	import com.minarto.events.CustomEvent;
	
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	
	import scaleform.gfx.Extensions;
	
	
	public class DebugManager extends EventDispatcher {
		private static var _instance:DebugManager = new DebugManager, _evt:CustomEvent = new CustomEvent("error", {});
		
		
		public static function getInstance():DebugManager{
			return	_instance;
		}
		
		
		public function DebugManager(){
			if(_instance)	throw	new Error("don't create instance");
			_instance = this;
		}
		
		
		public static function error($type:String, $message:String):void{
			var p:* = _evt.param;
			p.type = $type;
			p.message = $message;
			_instance.dispatchEvent(_evt);
			
			if(ExternalInterface.available && Extensions.isScaleform)	ExternalInterface.call("error", $type, $message);
			trace("error", $type, $message);
		}
	}
}