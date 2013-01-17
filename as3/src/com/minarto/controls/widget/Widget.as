package com.minarto.controls.widget {
	import flash.display.*;
	import flash.events.Event;
	
	import scaleform.clik.core.CLIK;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class Widget extends Sprite {
		protected var _widgetID:String;
		
		
		public var background:MovieClip;
		
		
		public function get widgetID():String {
			return _widgetID;
		}
		
		
		public function Widget(){
			addEventListener(Event.ADDED_TO_STAGE, configUI);
		}
		
		
		protected function setTitle($s:String):void {
			if (background)	background.title = $s;
		}
		
		
		public function open():void{
			visible = true;
		}
		
		
		public function close():void{
			visible = false;
		}
		
		
		public function destroy():void{
		}
		
		
		override public function toString() : String {
			return "com.minarto.controls.widget.Widget";
		}
		
		
		protected function configUI($e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, configUI);
			CLIK.initialize(stage, null);
		}
	}
}