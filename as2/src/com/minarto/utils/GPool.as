class com.minarto.utils.GPool {
	private static var _dic:Array = [];
	
	
	static public function addPool($constructor:Function, $size:Number):ObjectPool {
		return	_searchPool($constructor) || _createPool($constructor, $size || 1);
	}
	
	
	static private function _createPool($constructor:Function, $size:Number):ObjectPool {
		var p:ObjectPool = new ObjectPool($size, $constructor);
		_dic.push( { c:$constructor, p:p } );
		
		return	p;
	}
	
	
	static private function _searchPool($constructor:Function):ObjectPool {
		var i:Number = _dic.length;
		while (i --) {
			var o = _dic[i];
			if (o.c === $constructor) {
				return	o.p;
			}
		}
		
		return	null;
	}
	
	
	static public function getPool($constructor:Function):ObjectPool {
		return	_searchPool($constructor) || _createPool($constructor, 1);
	}
	
	
	static public function delPool($constructor:Function):Void {
		var i:Number = _dic.length;
		while (i --) {
			var o = _dic[i];
			if (o.c === $constructor) {
				o.p.deconstruct();
				_dic.splice(i, 1);
				return;
			}
		}
	}
}