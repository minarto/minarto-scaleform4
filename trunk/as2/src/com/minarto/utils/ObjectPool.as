import com.minarto.utils.Utils;


class com.minarto.utils.ObjectPool {
	public var constructor:Function;
	
	
	public function ObjectPool($constructor:Function, $minSize:Number) {
		var dic:Array = [];
		
		get = function() {
			return	dic.pop() || new constructor;
		}
		
		set = function($obj) {
			if (constructor($obj))	dic.push($obj);
			else throw	Utils.error("ObjectPool", "constructor error:" + $obj);
		}
		
		constructor = $constructor;
		while ($minSize --) dic.push(new $constructor);
	}
	
	
	public function get() {}
	
	
	public function set($obj):Void {}
	
	
	public static function getPool($constructor:Function, $minSize:Number):ObjectPool {
		var dic:Array = [];
		
		getPool = function($constructor:Function, $minSize:Number) {
			var p:ObjectPool, i;
			
			for (i in dic) {
				p = dic[i];
				if (p.constructor == $constructor)	return	p;
			}
			
			p = new ObjectPool($constructor, $minSize);
			dic.push(p);
			
			return	p;
		}
		
		return	getPool($constructor, $minSize);
	}
}