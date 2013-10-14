package com.minarto.controls.widget {
	import flash.events.IEventDispatcher;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public interface IWidget extends IEventDispatcher {
		function open():void;
		
		function close():void;
		
		function destroy():void;
	}
}