import com.minarto.manager.LoadManager;
import gfx.events.EventTypes;


class com.minarto.manager.WidgetManager extends EventDispatcher {
	private static var onMouseDown:Function, onMouseUp:Function, onDragStart:Function, onClose:Function;
		
		
	private static function _init() {
		var dic = { }, _onMouseUp:Function, dragWidget:MovieClip, container:MovieClip, setHandler:Function;
		
		Mouse.addListener(WidgetManager);
		
		init = function($container:MovieClip):MovieClip {
			if ($container)	container = $container;
			return	container;
		}
		
		
		setHandler = function($widget:MovieClip) {
			$widget.addEventListener(EventTypes.DRAG_BEGIN, this, "onDragStart");
		}
		
		
		add = function($id, $widget, $onComplete:Function, $scope, $onError:Function, $onErrorScope) {
			var w:MovieClip, d:Number, f0:Function, f1:Function;
			
			if (typeof($widget) == "movieclip") {
				w = WidgetManager.get($id);
				if (w != $widget)	del(w);
				w = $widget;
				w.__widgetID__ = $id;
				dic[$id] = w;
				setHandler(w);
			}
			else if (typeof($widget) == "string") {
				d = container.getNextHighestDepth();
				w = WidgetManager.get($id);
				if(w)	del(w);
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
					w = WidgetManager.get($id);
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
					w = WidgetManager.get($id);
					
					if(w.removeAllEventListeners)	w.removeAllEventListeners();
					w.unloadMovie();
					w.removeMovieClip();
				}
				dic = { };
			}
		}
		
		
		onMouseDown = function() {
			var w:MovieClip = eval(arguments[1]);
			
			while (w) {
				if (w._parent == container) {
					setIndex(w, - 1);
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
		
		
		WidgetManager.get = function($id) {
			return	dic[$id];
		}
		
		setIndex($id, $index:Number):MovieClip {
			var w:MovieClip = (typeof($widget) == "movieclip") ? $widget : WidgetManager.get($widget);
			
			if (w) {
				if ($index < 0)	$index = container.getNextHighestDepth() - 1;
				w.swapDepths($index);
			}
			
			return	w;
		}
	}
	
	
	/**
	 * 
	 */
	public static function init($container:MovieClip):MovieClip {
		_init();
		return	init($container);
	}
	
	
	/**
	 * 
	 */
	public static function add($id, $widget, $onComplete:Function, $scope, $onError:Function, $onErrorScope):MovieClip {
		_init();
		return	add($id, $widget, $onComplete, $scope, $onError, $onErrorScope);
	}
	
	
	public static function del($id):Void {
		_init();
		del.apply(WidgetManager, arguments);
	}
	
	
	public static function get($id):MovieClip {
		_init();
		return	WidgetManager.get($id);
	}
	
	
	public static function setIndex($widget, $index:Number):MovieClip {
		_init();
		return	setIndex($widget, $index);
	}
}