import com.minarto.utils.Util;


class com.minarto.utils.ObjectPool {
	public var get:Function, set:Function, constructor:Function;
	
	
	public function ObjectPool($constructor:Function, $minSize:Number, $initFunc:Function) {
		init($constructor, $minSize, $initFunc);
	}
	
	
	public function init($constructor:Function, $minSize:Number, $initFunc:Function):Void {
		var dic:Array, initFunc:Function, const:Function;
		
		dic = [];
		
		get = function() {
			return	dic.pop() || new const;
		}
		
		set = function($obj) {
			$obj = const($obj);
			if ($obj) {
				if (initFunc)	initFunc.call($obj);
				dic.push($obj);
			}
			else {
				throw	Util.error("ObjectPool", "constructor error - " + $obj);
			}
		}
		
		init = function($constructor, $minSize, $initFunc) {
			dic.length = $minSize = $minSize || 1;
			constructor = const = $constructor;
			initFunc = $initFunc;
		
			while ($minSize --) dic[$minSize] = new $constructor;
		}
		
		init($constructor, $minSize, $initFunc);
	}
	
	
	public static function getPool($constructor:Function, $minSize:Number, $initFunc:Function):ObjectPool {
		var dic:Array = [];
		
		getPool = function($constructor:Function, $minSize:Number, $initFunc:Function):ObjectPool {
			var p:ObjectPool, i;
			
			for (i in dic) {
				p = dic[i];
				if (p.constructor === $constructor)	return	p;
			}
			
			p = new ObjectPool($constructor, $minSize, $initFunc);
			dic.push(p);
			
			return	p;
		}
		
		return	getPool($constructor, $minSize, $initFunc);
	}
}