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
		protected static var _instance:WidgetManager = new WidgetManager;
		
		
		protected var widgetDic:Dictionary = new Dictionary(true), widgetIdDic:* = {}, 
			dragWidget:Sprite, focusEvt:CustomEvent = new CustomEvent("focusWidget"), closeEvt:CustomEvent = new CustomEvent(WidgetEvent.CLOSE_WIDGET), 
			containers:* = {},
			_sources:Array = [], pool:ObjectPool,
			currentLoadWidgetObj:WidgetParamObject, _loadID:uint;
		
		
		public function WidgetManager() {
			if(_instance)	throw new Error("don't create instance");
			
			if(ExternalInterface.available && Extensions.isScaleform)	ExternalInterface.call("WidgetManager", this);
			trace("WidgetManager init");
			
			pool = new ObjectPool(true);
			pool.allocate(10, WidgetParamObject);
		}
		
		
		public static function getInstance():WidgetManager{
			return	_instance;
		}
		
		
		public function setContainer($containers:DisplayObjectContainer, $topArrange:int=0):void{
			containers[$topArrange] = $containers;
		}
		
		
		public function loadWidget($src:String, $widgetID:String, $containerIndex:int=0, $resolution:String=null, $widgetArrangeObject:WidgetArrangeObject=null, ...$resolutionNarrangeObject):void{
			var o:WidgetParamObject = pool.object;
			
			o.src = $src;
			o.widgetID = $widgetID;
			o.containerIndex = $containerIndex;
			
			if($widgetArrangeObject && $resolution){
				o.setArrange($widgetArrangeObject, $resolution);
				
				for(var i:uint = 0, c:uint = $resolutionNarrangeObject.length; i<c; i += 2){
					o.setArrange($resolutionNarrangeObject[i + 1], $resolutionNarrangeObject[i]);
				}
			}			
			
			_sources.push(o);
		}
		
		
		public function load():void{
			if(_sources.length){
				currentLoadWidgetObj = _sources.shift();
				_loadUI();
			}
		}
		
		
		protected function _loadUI():void {
			LoadSourceManager.load(currentLoadWidgetObj.src, onLoadUI);
		}
		
		
		protected function onLoadUI($widget:DisplayObject):void{
			var w:Widget = $widget as Widget;
			currentLoadWidgetObj.widget = w;
			var id:String = w.widgetID;
			widgetDic[w] = currentLoadWidgetObj;
			widgetIdDic[id] = currentLoadWidgetObj;
			
			w.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			w.addEventListener(DragEvent.DRAG_START, onDragStart);
			w.addEventListener(WidgetEvent.CLOSE_WIDGET, onClose);
			
			WidgetArrangeManager.addWidget(currentLoadWidgetObj);
			
			var c:DisplayObjectContainer = containers[currentLoadWidgetObj.containerIndex];
			if(c)	c.addChild($widget);
			
			if(_sources.length){
				currentLoadWidgetObj = _sources.shift();
				_loadID = setTimeout(_loadUI, 200);
			}
			else{
				currentLoadWidgetObj = null;
				WidgetArrangeManager.arrange(null);
				dispatchEvent(new Event(Event.COMPLETE));
			}
			
			if(Boolean(Extensions.CLIK_addedToStageCallback))	Extensions.CLIK_addedToStageCallback(id, CLIK.getTargetPathFor(w), w);
		}
		
		
		public function delWidgetByID(...$widgetID):void{
			if($widgetID.length){
				for(var i:* in $widgetID){
					var widgetID:String = $widgetID[i];
					
					if(currentLoadWidgetObj && currentLoadWidgetObj.widgetID == widgetID){
						_delWidget(o);
					}
					
					for(var j:* in _sources){
						var o:WidgetParamObject = _sources[j];
						if(o.widgetID == widgetID){
							_delWidget(o);
							break;
						}
					}
					
					for(j in widgetIdDic){
						o = widgetIdDic[j];
						if(o.widgetID == widgetID){
							_delWidget(o);
							break;
						}
					}
				}
			}
			else{
				_delWidget(null);
			}
		}
		
		
		public function delWidget(...$widget):void{
			if($widget.length){
				for(var i:* in $widget){
					var widget:Widget = $widget[i];
					
					for(var j:* in widgetDic){
						var o:WidgetParamObject = widgetDic[j];
						if(o.widget == widget){
							_delWidget(o);
							break;
						}
					}
				}
			}
			else{
				_delWidget(null);
			}
		}
		
		
		protected function _delWidget($o:WidgetParamObject):void{
			if($o){
				if(currentLoadWidgetObj == $o){
					clearTimeout(_loadID);
					LoadSourceManager.unLoad($o.src, onLoadUI);
					currentLoadWidgetObj = null;
				}
				else{
					for(var i:* in _sources){
						var o:WidgetParamObject = _sources[i];
						if(o == $o){
							pool.object = o;
							_sources.splice(i, 1);
							return;
						}
					}
					
					for(i in widgetDic){
						o = widgetDic[i];
						if(o == $o){
							var w:Widget = o.widget;
							w.destroy();
							w.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
							w.removeEventListener(DragEvent.DRAG_START, onDragStart);
							w.removeEventListener(WidgetEvent.CLOSE_WIDGET, onClose);
							
							pool.object = o;
							
							var c:DisplayObjectContainer = w.parent;
							if(c)	c.removeChild(w);
							
							delete	widgetDic[w];
							delete	widgetIdDic[o.widgetID];
							return;
						}						
					}
				}
			}
			else{
				if(currentLoadWidgetObj){
					clearTimeout(_loadID);
					LoadSourceManager.unLoad(currentLoadWidgetObj.src, onLoadUI);
					currentLoadWidgetObj = null;
				}
				
				for(i in _sources){
					o = _sources[i];
					pool.object = o;
				}
				_sources.length = 0;
				
				for(i in widgetDic){
					o = widgetDic[i];
					w = o.widget;
					w.destroy();
					w.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
					w.removeEventListener(DragEvent.DRAG_START, onDragStart);
					w.removeEventListener(WidgetEvent.CLOSE_WIDGET, onClose);
					
					pool.object = o;
					
					c = w.parent;
					if(c)	c.removeChild(w);
				}
				
				widgetDic = new Dictionary(true);
				widgetIdDic = {};
			}
		}
		
		
		public function open($widget:Widget):Widget {
			return	_open($widget);
		}
		
		
		public function openByID($widgetID:String):Widget {
			return	_open(getWidget($widgetID));
		}
		
		
		protected function _open($widget:Widget):Widget {
			if ($widget) {
				var c:DisplayObjectContainer = $widget.parent;
				if(c){
					c.setChildIndex($widget, c.numChildren - 1);
				}
				else{
					var o:WidgetParamObject = widgetDic[$widget];
					c = containers[o.containerIndex];
					if(c)	c.addChild($widget);
				}
				
				$widget.open();
				FocusManager.setFocus($widget);
				
				if(FocusManager.getFocus() == $widget){
					focusEvt.param = $widget;
					dispatchEvent(focusEvt);
				}				
			}			
			
			return	$widget;
		}
		
		
		public function close($widget:Widget):Widget {
			return	_close($widget);
		}
		
		
		public function closeByID($widgetID:String):Widget {
			return	_close(getWidget($widgetID));
		}
		
		
		protected function _close($widget:Widget):Widget {
			if ($widget) $widget.close();
			return	$widget;
		}
		
		
		public function getTopWidget($containerIndex:int=0):DisplayObject {
			var c:DisplayObjectContainer = containers[$containerIndex];
			return	c ? c.getChildAt(c.numChildren - 1) : c;
		}
		
		
		public function getFocusWidget():Widget{
			var f:InteractiveObject = FocusManager.getFocus();
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
			return	widgetIdDic[$widgetID];
		}
		
		
		protected function onClose($e:DragEvent):void {
			var w:Widget = $e.dragSprite as Widget;
			w.close();
			if(getFocusWidget() == w){
				FocusManager.setFocus(null);
			}
			closeEvt.param = w;
			dispatchEvent(closeEvt);
		}
		
		
		protected function onMouseDown($e:MouseEvent):void {
			var w:DisplayObject = $e.currentTarget as DisplayObject;
			var c:DisplayObjectContainer = w.parent;
			if(c)	c.setChildIndex(w, c.numChildren - 1);
			
			focusEvt.param = w;
			dispatchEvent(focusEvt);
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