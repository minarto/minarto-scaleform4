import com.minarto.manager.LoadManager;
import gfx.events.EventTypes;


class com.minarto.manager.WidgetManager extends EventDispatcher {
	private static var onMouseDown:Function, onMouseUp:Function, onDragStart:Function, onClose:Function;
		
		
	private static function _init() {
		var dic = { }, _onMouseUp:Function, dragWidget:MovieClip, container:MovieClip, setHandler:Function;
		
		Mouse.addListener(WidgetManager);
		
		init = function() {
			container = arguments[0];
		}
		
		
		setHandler = function($widget:MovieClip) {
			$widget.addEventListener(EventTypes.DRAG_BEGIN, this, "onDragStart");
			$widget.addEventListener(EventTypes.HIDE, this, "onClose");
		}
		
		
		add = function($id, $widget, $onComplete:Function, $scope) {
			var w:MovieClip, d:Number, f:Function;
			
			if (typeof($widget) == "movieclip") {
				w = $widget;
				w.widgetID = $id;
				setHandler(w);
			}
			else if (typeof($widget) == "string") {
				d = container.getNextHighestDepth();
				
				w = container.attachMovie($widget, "w" + d, d);
				if (w) {
					w.widgetID = $id;
					setHandler(w);
				}
				else {
					w = container.createEmptyMovieClip("w" + d, d);
					
					f = function() {
						w.widgetID = $id;
						setHandler(w);
						if ($onComplete)	$onComplete.apply($scope);
					}
					LoadManager.load(w, $widget, f, WidgetManager, f, WidgetManager);
				}
			}
			
			dic[$id] = w;
			
			return	w;
		}
		
		
		del = function($id) {
			var w:MovieClip;
			
			if ($id) {
				if (typeof($id) == "movieclip") {
					w = $id;
					
					if(w.destroy)	w.destroy();
					else if(w.removeAllEventListeners)	w.removeAllEventListeners();
					w.unloadMovie();
					w.removeMovieClip();
					
					delete	dic[w.widgetID];
				}
				else {
					w = dic[$id];
					if (w) {
						if(w.destroy)	w.destroy();
						else if(w.removeAllEventListeners)	w.removeAllEventListeners();
						w.unloadMovie();
						w.removeMovieClip();
						
						delete	dic[$id];
					}
				}				
			}
			else {
				for ($id in dic) {
					w = dic[$id];
					
					if(w.removeAllEventListeners)	w.removeAllEventListeners();
					w.unloadMovie();
					w.removeMovieClip();
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
	public static function add($id, $widget, $onComplete:Function, $scope) {
		_init();
		return	add.apply(WidgetManager, arguments);
	}
	
	
	public static function del($id):Void {
		_init();
		del.apply(WidgetManager, arguments);
	}
	
	
	public static function get($id):MovieClip {
		_init();
		return	get($id);
	}
	
	
	public static function open($id):Void {
		_init();
		open($id);
	}
	
	
	public static function close($id):Void {
		_init();
		close($id);
	}
}