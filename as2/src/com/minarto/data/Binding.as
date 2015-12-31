class com.minarto.data.Binding
{
		private var _valueDic = { }, _reservations = { }, _handlerDic = {}, _gcHandlerDic = {}, _getHandlerDic = {}, _uid:Number = 0;
	

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
	
	
	public function add($key:String, $scope, $handler:Function):Number
	{
		var dic:Array = _handlerDic[$key] || (_handlerDic[$key] = [] ), args:Array = arguments.slice(3), uid:Number = ++ _uid;
		
		args.scope = $scope;
		args.handler = $handler;
		args.uid = uid;
		
		dic.push(args);
		
		delete	_reservations[$key];
		
		return	uid;
	}
	
	
	public function addFn($key:String, $scope, $handler:Function):Number
	{
		var dic:Array = _getHandlerDic[$key] || (_getHandlerDic[$key] = [] ), uid:Number = ++ _uid;
		
		arguments.uid = uid;
		
		dic.push(arguments);
		
		return	uid;
	}
	
	
	public function addGC($key:String, $scope, $handler:Function):Number
	{
		var dic:Array = _gcHandlerDic[$key] || (_gcHandlerDic[$key] = [] ), args:Array = arguments.slice(3), uid:Number = ++ _uid;
		
		args.scope = $scope;
		args.handler = $handler;
		args.uid = uid;
		
		dic.push(args);
		
		delete	_reservations[$key];
		
		del.apply(this, arguments);
		
		return	uid;
	}
	
	
	public function addPlay($key:String, $scope, $handler:Function):Number
	{
		var args:Array = arguments.slice(3), a:Array = _reservations[$key], i:Number, l:Number = a ? a.length : 0, values:Array = _valueDic[$key], uid:Number;
		
		uid = add.apply(this, arguments);
		
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
		
		return	uid;
	}
	
	
	public function addPlayGC($key:String, $scope, $handler:Function):Number
	{
		var args:Array = arguments.slice(3), a:Array = _reservations[$key], i:Number, l:Number = a ? a.length : 0, values:Array, uid:Number;
		
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
			uid = addGC.apply(this, arguments);
		}
		
		return	uid;
	}
		
	
	public function del($key:String, $scope, $handler:Function, $uid:Number):Void
	{
		_del(_handlerDic, $key, $scope, $handler, $uid);
		_del(_gcHandlerDic, $key, $scope, $handler, $uid);
		_del(_getHandlerDic, $key, $scope, $handler, $uid);
	}
		
	
	private function _del($handlerDic, $key:String, $scope, $handler:Function, $uid:Number):Void
	{
		var dic:Array = $handlerDic[$key], i:Number, args:Array;
		
		if ($key)
		{
			if ($scope || $handler || $uid)
			{
				dic = $handlerDic[$key];
				i = dic.length;
				if ($uid)
				{
					while(i--)
					{
						args = dic[i];
						if (args.uid == $uid)
						{
							dic.splice(i, 1);
						}
					}
				}
				else if ($scope && $handler)
				{
					while(i--)
					{
						args = dic[i];
						if (args.scope == $scope && args.handler == $handler)
						{
							dic.splice(i, 1);
						}
					}
				}
				else if($handler)
				{
					while(i--)
					{
						args = dic[i];
						if (args.handler == $handler)
						{
							dic.splice(i, 1);
						}
					}
				}
				else
				{
					while(i--)
					{
						args = dic[i];
						if (args.scope == $scope)
						{
							dic.splice(i, 1);
						}
					}
				}
			}
			else
			{
				delete	$handlerDic[$key];
			}
		}
		else
		{
			if ($scope || $handler || $uid)
			{
				for ($key in $handlerDic)
				{
					dic = $handlerDic[$key];
					i = dic.length;
					if ($uid)
					{
						while(i--)
						{
							args = dic[i];
							if (args.uid == $uid)
							{
								dic.splice(i, 1);
							}
						}
					}
					else if ($scope && $handler)
					{
						while(i--)
						{
							args = dic[i];
							if (args.scope == $scope && args.handler == $handler)
							{
								dic.splice(i, 1);
							}
						}
					}
					else if($handler)
					{
						while(i--)
						{
							args = dic[i];
							if (args.handler == $handler)
							{
								dic.splice(i, 1);
							}
						}
					}
					else
					{
						while(i--)
						{
							args = dic[i];
							if (args.scope == $scope)
							{
								dic.splice(i, 1);
							}
						}
					}
				}			
			}
			else
			{
				$handlerDic = {};
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
