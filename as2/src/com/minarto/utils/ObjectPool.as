import com.minarto.utils.Util;


class com.minarto.utils.ObjectPool {
	public var constructor:Function;
	
	
	public function ObjectPool($constructor:Function, $minSize:Number) {
		init($constructor, $minSize);
	}
	
	
	private function _init():Void {
		var dic:Array = [];
		
		get = function() {
			return	dic.pop() || new constructor;
		}
		
		set = function($obj) {
			$obj = constructor($obj);
			if ($obj)	dic.push($obj);
			else throw	Util.error("ObjectPool", "constructor error - " + $obj);
		}
		
		init = function($constructor, $minSize) {
			dic.length = 0;
			constructor = $constructor;
			while ($minSize --) dic.push(new $constructor);
		}
		
		delete	_init;
	}
	
	
	public function init($constructor:Function, $minSize:Number):Void {
		_init();
		init.apply(this, arguments);
	}
	
	
	public function get():Void {
		_init();
		return	get.call(this);
	}
	
	
	public function set($obj):Void {
		_init();
		set.call(this, $obj);
	}
	
	
	public static function getPool($constructor:Function, $minSize:Number):ObjectPool {
		var dic:Array = [];
		
		getPool = function($$constructor:Function, $$minSize:Number) {
			var p:ObjectPool, i;
			
			for (i in dic) {
				p = dic[i];
				if (p.constructor == $$constructor) {
					if ($$minSize)	p.init($$constructor, $$minSize);
					return	p;
				}
			}
			
			p = new ObjectPool($$constructor, $$minSize);
			dic.push(p);
			
			return	p;
		}
		
		return	getPool($constructor, $minSize);
	}
}