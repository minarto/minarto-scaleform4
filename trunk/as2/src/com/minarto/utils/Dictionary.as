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
				var dic = $target.__dictionary__ || ($target.__dictionary__ = { } );
				dic[id] || (dic[id] = ++ c);
				this[dic[id]] = $value;
			}
		};
		
		
		$dic.getValue = function($target) {
			if ($target) {
				var dic = $target ? $target.__dictionary__ : $target;
				return	dic ? this[dic[id]] : dic;
			}
			return	$target;
		};
		
		return	$dic;
	}
}