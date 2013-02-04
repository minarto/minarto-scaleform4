import com.minarto.controls.widget.Widget;
import com.minarto.manager.LoadSourceManager;
import com.minarto.manager.widget.*;
import com.minarto.utils.ObjectPool;
import flash.external.ExternalInterface;
import gfx.events.EventDispatcher;
import gfx.events.EventTypes;
import gfx.managers.FocusHandler;


class com.minarto.manager.widget.WidgetManager extends EventDispatcher {
	private static var _instance:WidgetManager = new WidgetManager;
		
		
	private var widgetDic = { }, widgetIdDic = {}, 
		dragWidget:MovieClip, 
		containers = {},
		_sources:Array = [], pool:ObjectPool,
		currentLoadWidgetObj:LoadWidgetObject, 
		focusEvt = { type:"focusWidget", target:this }, closeEvt = { type:"closeWidget", target:this },
		onMouseDown:Function, onMouseUp:Function;
	
	
	public function WidgetManager() {
		if (_instance)	throw new Error("don't create instance");
		
		Mouse.addListener(this);
		
		onMouseDown = _onMouseDown;
		
		pool = new ObjectPool(1, LoadWidgetObject);
		pool.allocate(10, LoadWidgetObject);
			
		if(ExternalInterface.available)	ExternalInterface.call("WidgetManager", this);
		trace("WidgetManager init");
	}
	
	
	public static function getInstance():WidgetManager{
		return	_instance;
	}
	
	
	public static function targetPathToWidget($targetPath:String) {
		var a:Array = $targetPath.split(".");
		
		$targetPath = _root;
		for (var i:Number = 0, c:Number = a.length; i < c; ++ i) {
			$targetPath = $targetPath[a[i]];
			if ($targetPath as Widget)	return	$targetPath;
		}
		
		return $targetPath;
	}
		
		
	public function setContainer($container:MovieClip, $topArrange:Number):Void{
		containers[$topArrange || 0] = $container;
	}
		
		
	public function loadWidget($src:String, $widgetID:String, $parentWidgetID:String, $xrate:Number, $yrate:Number, $align:String, $xpadding:Number, $ypadding:Number, $scaleEnable:Boolean, $topArrange:Number):Void{
		var o:LoadWidgetObject = pool.object;
		
		o.widgetID = $widgetID;
		o.src = $src;
		o.parentWidgetID = $parentWidgetID || "stage";
		o.xrate = $xrate || 0;
		o.yrate = $yrate || 0;
		o.align = $align || "C";
		o.xpadding = $xpadding || 10;
		o.ypadding = $ypadding || 10;
		o.scaleEnable = $scaleEnable;
		o.topArrange = $topArrange || 0;
		
		_sources.push(o);
	}
		
		
	public function load():Void{
		if(_sources.length){
			currentLoadWidgetObj = _sources.shift();
			_loadUI();
		}
	}
		
		
	private function _loadUI():Void {
		var c:MovieClip = containers[currentLoadWidgetObj.topArrange];
		var d:Number = c.getNextHighestDepth();
		c = c.createEmptyMovieClip("w" + d, d);
		currentLoadWidgetObj.widget = c;
		LoadSourceManager.load(currentLoadWidgetObj.src, c, "onLoadUI", this);
	}
		
		
	private function onLoadUI($widget:MovieClip):Void {
		var w:Widget = $widget as Widget;
		
		var id:String = w.widgetID;
		widgetDic[targetPath(w)] = currentLoadWidgetObj;
		widgetIdDic[id] = currentLoadWidgetObj;
		
		w.addEventListener("dragStart", this, "onDragStart");
		w.addEventListener("closeWidget", this, "onClose");
		
		WidgetArrangeManager.addArrange(currentLoadWidgetObj);
		
		currentLoadWidgetObj = null;
		if (_sources.length) {
			currentLoadWidgetObj = _sources.shift();
			_loadUI();
		}
		else {
			currentLoadWidgetObj = null;
		}
		
		if (_global.CLIK_loadCallback) _global.CLIK_loadCallback(id, targetPath(w), w);
	}
		
		
	public function delWidgetBySrc($src:String):Void{
		if (arguments.length) {
			for(var i in arguments){
				var src:String = arguments[i];
				
				if(currentLoadWidgetObj && currentLoadWidgetObj.src == src){
					_delWidget(o);
				}
				
				for(var j in _sources){
					var o:LoadWidgetObject = _sources[j];
					if(o.src == src){
						_delWidget(o);
					}
				}
			}
		}
		else{
			_delWidget(null);
		}
	}
		
		
	public function delWidgetByID($widgetID:String):Void{
		if (arguments.length) {
			for(var i in arguments){
				var widgetID:String = arguments[i];
				
				if(currentLoadWidgetObj && currentLoadWidgetObj.widgetID == widgetID){
					_delWidget(o);
				}
				
				for(var j in _sources){
					var o:LoadWidgetObject = _sources[j];
					if(o.widgetID == widgetID){
						_delWidget(o);
					}
				}
				
				for(j in widgetIdDic){
					o = widgetIdDic[j];
					if(o.widgetID == widgetID){
						_delWidget(o);
					}
				}
			}
		}
		else{
			_delWidget(null);
		}
	}
		
		
	public function delWidget($widget:Widget):Void{
		if (arguments.length) {
			for(var i in arguments){
				var widget:Widget = arguments[i];
				
				for(var j in widgetDic){
					var o:LoadWidgetObject = widgetDic[j];
					if(o.widget == widget){
						_delWidget(o);
					}
				}
			}
		}
		else{
			_delWidget(null);
		}
	}
		
		
	private function _delWidget($o:LoadWidgetObject):Void{
		if($o){
			if(currentLoadWidgetObj == $o){
				LoadSourceManager.getInstance().close($o.src, $o.widget);
				currentLoadWidgetObj = null;
			}
			else{
				for(var i in _sources){
					var o:LoadWidgetObject = _sources[i];
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
						w.removeEventListener("dragStart", this, "onDragStart");
						w.removeEventListener("closeWidget", this, "onClose");
						
						pool.object = o;
						
						w.removeMovieClip();
						
						delete	widgetDic[i];
						delete	widgetIdDic[o.widgetID];
						return;
					}
				}
			}
		}
		else{
			if(currentLoadWidgetObj){
				LoadSourceManager.getInstance().close(currentLoadWidgetObj.src, currentLoadWidgetObj.widget);
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
				w.removeEventListener("dragStart", this, "onDragStart");
				w.removeEventListener("closeWidget", this, "onClose");
				
				pool.object = o;
				
				w.removeMovieClip();
			}
			
			widgetDic = {};
			widgetIdDic = {};
		}
	}
		
		
	public function openByID($widget:MovieClip):MovieClip {
		if ($widget) {
			var c:MovieClip = $widget._parent;
			c.swapDepths($widget, c.getNextHighestDepth());
			
			$widget.open();
			
			focusEvt.widget = $widget;
			dispatchEvent(focusEvt);
		}			
		
		return	$widget;
	}
		
		
	public function openByID($widgetID:String):MovieClip {
		var w:MovieClip = getWidget($widgetID);
		if (w) {
			var c:MovieClip = w._parent;
			c.swapDepths(w, c.getNextHighestDepth());
			
			w.open();
			
			focusEvt.widget = w;
			dispatchEvent(focusEvt);
		}			
		
		return	w;
	}
		
		
	public function close($widget:MovieClip):MovieClip {
		if ($widget) {
			$widget.close();
		}
		
		return	$widget;
	}
		
		
	public function closeByID($widgetID:String):MovieClip {
		var w:MovieClip = getWidget($widgetID);
		if (w) {
			w.close();
		}			
		
		return	w;
	}
		
		
	public function getTopWidget($topArrange:Number):MovieClip {
		var c:MovieClip = containers[$topArrange || 0];
		return	c ? c.getInstanceAtDepth(c.getNextHighestDepth() - 1) : c;
	}
		
		
	public function getFocusWidget(focusIdx:Number):Widget {
		var p = FocusHandler.instance.getFocus(focusIdx);
		while(p){
			if(p as Widget){
				return	p;
			}
			else{
				p = p._parent;
			}
		}
		
		return	null;
	} 
		
		
	public function getWidget($widgetID:String):Widget {
		return	widgetIdDic[$widgetID];
	}
	
	
	private function onClose($e):Void {
		var w:MovieClip = $e.target;
		w.close();
		
		closeEvt.widget = w;
		dispatchEvent(closeEvt);
	}
		
		
	private function _onMouseDown($button:Number, $targetPath:String):Void {
		var w:MovieClip = targetPathToObject($targetPath);
		var c:MovieClip = w._parent;
		c.swapDepths(w, c.getNextHighestDepth());
		
		focusEvt.widget = w;
		dispatchEvent(focusEvt);
	}
		
		
	private function onDragStart($e):Void {
		dragWidget = $e.target;
		dragWidget.startDrag(false);
		
		delete	onMouseDown;
		onMouseUp = _onMouseUp;
	}
	
	
	private function _onMouseUp():Void {
		dragWidget.stopDrag();
		dragWidget = null;
		delete	onMouseUp;
		onMouseDown = _onMouseDown;
	}
}