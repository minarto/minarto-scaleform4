package com.minarto.manager.widget {
	import com.minarto.controls.widget.Widget;
	import com.minarto.events.CustomEvent;
	import com.scaleform.mmo.events.WidgetEvent;
	
	import de.polygonal.core.ObjectPool;
	
	import flash.display.*;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.utils.*;
	
	import scaleform.clik.core.CLIK;
	import scaleform.clik.events.DragEvent;
	import scaleform.gfx.Extensions;
	import com.minarto.manager.LoadSourceManager;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class WidgetManager extends EventDispatcher {
		protected static var _instance:WidgetManager = new WidgetManager;
		
		
		protected var widgetDic:* = { }, topWidgetDic:* = {}, 
			dragWidget:Sprite, 
			containers:* = {},
			_sources:Array = [], pool:ObjectPool,
			currentLoadWidgetObj:LoadWidgetObject, _loadID:uint;
		
		
		public function WidgetManager() {
			if(_instance)	throw new Error("don't create instance");
			
			if(ExternalInterface.available && Extensions.isScaleform)	ExternalInterface.call("WidgetManager", this);
			trace("WidgetManager init");
			
			pool = new ObjectPool(true);
			pool.allocate(10, LoadWidgetObject);
		}
		
		
		public static function getInstance():WidgetManager{
			return	_instance;
		}
		
		
		public function setContainer($container:DisplayObjectContainer, $topArrange:int=0):void{
			containers[$topArrange] = $container;
			
			for(var widgetID:* in widgetDic){
				var o:LoadWidgetObject = widgetDic[widgetID];
				if(o.topArrange == $topArrange){
					var w:Widget = o.widget;
					if(!$container.contains(w))	$container.addChild(w);
				}
			}
		}
		
		
		/**
		 * 
		 * @param $args widgetID, src, widgetID, src, widgetID, src, widgetID, src... 
		 * 
		 */		
		public function addWidget($widgetID:String, $src:String, $parentWidgetID:String="stage", $xrate:Number=0, $yrate:Number=0, $align:String="C", $xpadding:Number=10, $ypadding:Number=10, $scaleEnable:Boolean=true):void{
			var o:LoadWidgetObject = pool.object;
			
			o.widgetID = $widgetID;
			o.src = $src;
			o.parentWidgetID = $parentWidgetID;
			o.xrate = $xrate;
			o.yrate = $yrate;
			o.align = $align;
			o.xpadding = $xpadding;
			o.ypadding = $ypadding;
			o.scaleEnable = $scaleEnable;
			
			_sources.push(o);
		}
		
		
		public function load():void{
			_loadUI();
		}
		
		
		public function loadWidgetByArrange($widgetID:String, $src:String, $topArrange:int=0):void{
			var o:LoadWidgetObject = pool.object;
			o.widgetID = $widgetID;
			o.topArrange = $topArrange;
			o.src = $src;
			_sources.push(o);
			
			if(!currentLoadWidgetObj)	_loadUI();
		}
		
		
		public function unLoadWidget(...$args):void{
			if ($args.length) {
				for(var p:* in $args){
					var src:String = $args[p];
					
					for(var i:uint=0, c:uint = _sources.length; i<c; ++ i){
						currentLoadWidgetObj = _sources[i];
						if(currentLoadWidgetObj.src == src){
							pool.object = currentLoadWidgetObj;
							_sources.splice(i, 1);
							-- i;
						}
					}
					
					if(currentLoadWidgetObj && currentLoadWidgetObj.src == src)	LoadSourceManager.close(src, onLoadUI);
				}
				
				var a:Array = widgetDic[src];
				for(p in a){
					var w:Widget = a[p];
					delWidget(w.widgetID, w);
				}
			}
			else{
				clearTimeout(_loadID);
				
				if(currentLoadWidgetObj)	LoadSourceManager.close(currentLoadWidgetObj.src, onLoadUI);
				
				delWidget(null, null);				
				for(i=0, c = _sources.length; i<c; ++ i){
					currentLoadWidgetObj = _sources[i];
					pool.object = currentLoadWidgetObj;
				}
				_sources.length = 0;
			}
			
			currentLoadWidgetObj = null;
		}
		
		
		protected function _loadUI():void {
			currentLoadWidgetObj = _sources.shift();
			if(currentLoadWidgetObj)	LoadSourceManager.load(currentLoadWidgetObj.src, onLoadUI);
		}
		
		
		protected function onLoadUI($widget:DisplayObject):void{
			var w:Widget = $widget as Widget;
			currentLoadWidgetObj.widget = w;
			var id:String = currentLoadWidgetObj.widgetID;
			w.widgetID = id;
			widgetDic[id] = currentLoadWidgetObj;
			
			w.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			w.addEventListener(DragEvent.DRAG_START, onDragStart);
			w.addEventListener(WidgetEvent.CLOSE_WIDGET, onClose);
			
			WidgetArrangeManager.addWidget(id, $widget);
			
			var container:DisplayObjectContainer = containers[currentLoadWidgetObj.topArrange];
			if(container)	container.addChild($widget);
			
			currentLoadWidgetObj = null;
			if(_sources.length)	_loadID = setTimeout(_loadUI, 200);
		}
		
		
		public function delWidget($widgetID:String, $widget:Widget):void{
			if($widgetID && $widget){
				
				$widget.destroy();
				
				$widget.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				$widget.removeEventListener(DragEvent.DRAG_START, onDragStart);
				$widget.removeEventListener(WidgetEvent.CLOSE_WIDGET, onClose);
				
				delete widgetDic[$widgetID];
				
				var container:DisplayObjectContainer = $widget.parent;
				container.removeChild($widget);
			}
			else{
				for ($widgetID in widgetDic) {
					var o:LoadWidgetObject = widgetDic[$widgetID];
					
					$widget = o.widget;
					
					$widget.destroy();
					
					$widget.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
					$widget.removeEventListener(DragEvent.DRAG_START, onDragStart);
					$widget.removeEventListener(WidgetEvent.CLOSE_WIDGET, onClose);
					
					container = $widget.parent;
					container.removeChild($widget);
					
					pool.object = o;
				}
				
				widgetDic = {};
			}
		}
		
		
		public function open($widgetID:String):Widget {
			var o:LoadWidgetObject = widgetDic[$widgetID];
			
			var w:Widget = getWidget($widgetID);
			if (w) {
				var container:DisplayObjectContainer = w.parent;
				container.setChildIndex(w, container.numChildren - 1);
				
				w.open();
				
				dispatchEvent(new CustomEvent("focusWidget", w));
			}			
			
			return	w;
		}
		
		
		public function close($widgetID:String):Widget {
			var w:Widget = getWidget($widgetID);
			if (w) {
				w.close();
			}
			
			return	w;
		}
		
		
		public function getTopWidget($topArrange:int=0):Widget {
			var container:DisplayObjectContainer = containers[$topArrange];
			return	container ? container.getChildAt(container.numChildren - 1) as Widget : null;
		}
		
		
		public function getFocusWidget():Widget{
			var s:Stage = CLIK.stage;
			
			var f:InteractiveObject = s.focus;
			var p:DisplayObjectContainer = f.parent;
			while(p){
				if(p as Widget){
					return	p as Widget;
				}
				else{
					p = p.parent;
				}
			}
			
			return	null;
		} 
		
		
		public function getWidget($widgetID:String):Widget {
			return	widgetDic[$widgetID];
		}
		
		
		private function onClose($e:DragEvent):void {
			var w:Widget = $e.dragSprite as Widget;
			w.close();
			dispatchEvent(new CustomEvent(WidgetEvent.CLOSE_WIDGET, w));
		}
		
		
		private function onMouseDown($e:MouseEvent):void {
			var w:DisplayObject = $e.currentTarget as DisplayObject;
			var container:DisplayObjectContainer = w.parent;
			container.setChildIndex(w, container.numChildren - 1);
			
			dispatchEvent(new CustomEvent("focusWidget", w));
		}
		
		
		private function onDragStart($e:DragEvent):void {
			dragWidget = $e.dragSprite;
			dragWidget.startDrag();
			
			CLIK.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, true);
		}
		
		
		private function onMouseUp($e:MouseEvent):void {
			$e.stopPropagation();
			
			CLIK.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp, true);
			
			dragWidget.stopDrag();
			dragWidget = null;
		}
	}
}