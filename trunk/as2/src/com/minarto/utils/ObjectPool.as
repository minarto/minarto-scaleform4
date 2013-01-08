class com.minarto.utils.ObjectPool {
	private var _dic:Array = [],
				_constructor:Function;
	
	
	public function ObjectPool($size:Number, $constructor:Function) {
		allocate($size, $constructor);
	}
	
	
	public function allocate($size:Number, $constructor:Function):Void {
		deconstruct();
		
		_constructor = $constructor;
		
		for (var i:Number = 0; i < $size; i++ ) {
			_dic.push(new $constructor);
		}
	}
	
	
	public function getObj() {
		if (_dic.length) {
			return	_dic.pop();
		}
		else {
			return	new _constructor;
		}
	}
	
	
	public function returnObj($obj):Void {
		_dic.push($obj);
	}
	
	
	public function deconstruct():Void {
		_dic.length = 0;
		_constructor = null;
	}
}