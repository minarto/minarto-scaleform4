package com.minarto.controls.widget {
	import flash.display.*;
	import flash.events.Event;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class Widget extends Sprite implements IWidget {
		public var background:DisplayObject, widgetID:String;
		
		
		public function Widget(){
			addEventListener(Event.ADDED_TO_STAGE, configUI);
		}
		
		
		public function open():void{
			visible = true;
		}
		
		
		public function close():void{
			visible = false;
		}
		
		
		public function destroy():void{
			removeEventListener(Event.ADDED_TO_STAGE, configUI);
		}
		
		
		protected function configUI($e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, configUI);
		}
	}
}