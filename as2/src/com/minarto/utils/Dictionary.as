import com.minarto.utils.*;


/*
 * use class after Binding.init
 */
dynamic class com.minarto.utils.Dictionary {
	private static var __id = { }, __count:Number = 0;
	
	
	public function Dictionary() {
		var c:Number = 0;
		var id:Number = ++ __count;
		
		var f:Function = function($target, $value):Void {
			if ($target) {
				var d = $target.__dictionary__ || ($target.__dictionary__ = {});
				if (!d[id]) 	d[id] = ++ c;
				this[c] = $value;
			}
		}
		
		Dictionary.prototype.addDic = f;
		
		
		f = function():Number {
			return	id;
		}
		
		Dictionary.prototype.__getDicID__ = f;
	}
		
		
	public function addDic($target, $value):Void {}
	
	
	public function getDic($target) {
		if ($target) {
			var d = $target.__dictionary__;
			return	d ? this[d[__getDicID__()]] : d;
		}
		return	d;
	}
	
	
	private function __getDicID__() {}
}