package com.minarto.manager.widget {
	import com.minarto.controls.widget.Widget;
	import com.minarto.events.CustomEvent;
	import com.minarto.manager.LoadSourceManager;
	import com.scaleform.mmo.events.WidgetEvent;
	
	import de.polygonal.core.ObjectPool;
	
	import flash.display.*;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.utils.*;
	
	import scaleform.clik.core.CLIK;
	import scaleform.clik.events.DragEvent;
	import scaleform.gfx.Extensions;
	import scaleform.gfx.FocusManager;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class WidgetManager extends EventDispatcher {
		protected var widgetDic:* = {}, widgetDataDic:* = {}, 
			dragWidget:Sprite, focusEvt:CustomEvent = new CustomEvent("focusWidget"), closeEvt:CustomEvent = new CustomEvent(WidgetEvent.CLOSE_WIDGET), completeEvt:Event = new Event(Event.COMPLETE),  
			containers:* = {},
			_sources:Array = [], pool:ObjectPool,
			currentLoadWidgetObj:WidgetData, _loadID:uint, currentLoadingWidgetID:String, currentLoadingWidgetURL:String;
		
		
		public function WidgetManager() {
			pool = new ObjectPool(true);
			pool.allocate(10, WidgetData);
		}
		
		
		public function setContainer($container:DisplayObjectContainer, $topArrange:uint=0):void{
			if($container)	containers[$topArrange] = $container;
		}
		
		
		public function loadWidget($widgetID:String, $src:String):void{
			_sources.push($widgetID, $src);
			if(!currentLoadingWidgetURL){
				currentLoadingWidgetID = _sources[0];
				currentLoadingWidgetURL = _sources[1];
				_sources.splice(0, 2);
				
				load();
			}
		}
		
		
		public function setWidgetData($widgetID:String, $data:WidgetData):void{
			widgetDataDic[$widgetID] = $data;
		}
		
		protected function load():void{
			LoadSourceManager.load(currentLoadingWidgetURL, onLoadUI);
		}
		
		
		protected function onLoadUI($widget:DisplayObject):void{
			if($widget){
				widgetDic[currentLoadingWidgetID] = $widget;
				
				var s:Sprite = $widget as Widget;
				if(s){
					s.addEventListener(DragEvent.DRAG_START, onDragStart);
					s.addEventListener(WidgetEvent.CLOSE_WIDGET, onClose);
				}
				
				s = $widget as Sprite;
				if(s)	s.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				
				var data:WidgetData = widgetDataDic[currentLoadingWidgetID];
				s = data ? containers[data.containerIndex] : containers[0];
				if(s)	s.addChild($widget);
				
				if(Boolean(Extensions.CLIK_addedToStageCallback))	Extensions.CLIK_addedToStageCallback(currentLoadingWidgetID, CLIK.getTargetPathFor($widget as DisplayObjectContainer), $widget);
			}
			
			if(_sources.length){
				currentLoadingWidgetID = _sources[0];
				currentLoadingWidgetURL = _sources[1];
				_sources.splice(0, 2);
				
				_loadID = setTimeout(load, 200);
			}
			else{
				currentLoadingWidgetID = null;
				currentLoadingWidgetURL = null;
				
				WidgetBridge.action(completeEvt);
			}
		}
		
		
		public function delWidgetByID($widgetID:String):void{
			if($widgetID){
				if(currentLoadingWidgetID == $widgetID){
					clearTimeout(_loadID);
					LoadSourceManager.unLoad(currentLoadingWidgetURL, onLoadUI);
				}
				
				var d:DisplayObject = widgetDic[$widgetID];
				if(d){
					var w:* = d as Widget;
					if(w){
						d.removeEventListener(DragEvent.DRAG_START, onDragStart);
						d.removeEventListener(WidgetEvent.CLOSE_WIDGET, onClose);
					}
					
					w = d as InteractiveObject;
					if(w)	w.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
					
					
					var c:DisplayObjectContainer = d.parent;
					if(c)	c.removeChild(d);
				}
				else{
					for(var i:uint = 0, j:uint = _sources.length; i<j; i+= 2){
						if(_sources[i] == $widgetID){
							_sources.splice(i, 2);
							i -= 2;
						}
					}
				}
			}
		}
		
		
		public function delWidget($widget:DisplayObject):void{
			if($widget){
				var w:Widget = $widget as Widget;
				if(w)	w.destroy();
				
				$widget.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				$widget.removeEventListener(DragEvent.DRAG_START, onDragStart);
				$widget.removeEventListener(WidgetEvent.CLOSE_WIDGET, onClose);
				
				var c:DisplayObjectContainer = $widget.parent;
				if(c)	c.removeChild($widget);
				
				for(var id:String in widgetDic){
					if(widgetDic[id] == $widget){
						delete	widgetDic[id];
					}
				}
			}
		}
		
		
		public function delWidgetAll():void{
			if(currentLoadingWidgetURL){
				clearTimeout(_loadID);
				LoadSourceManager.unLoad(currentLoadingWidgetURL, onLoadUI);
			}
			_sources.length = 0;
			
			for(var id:String in widgetDic){
				var d:DisplayObject = widgetDic[id];
				d.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				d.removeEventListener(DragEvent.DRAG_START, onDragStart);
				d.removeEventListener(WidgetEvent.CLOSE_WIDGET, onClose);
				
				var c:DisplayObjectContainer = w.parent;
				if(c)	c.removeChild(d);
				
				var w:Widget = d as Widget;
				if(w)	w.destroy();
			}
			
			widgetDic = {};
		}
		
		
		public function open($widget:DisplayObject):DisplayObject {
			if ($widget) {
				var c:DisplayObjectContainer = $widget.parent;
				if(c){
					c.setChildIndex($widget, c.numChildren - 1);
				}
				else{
					var o:WidgetData = widgetDic[$widget];
					c = containers[o.containerIndex];
					if(c)	c.addChild($widget);
				}
				
				var w:Widget = $widget as Widget;
				if(w)	w.open();
				$widget.visible = true;
				
				FocusManager.setFocus($widget as InteractiveObject);
				
				if(FocusManager.getFocus() == $widget){
					focusEvt.param = $widget;
					WidgetBridge.action(focusEvt);
				}				
			}			
			
			return	$widget;
		}
		
		
		public function openByID($widgetID:String):DisplayObject {
			return	open(getWidget($widgetID));
		}
		
		
		public function close($widget:DisplayObject):DisplayObject {
			if($widget)	$widget.visible = false;
			
			var w:Widget = $widget as Widget;
			if (w)	w.close();
			
			return	$widget;
		}
		
		
		public function closeByID($widgetID:String):DisplayObject {
			return	close(getWidget($widgetID));
		}
		
		
		public function getTopWidget($containerIndex:uint=0):DisplayObject {
			var c:DisplayObjectContainer = containers[$containerIndex];
			return	c ? c.getChildAt(c.numChildren - 1) : c;
		}
		
		
		public function getFocusWidget($controllerIdx:uint=0):InteractiveObject{
			var t:InteractiveObject = FocusManager.getFocus($controllerIdx);
			while(t){
				for(var i:* in containers){
					var c:DisplayObjectContainer = containers[i];
					if(c.contains(t))	return	t;
				}
				
				t = t.parent;
			}
			
			return	null;
		} 
		
		
		public function getWidget($widgetID:String):DisplayObject {
			return	widgetDic[$widgetID];
		}
		
		
		protected function onClose($e:DragEvent):void {
			var w:Widget = $e.dragSprite as Widget;
			w.close();
			if(getFocusWidget() == w){
				FocusManager.setFocus(null);
			}
			closeEvt.param = w;
			WidgetBridge.action(closeEvt);
		}
		
		
		protected function onMouseDown($e:MouseEvent):void {
			var w:DisplayObject = $e.currentTarget as DisplayObject;
			var c:DisplayObjectContainer = w.parent;
			if(c)	c.setChildIndex(w, c.numChildren - 1);
			
			focusEvt.param = w;
			WidgetBridge.action(focusEvt);
		}
		
		
		protected function onDragStart($e:DragEvent):void {
			dragWidget = $e.dragSprite;
			dragWidget.startDrag();
			
			CLIK.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		
		protected function onMouseUp($e:MouseEvent):void {
			$e.stopPropagation();
			
			CLIK.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			dragWidget.stopDrag();
			dragWidget = null;
		}
	}
}