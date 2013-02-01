package com.minarto.controls {
	import com.minarto.data.*;
	import com.minarto.manager.*;
	import com.minarto.manager.tooltip.*;
	import com.minarto.manager.widget.*;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.system.System;
	
	import scaleform.clik.core.CLIK;
	import scaleform.gfx.Extensions;
	

	/**
	 * @author KIMMINHWAN
	 */
	public class BaseMain extends Sprite {
		public var toolTipContainer:IToolTipManager;
		
		
		public function BaseMain() {
			CLIK.initialize(stage, null);
			addEventListener(Event.ADDED_TO_STAGE, configUI);
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
			
			ToolTipBinding.init(toolTipContainer);
			
			if(Boolean(Extensions.CLIK_addedToStageCallback))	Extensions.CLIK_addedToStageCallback("main", CLIK.getTargetPathFor(this), this);
		}
		
		
		protected function setMode($mode:String):void {
			ListBinding.delListBind(null);
			ListBinding.delDataBind(null, null);
			WidgetBridge.delWidgetAll();
			Binding.delBind(null, null);
			
			System.gc();
		}
	}
}
