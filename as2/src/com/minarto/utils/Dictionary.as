dynamic class com.minarto.utils.Dictionary {
	private static var globalCount:Number = 0;
	
	
	public function Dictionary() {
		var id:Number, c:Number;
		
		id = ++ globalCount;
		c = 0;
		
		set = function($target, $value):Void {
			if ($target) {
				$target = $target.__dictionary__ || ($target.__dictionary__ = { } );
				$target[id] || ($target[id] = ++ c);
				this[$target[id]] = arguments.length > 1 ? $value : $target;
			}
		};
		
		
		get = function($target) {
			$target = $target ? $target.__dictionary__ : $target;
			return	$target ? this[$target[id]] : $target;
		};
	}
	
	
	public function set($target, $value):Void {}
	
	
	public function get($target) {}
}