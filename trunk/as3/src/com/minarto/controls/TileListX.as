package com.minarto.controls {
	import scaleform.clik.constants.DirectionMode;
	import scaleform.clik.controls.TileList;
	import scaleform.clik.interfaces.IListItemRenderer;
	

	public class TileListX extends TileList {
		[Inspectable(defaultValue="")]
		override public function set itemRendererInstanceName($v:String):void {
			if (!$v || !parent) return;
			var i:uint = 0;
			var newRenderers:Vector.<IListItemRenderer> = new <IListItemRenderer>[];
			
			var clip:IListItemRenderer;
			while (clip = parent.getChildByName($v + (i++)) as IListItemRenderer) {
				newRenderers.push(clip);
			}
			
			if (newRenderers.length) {
				itemRendererList = newRenderers;
			}
			else {
				if (componentInspectorSetting) return;
				itemRendererList = null;
			}
		}
		
		
		override public function set itemRendererList($v:Vector.<IListItemRenderer>):void {
			if (_usingExternalRenderers) {
				for (var i:* in _renderers) {
					cleanUpRenderer(getRendererAt(i));
				}
			}
			
			_usingExternalRenderers = $v ? $v.length : false;
			_renderers = $v;
			
			if (_usingExternalRenderers) {
				for (i in $v) {
					setupRenderer(getRendererAt(i));
				}
				_totalRenderers = $v.length;
			}
			invalidateRenderers();
		}
	}
}