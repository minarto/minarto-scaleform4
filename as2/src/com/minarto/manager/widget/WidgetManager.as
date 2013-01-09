import com.minarto.controls.widget.Widget;
import com.minarto.manager.LoadSourceManager;
import com.minarto.manager.widget.*;
import flash.external.ExternalInterface;
import gfx.events.EventDispatcher;
import gfx.events.EventTypes;
import gfx.managers.FocusHandler;


class com.minarto.manager.widget.WidgetManager extends EventDispatcher {
	private static var _instance:WidgetManager = new WidgetManager;
		
		
	private var widgetDic = { }, topWidgetDic = {}, 
		dragWidget:MovieClip, 
		containers = {},
		_sources:Array = [],
		currentLoadWidgetObj, _loadID:Number, 
		focusEvt = {type:"focusWidget", target:this}, closeEvt = {type:"closeWidget", target:this};
	
	
	public function WidgetManager() {
		if (_instance)	throw new Error("don't create instance");
		
		Mouse.addListener(this);
		
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
		
		
	public function loadWidget($src:String):Void{
		var c:Number = arguments.length;
		if (c) {
			for(var i:Number=0; i<c; ++ i){
				var o = {};
				o.topArrange = 0;
				o.src = arguments[i];
				_sources.push(o);
			}
			
			if(!currentLoadWidgetObj)	_loadUI();
		}
	}
		
		
	public function loadWidgetByArrange($src:String, $topArrange:Number):Void{
		if(!$src)	return;
		
		var o = {};
		o.topArrange = $topArrange;
		o.src = $src;
		_sources.push(o);
		
		if(!currentLoadWidgetObj)	_loadUI();
	}
		
		
	public function unLoadWidget($src):void{
		if (arguments.length) {
			for(var p in arguments){
				var src:String = arguments[p];
				
				for(var i:Number=0, c:Number = _sources.length; i<c; ++ i){
					currentLoadWidgetObj = _sources[i];
					if(currentLoadWidgetObj.src == src){
						_sources.splice(i, 1);
						-- i;
					}
				}
				
				if (currentLoadWidgetObj && currentLoadWidgetObj.src == src) 	LoadSourceManager.close(src, containers[currentLoadWidgetObj.topArrange]);
			}
			
			var a:Array = widgetDic[src];
			for(p in a){
				var w:Widget = a[p];
				delWidget(w.widgetID, w);
			}
		}
		else{
			if (currentLoadWidgetObj) LoadSourceManager.close(currentLoadWidgetObj.src, containers[currentLoadWidgetObj.topArrange]);
			
			delWidget(null, null);				
			_sources.length = 0;
		}
		
		currentLoadWidgetObj = null;
	}
		
		
	private function _loadUI():Void {
		currentLoadWidgetObj = _sources.shift();
		if (currentLoadWidgetObj) {
			var c:MovieClip = containers[currentLoadWidgetObj.topArrange];
			var d:Number = c.getNextHighestDepth();
			c = c.createEmptyMovieClip("w" + d, d);
			LoadSourceManager.load(currentLoadWidgetObj.src, c, "onLoadUI", this);
		}
	}
		
		
	private function onLoadUI($widget:MovieClip):Void{
		currentLoadWidgetObj.widget = $widget;
		var id:String = $widget.widgetID;
		$widget._name = id;
		widgetDic[id] = currentLoadWidgetObj;
		
		$widget.addEventListener("dragStart", this, "onDragStart");
		$widget.addEventListener("closeWidget", this, "onClose");
		
		WidgetArrangeManager.addWidget(id, $widget);
		
		currentLoadWidgetObj = null;
		if(_sources.length)	_loadUI();
	}
		
		
	public function delWidget($widgetID:String, $widget:MovieClip):void{
		if($widgetID && $widget){
			
			$widget.destroy();
			
			$widget.removeEventListener("dragStart", this, "onDragStart");
			$widget.removeEventListener("closeWidget", this, "onClose");
			
			delete widgetDic[$widgetID];
			
			$widget.removeMovieClip();
		}
		else{
			for ($widgetID in widgetDic) {
				var o = widgetDic[$widgetID];
				
				$widget = o.widget;
				
				$widget.destroy();
				
				$widget.removeEventListener("dragStart", this, "onDragStart");
				$widget.removeEventListener("closeWidget", this, "onClose");
				
				$widget.removeMovieClip();
			}
			
			widgetDic = {};
		}
	}
		
		
	public function open($widgetID:String):MovieClip {
		var o = widgetDic[$widgetID];
		
		var w:MovieClip = getWidget($widgetID);
		if (w) {
			var container:MovieClip = w._parent;
			container.swapDepths(w, container.getNextHighestDepth());
			
			w.open();
			
			focusEvt.widget = w;
			dispatchEvent(focusEvt);
		}			
		
		return	w;
	}
		
		
	public function close($widgetID:String):MovieClip {
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
		
		
	public function getFocusWidget(focusIdx:Number):MovieClip {
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
		
		
	public function getWidget($widgetID:String):MovieClip {
		return	widgetDic[$widgetID];
	}
	
	
	private function onClose($e):Void {
		var w:MovieClip = $e.target;
		w.close();
		
		closeEvt.widget = w;
		dispatchEvent(closeEvt);
	}
		
		
	private function onMouseDown($button:Number, $targetPath:String):Void {
		var w:MovieClip = targetPathToObject($targetPath);
		var container:MovieClip = w._parent;
		container.swapDepths(w, container.getNextHighestDepth());
		
		focusEvt.widget = w;
		dispatchEvent(focusEvt);
	}
		
		
	private function onDragStart($e):Void {
		dragWidget = $e.target;
		dragWidget.startDrag(false);
		
		CLIK.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, true);
	}
	
	
	private function onMouseUp($e):Void {
		CLIK.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp, true);
		
		dragWidget.stopDrag();
		dragWidget = null;
	}
}