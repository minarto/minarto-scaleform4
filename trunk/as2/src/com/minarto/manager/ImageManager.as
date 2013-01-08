import com.minarto.manager.*;

class com.minarto.manager.ImageManager {
	public static function load($src:String, $target:MovieClip, $onComplete:String, $scope:Object):Void {
		LoadSourceManager.load("img://" + $src, $target, $onComplete, $scope);
	}
}