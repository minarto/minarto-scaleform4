class com.minarto.data.Binding
{
	private var _valueDic = { }, _reservations = { }, _handlerDic = {}, _gcHandlerDic = {}, _getHandlerDic = {};
	

	public function set($key, $value):Void
	{
		var values:Array = arguments.slice(1), dic:Array = _handlerDic[$key], i, a:Array;
		
		_valueDic[$key] = values;
		
		for(i in dic)
		{
			_set($key, values);
			return;
		}
		
		dic = _gcHandlerDic[$key];
		for(i in dic)
		{
			_set($key, values);
			return;
		}
		
		a = _reservations[$key] || (_reservations[$key] = [])
		a.push(values);
	}
	

	public function event($key, $value):Void
	{
		var values:Array = arguments.slice(1), dic:Array = _handlerDic[$key], i, a:Array;
		
		for(i in dic)
		{
			_set($key, values);
			return;
		}
		
		dic = _gcHandlerDic[$key];
		for(i in dic)
		{
			_set($key, values);
			return;
		}
		
		a = _reservations[$key] || (_reservations[$key] = [])
		a.push(values);
	}
		
		
	private function _set($key:String, $values:Array):Void
	{
		var dic:Array = _handlerDic[$key], i, args:Array, func:Function;
			
		for(i in dic)
		{
			args = dic[i];
			func = args.handler;
			func.apply(args.scope, $values.concat(args));
		}
		
		dic = _gcHandlerDic[$key];
		for(i in dic)
		{
			args = dic[i];
			func = args.handler;
			func.apply(args.scope, $values.concat(args));
		}
		
		delete	_gcHandlerDic[$key];
	}
	
	
	public function add($key:String, $scope, $handler:Function):Void
	{
		var dic:Array = _handlerDic[$key] || (_handlerDic[$key] = [] ), args:Array = arguments.slice(3);
		
		args.scope = $scope;
		args.handler = $handler;
		
		dic.push(args);
		
		delete	_reservations[$key];
	}
	
	
	public function addFn($key:String, $scope, $handler:Function):Void
	{
		var dic:Array = _getHandlerDic[$key] || (_getHandlerDic[$key] = [] );
		
		dic.push(arguments);
	}
	
	
	public function addGC($key:String, $scope, $handler:Function):Void
	{
		var dic:Array = _gcHandlerDic[$key] || (_gcHandlerDic[$key] = [] ), args:Array = arguments.slice(3);
		
		args.scope = $scope;
		args.handler = $handler;
		
		dic.push(args);
		
		delete	_reservations[$key];
		
		del.apply(this, arguments);
	}
	
	
	public function addPlay($key:String, $scope, $handler:Function):Void
	{
		var args:Array = arguments.slice(3), a:Array = _reservations[$key], i:Number, l:Number = a ? a.length : 0, values:Array = _valueDic[$key];
		
		add.apply(this, arguments);
		
		if (l)
		{
			for (i = 0; i < l; ++i)
			{
				values = a[i];
				$handler.apply($scope, values.concat(args));
			}
			
			delete	_reservations[$key];
		}
		else if(values)
		{
			$handler.apply($scope, values.concat(args));
		}
	}
	
	
	public function addPlayGC($key:String, $scope, $handler:Function):Void
	{
		var args:Array = arguments.slice(3), a:Array = _reservations[$key], i:Number, l:Number = a ? a.length : 0, values:Array;
		
		if (l)
		{
			for (i = 0; i < l; ++i)
			{
				values = a[i];
				$handler.apply($scope, values.concat(args));
			}
			
			delete	_reservations[$key];
		}
		else if(values)
		{
			values = _valueDic[$key];
			$handler.apply($scope, values.concat(args));
		}
		else
		{
			addGC.apply(this, arguments);
		}
	}
		
	
	public function del($key:String, $scope, $handler:Function):Void
	{
		var dic:Array = _handlerDic[$key], i, args:Array;
		
		if ($key)
		{
			if ($scope || $handler)
			{
				dic = _handlerDic[$key];
				if ($scope && $handler)
				{
					for(i in dic)
					{
						args = dic[i];
						if (args.scope == $scope && args.handler == $handler)
						{
							delete	dic[i];
						}
					}
				}
				else if($handler)
				{
					for(i in dic)
					{
						args = dic[i];
						if (args.handler == $handler)
						{
							delete	dic[i];
						}
					}
				}
				else
				{
					for(i in dic)
					{
						args = dic[i];
						if (args.scope == $scope)
						{
							delete	dic[i];
						}
					}
				}
			}
			else
			{
				delete	_handlerDic[$key];
			}
		}
		else
		{
			if ($scope || $handler)
			{
				for ($key in _handlerDic)
				{
					dic = _handlerDic[$key];
					if ($scope && $handler)
					{
						for(i in dic)
						{
							args = dic[i];
							if (args.scope == $scope && args.handler == $handler)
							{
								delete	dic[i];
							}
						}
					}
					else if($handler)
					{
						for(i in dic)
						{
							args = dic[i];
							if (args.handler == $handler)
							{
								delete	dic[i];
							}
						}
					}
					else
					{
						for(i in dic)
						{
							args = dic[i];
							if (args.scope == $scope)
							{
								delete	dic[i];
							}
						}
					}
				}			
			}
			else
			{
				_handlerDic = {};
			}
		}		
	}
		
		
	public function getAt($key:String, $index:Number)
	{
		var values:Array = _valueDic[$key];
		
		return	values ? values[$index || 0] : undefined;
	}
		
		
	public function get($key:String):Array
	{
		return	_valueDic[$key];
	}
}
