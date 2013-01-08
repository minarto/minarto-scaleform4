package com.minarto.events {
	import flash.events.Event;

	/**
	 * @author KIMMINHWAN
	 */
	public class CustomEvent extends Event {
		public var param:*;
		
		override public function toString() : String {
			return "com.minarto.events.CustomEvent";
		}
		
		
		public function CustomEvent($type:String, $param:*=null, $bubbles : Boolean = false, $cancelable : Boolean = false) {
			super($type, $bubbles, $cancelable);
			param = $param;
		}
		
		
		override public function clone() : Event {
			return new CustomEvent(type, param, bubbles, cancelable);
		}
	}
}