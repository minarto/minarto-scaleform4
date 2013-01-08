import com.minarto.manager.*;
import gfx.events.EventTypes;


class com.minarto.manager.LoadSourceManager {
	private static var _reservations:Array = [], _loader:MovieClipLoader = new MovieClipLoader, _instance:LoadSourceManager = new LoadSourceManager;
	
	
	public function LoadSourceManager() {
		if(_instance)	throw	new Error("don't create instance");
		_loader.addListener(this);
	}
	
	
	public static function load($src:String, $target:MovieClip, $onComplete:String, $scope:Object):Void {
		if(arguments.length < 2)	return;
		_reservations.push($src, $target, $onComplete, $scope);
		_load();
	}
	
	
	private static function _load() {
		_loader.loadClip(_reservations[0], _reservations[1]);
	}
	
	
	private function onLoadComplete($content):Void {
		_reservations[3][_reservations[2]]($content);
		_reservations.splice(0, 4);
		
		if(_reservations.length > 3)	_load();
	}
	
	
	private function onLoadError($content):Void {
		DebugManager.error(EventTypes.IO_ERROR, _reservations[0]);
		_reservations.splice(0, 4);
		
		if(_reservations.length > 3)	_load();
	}
		
		
	public static function close($src:String, $target:MovieClip):Void{
		if(arguments.length < 2)	return;
		
		for (var i:Number = 0, c:Number = _reservations.length; i < c; i+= 4) {
			if ($src == _reservations[i] && $target == _reservations[i + 1]) {
				if (i == 0) {
					_loader.unloadClip(_reservations[1]);
				}
				_reservations.splice(i, 4);
				return;
			}
		}
	}
}