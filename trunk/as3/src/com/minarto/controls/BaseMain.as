package com.minarto.controls {
	import com.minarto.data.*;
	import com.minarto.manager.*;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.system.System;
	
	import scaleform.clik.core.CLIK;
	import scaleform.gfx.Extensions;
	

	/**
	 * @author KIMMINHWAN
	 */
	public class BaseMain extends Sprite {
		public var toolTipManager:IToolTipContainer, setValue:Function, getValue:Function;
		
		
		public function BaseMain() {
			Extensions.enabled = true;
			CLIK.initialize(stage, null);
			addEventListener(Event.ADDED_TO_STAGE, configUI);
			
			Binding.init(this);
			WidgetManager.init(this);
			Binding.addNPlay("mode", setMode);
		}
		
		
		protected function configUI($e:Event):void{
			removeEventListener($e.type, configUI);
			
			if(Extensions.isScaleform){
				tabEnabled = false;
				tabChildren = false;
			}
			
			stage.doubleClickEnabled = false;
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			toolTipManager.del();
			
			if(Boolean(Extensions.CLIK_addedToStageCallback))	Extensions.CLIK_addedToStageCallback("main", CLIK.getTargetPathFor(this), this);
		}
		
		
		protected function setMode($mode:String):void {
			WidgetManager.del();
			Binding.del();
			System.gc();
			Binding.add("mode", setMode);
		}
	}
}
