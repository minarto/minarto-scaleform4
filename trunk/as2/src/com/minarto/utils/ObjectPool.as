import com.minarto.utils.Util;


class com.minarto.utils.ObjectPool {
	public var get:Function, set:Function, constructor:Function;
	
	
	public function ObjectPool($constructor:Function, $minSize:Number, $initFunc:Function) {
		init($constructor, $minSize, $initFunc);
	}
	
	
	public function init($constructor:Function, $minSize:Number, $initFunc:Function):Void {
		var dic:Array = [];
		
		get = function() {
			return	dic.pop() || new $constructor;
		}
		
		set = function($obj) {
			$obj = $constructor($obj);
			if ($obj) {
				if ($initFunc)	$initFunc.call($obj);
				dic.push($obj);
			}
			else throw	Util.error("ObjectPool", "constructor error - " + $obj);
		}
		
		init = function($$constructor, $$minSize, $$initFunc) {
			dic.length = $minSize = $$minSize = $$minSize || 1;
			constructor = $constructor = $$constructor;
			$initFunc = $$initFunc;
		
			while ($$minSize --) dic[$$minSize] = new $$constructor;
		}
		
		init($constructor, $minSize, $initFunc);
	}
	
	
	public static function getPool($constructor:Function, $minSize:Number, $initFunc:Function):ObjectPool {
		var dic:Array = [];
		
		getPool = function($$constructor:Function) {
			var p:ObjectPool, i;
			
			for (i in dic) {
				p = dic[i];
				if (p.constructor === $$constructor)	return	p;
			}
			
			p = new ObjectPool($$constructor, arguments[1], arguments[2]);
			dic.push(p);
			
			return	p;
		}
		
		return	getPool($constructor, $minSize, $initFunc);
	}
}