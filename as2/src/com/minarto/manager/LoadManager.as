import com.minarto.utils.Util;
import gfx.events.EventTypes;


class com.minarto.manager.LoadManager {
	private static var onLoadInit, onLoadError;
	
	
	/**
	 * 함수 초기화
	 */
	private static function _init() {
		var reservations:Array, loader:MovieClipLoader, item, _load:Function;
		
		reservations = [];
		loader = new MovieClipLoader;
		loader.addListener(LoadManager);
		
		_load = function() {
			item = reservations.shift();
			if (item) loader.loadClip(item[1], item[0]);
		}
		
		onLoadInit = function() {
			var f:Function, arg;
			
			f = item[2];
			
			if (f) {
				arg = item.slice(5, item.length);
				arg[0] = arguments[0];
				f.apply(item[3], arg);
			}
			
			_load();
		}
		
		onLoadError = function() {
			var f:Function, arg;
			
			f = item[4];
			if (f) {
				arg = item.slice(5, item.length);
				arg[0] = arguments[0];
				f.apply(item[5], arg);
			}
			
			Util.error(EventTypes.IO_ERROR, arguments[0] + ", " + item[1]);
			
			_load();
		}
			
		clear = function() {
			reservations.length = 0;
			if (item) {
				loader.unloadClip(item[0]);
				item = null;
			}
		}
		
		load = function() {
			reservations.push(arguments); 
			if (!item) _load();
		}
		
		delete	_init;
	}
	
	
	/**
	 * 모든 예약된 로드 취소
	 */
	public static function clear():Void {
		_init();
		clear.apply(LoadManager, arguments);
	}
	
	
	/**
	 * 로드
	 * 
	 * @param	$target
	 * @param	$src
	 * @param	$onComplete
	 * @param	$onCompleteScope
	 * @param	$onError
	 * @param	$onErrorScope
	 * 
	 * $onErrorScope 뒤쪽부터 추가인자 넣을 수 있음
	 */
	public static function load($target:MovieClip, $src:String, $onComplete:Function, $onCompleteScope, $onError:Function, $onErrorScope):Void {
		_init();
		load.apply(LoadManager, arguments);
	}
}