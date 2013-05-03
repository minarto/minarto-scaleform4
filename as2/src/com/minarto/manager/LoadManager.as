import gfx.events.EventTypes;


class com.minarto.manager.LoadManager {
	private static var onLoadInit, onLoadError;
	
	
	public static function load($target:MovieClip, $src:String, $onComplete:Function, $scope):Void {
		private static var onLoadInit, onLoadError;
	
	
	public static function load($target:MovieClip, $src:String, $onComplete:Function, $scope):Void {
		var reservations:Array, loader:MovieClipLoader, item, _load:Function;
		
		reservations = [arguments];
		
		loader = new MovieClipLoader;
		loader.addListener(LoadManager);
		
		_load = function() {
			item = reservations.shift();
			if (item)	loader.loadClip(item[1], item[0]);
		}
		
		onLoadInit = function() {
			item[2].apply(item[3], [arguments[0], item.slice(4, item.length)]);
			_load();
		}
		
		onLoadError = function() {
			Util.error(EventTypes.IO_ERROR, arguments[0] + ", " + item[1]);
			_load();
		}
		
		load = function() {
			if (item) reservations.push(arguments);
			else _load();
		}
		
		load($target, $src, $onComplete, $scope);
	}
}