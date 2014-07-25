package com.minarto.manager {
	import com.minarto.data.Binding;
	
	import flash.display.*;
	import flash.events.Event;
	
	import scaleform.clik.core.CLIK;
	
	/**
	 * @author minarto
	 */
	public function stageResizeManager($onHandler:Function=null, ...$args):void{
		var b:Binding = Binding.GET("__COMMON__"), stage:Stage = CLIK.stage;
		
		if($onHandler){
			$args.unshift(Event.RESIZE, $onHandler);
			b.addValuePlay.apply(null, $args);
		}
		
		if(stage && !stage.hasEventListener(Event.RESIZE)){
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, function($e:Event):void{
				b.set(Event.RESIZE, stage.stageWidth, stage.stageHeight);
			});
			stage.dispatchEvent(new Event(Event.RESIZE));
		}
	}
}