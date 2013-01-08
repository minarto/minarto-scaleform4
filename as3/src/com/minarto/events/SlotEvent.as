package com.minarto.events {
	import flash.events.Event;
	
	public class SlotEvent extends Event {
		public var index:int = - 1, fromIndex:int = - 1,
			listKey:String, fromListKey:String,
			data:*, fromData:*;
		
		
		public function SlotEvent($type:String, $bubbles : Boolean = false, $cancelable : Boolean = false) {
			super($type, $bubbles, $cancelable);
		}
		
		
		override public function clone() : Event {
			var e:SlotEvent = new SlotEvent(type, bubbles, cancelable);
			e.index = index;
			e.listKey = listKey;
			e.data = data;
			
			e.fromIndex = fromIndex;
			e.fromListKey = fromListKey;
			e.fromData = fromData;
			
			return e;
		}
	}
}