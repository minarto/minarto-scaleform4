import com.minarto.utils.*;


/*
 * use class after Binding.init
 */
dynamic class com.minarto.utils.Dictionary {
	public function Dictionary() {
		var c:Number = 0;
		
		var f:Function = function($target, $value):Void {
			if (!$target.__dictionary__) 	$target.__dictionary__ = ++ c;
			this[c] = $value;
		}
		
		Dictionary.prototype.addDic = f;
	}
		
		
	public function addDic($target, $value):Void {}
	
	
	public function getDic($target) {
		return	$target ? this[$target.__dictionary__] : undefined;
	}
}