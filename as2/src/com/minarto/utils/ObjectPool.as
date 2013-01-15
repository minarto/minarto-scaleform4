class com.minarto.utils.ObjectPool {
	private var _dic:Array = [],
				_constructor:Function, _currSize:Number = 0;
	
	
	public function ObjectPool($size:Number, $constructor:Function) {
		allocate($size, $constructor);
	}
	
	
	public function allocate($size:Number, $constructor:Function):Void {
		deconstruct();
		
		_constructor = $constructor;
		
		while ($size --) {
			_currSize = _dic.push(new $constructor);
		}
	}
	
	
	public get function object() {
		if (_dic.length) {
			return	_dic.pop();
		}
		else {
			return	new _constructor;
		}
	}
	
	
	public get function object($obj):Void {
		_currSize = _dic.push($obj);
	}
	
	
	public function deconstruct():Void {
		purge();
		_constructor = null;
	}
	
	
	public function get size():Number {
		return _currSize;
	}
	
	
	public function initialze(func:String, args:Array):Void {
		for (var i in _dic) {
			_dic[i][func].apply(n.data, args);
		}
	}
	
	
	public function purge():Void {
		_dic.length = _currSize = 0;
	}
}