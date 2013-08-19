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
		
		
		add = function($id, $widget, $onComplete:Function, $scope, $onError:Function, $onErrorScope) {
			var w:MovieClip, d:Number, f0:Function, f1:Function;
			
			if (typeof($widget) == "movieclip") {
				w = WidgetManager.get($id);
				if (w != $widget)	del($id);
				w = $widget;
				w.__widgetID__ = $id;
				dic[$id] = w;
				setHandler(w);
			}
			else if (typeof($widget) == "string") {
				d = container.getNextHighestDepth();
				w = WidgetManager.get($id);
				if(w)		del($id);
				w = container.createEmptyMovieClip("w" + d, d);
				
				f0 = function() {
					w.__widgetID__ = $id;
					dic[$id] = w;
					setHandler(w);
					if ($onComplete)	$onComplete.apply($scope);
				}
				
				f1 = function() {
					w.removeMovieClip();
					if ($onError)	$onError.apply($onErrorScope);
				}
				LoadManager.load(w, $widget, f0, WidgetManager, f1, WidgetManager);
			}
			
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
	public static function add($id, $widget, $onComplete:Function, $scope, $onError:Function, $onErrorScope) {
		_init();
		return	add($id, $widget, $onComplete, $scope, $onError, $onErrorScope);
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