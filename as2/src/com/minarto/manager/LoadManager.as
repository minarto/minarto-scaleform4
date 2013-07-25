import com.minarto.utils.Util;
import gfx.events.EventTypes;


class com.minarto.manager.LoadManager {
	private static var onLoadInit, onLoadError;
	
	
	/**
	 * 함수 초기화
	 */
	private static function _init() {
		var reservations:Array = [], loader:MovieClipLoader = new MovieClipLoader, item, _load:Function;
		
		_load = function() {
			item = reservations.shift();
			if (item)	loader.loadClip(item[1], item[0]);
			else	loader.removeListener(LoadManager);
		}
		
		onLoadInit = function() {
			var f:Function= item[2], arg;
			
			if (f) {
				arg = item.slice(5, item.length);
				arg[0] = arguments[0];
				f.apply(item[3], arg);
			}
			
			_load();
		}
		
		onLoadError = function() {
			var f:Function = item[4], arg;
			
			if (f) {
				arg = item.slice(5, item.length);
				arg[0] = arguments[0];
				f.apply(item[5], arg);
			}
			
			Util.error(EventTypes.IO_ERROR, arguments[0] + ", " + item[1]);
			
			_load();
		}
			
		unLoad = function($target:MovieClip) {
			if ($target) {
				$target.unloadMovie();
				
				if (item) {
					if (item[0] == $target)	_load();
					else {
						for (var i in reservations) {
							if (reservations[i][0] == $target) {
								reservations.splice(i, 1);
								return;
							}
						}
					}
				}
			}
			else	reservations.length = 0;
		}
		
		load = function($target:MovieClip) {
			if (item) {
				if (item[0] == $target) {
					$target.unloadMovie();
					item = null;
				}
				else {
					for (var i in reservations) {
						if (reservations[i][0] == $target) {
							reservations.splice(i, 1);
							break;
						}
					}
				}
			}
			
			reservations.push(arguments);
			if (!item) {
				loader.addListener(LoadManager);
				_load();
			}
		}
		
		delete	_init;
	}
	
	
	/**
	 * 모든 예약된 로드 취소
	 */
	public static function unLoad($target:MovieClip):Void {
		_init();
		unLoad($target);
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