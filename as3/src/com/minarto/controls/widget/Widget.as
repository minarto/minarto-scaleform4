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
			var t:* = this;
			addEventListener(Event.ADDED_TO_STAGE, function ($e:Event):void{
				t.removeEventListener(Event.ADDED_TO_STAGE, arguments.callee);
				
				CLIK.initialize(stage, null);
				configUI();
			});
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
		
		
		protected function configUI():void {
		}
	}
}