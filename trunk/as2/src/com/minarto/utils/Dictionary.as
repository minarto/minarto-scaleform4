import com.minarto.utils.*;


/*
 * use class after Binding.init
 */
dynamic class com.minarto.utils.Dictionary {
	private static var __count:Number = 0;
	
	
	public function Dictionary() {
		create(this);
	}
	
	
	public function setValue($target, $value):Void {}
	
	
	public function getValue($target) {}
	
	
	public static function create($dic) {
		$dic || ($dic = {});
		
		var id:Number = ++ __count;
		
		var c:Number = 0;
		
		$dic.setValue = function($target, $value):Void {
			if ($target) {
				$target = $target.__dictionary__ || ($target.__dictionary__ = { } );
				$target[id] || ($target[id] = ++ c);
				this[$target[id]] = $value;
			}
		};
		
		
		$dic.getValue = function($target) {
			$target = $target ? $target.__dictionary__ : $target;
			return	$target ? this[$target[id]] : $target;
		};
		
		return	$dic;
	}
}