import com.minarto.manager.*;

class com.minarto.manager.ImageManager {
	public static function load($src:String, $target:MovieClip, $onComplete:Function, $scope):Void {
		LoadSourceManager.load("img://" + $src, $target, $onComplete, $scope);
	}
}