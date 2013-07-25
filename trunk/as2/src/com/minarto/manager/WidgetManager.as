import com.minarto.manager.LoadManager;
import gfx.events.EventTypes;


class com.minarto.manager.WidgetManager extends EventDispatcher {
	private static var onMouseDown:Function, onMouseUp:Function, onDragStart:Function, onClose:Function;
		
		
	private static function _init() {
		var dic = { }, _onMouseUp:Function, dragWidget:MovieClip, container:MovieClip;
		
		Mouse.addListener(WidgetManager);
		
		init = function() {
			container = arguments[0];
		}
		
		
		load = function($src:String) {
			var widget:MovieClip, d:Number = container.getNextHighestDepth(), onComplete:Function, f:Function = arguments[1], s = arguments[2];
			
			onComplete = function() {
				widget.__src__ = $src;
				if (f)	f.apply(s);
			}
			
			widget = container.createEmptyMovieClip("m" + d, d);
			
			LoadManager.load(widget, $src, onComplete, WidgetManager);
			dic[$src] = widget;
		}
		
		
		add = function($id, $widget:MovieClip) {
			$widget.id = $id;
			
			dic[$id] = $widget;
			
			if ($widget.addEventListener) {
				$widget.addEventListener(EventTypes.DRAG_BEGIN, this, "onDragStart");
				$widget.addEventListener("closeWidget", this, "onClose");
			}
		}
		
		
		del = function($id) {
			var w:MovieClip, i, src:String;
			
			if ($id) {
				for (i in arguments) {
					w = dic[arguments[i]];
					if (w) {
						$id = w.id;
						src = w.__src__;
						
						delete	dic[$id];
						delete	dic[src];
						
						if(w.removeAllEventListeners)	w.removeAllEventListeners();
						LoadManager.unLoad(w);
						w.removeMovieClip();
					}
				}
			}
			else {
				for ($id in dic) {
					w = dic[$id];
					if (w) {
						if(w.removeAllEventListeners)	w.removeAllEventListeners();
						LoadManager.unLoad(w);
						w.removeMovieClip();
					}					
				}
				dic = { };
			}
		}
		
		
		onMouseDown = function() {
			var c:MovieClip, w:MovieClip;
			
			c = container;
			w = eval(arguments[1]);
			while (w) {
				if (w._parent == c) {
					w.swapDepths(c.getNextHighestDepth());
					return;
				}
				w = w._parent;
			}
		}
		
		
		onDragStart = function() {
			dragWidget = arguments[0].target;
			dragWidget.hitTestDisable = true;
			dragWidget.startDrag();
			
			onMouseUp = _onMouseUp;
		}
		
		
		_onMouseUp = function() {
			dragWidget.hitTestDisable = false;
			dragWidget.stopDrag();
			
			delete	onMouseUp;
		}
		
		
		get = function($id) {
			return	dic[$id];
		}
		
		
		open = function() {
			var w:MovieClip = dic[arguments[0]];
			if (w) {
				w._x = arguments[1];
				w._y = arguments[2];
				if (w.open)	w.open();
				else	w._visible = true;
			}
		}
		
		close = function($id):Void {
			var w:MovieClip;
			
			if ($id) {
				w = dic[$id];
				if (w) {
					if (w.close)	w.close();
					else	w._visible = false;
				}
			}
			else {
				for ($id in dic) {
					w = dic[$id];
					if (w.close)	w.close();
					else	w._visible = false;
				}
			}
		}
		
		
		onClose = function():Void {
			var w:MovieClip = arguments[0].target, id;
			
			for (id in dic) {
				if (dic[id] == w) {
					close(w.id);
					return;
				}
			}
		}
	}
	
	
	/**
	 * 
	 */
	public static function init($container:MovieClip):Void {
		_init();
		init.apply(WidgetManager, arguments);
	}
	
	
	/**
	 * 
	 */
	public static function load($src:String, $onComplete:Function, $scope):Void {
		_init();
		load.apply(WidgetManager, arguments);
	}
	
	
	/**
	 * 
	 */
	public static function add($id, $widget:MovieClip):Void {
		_init();
		add.apply(WidgetManager, arguments);
	}
	
	
	public static function del($id):Void {
		_init();
		del.apply(WidgetManager, arguments);
	}
	
	
	public static function get($id):MovieClip {
		_init();
		return	get($id);
	}
	
	
	public static function open($id, $x:Number, $y:Number):Void {
		_init();
		open.apply(WidgetManager, arguments);
	}
	
	
	public static function close($id):Void {
		_init();
		close(WidgetManager, arguments);
	}
}