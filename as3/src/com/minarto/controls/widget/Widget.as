package com.minarto.controls.widget {
	import flash.display.*;
	import flash.events.Event;
	
	import scaleform.clik.core.CLIK;
	import scaleform.gfx.Extensions;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class Widget extends Sprite {
		public var background:MovieClip, widgetID:String;
		
		
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
			removeEventListener(Event.ADDED_TO_STAGE, configUI);
		}
		
		
		protected function configUI($e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, configUI);
			CLIK.initialize(stage, null);
			
			if(Boolean(Extensions.CLIK_addedToStageCallback))	Extensions.CLIK_addedToStageCallback(widgetID, CLIK.getTargetPathFor(this), this);
		}
	}
}