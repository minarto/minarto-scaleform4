import com.minarto.data.*;


class com.minarto.data.DateBinding
{
	static private var _offsetTime:Number, _uid:Number = 0;
	
	
	static private function _getOffsetTime():Number
	{
		var binding:Binding, date:Date;
		
		if (isNaN(_offsetTime))
		{
			binding = BindingDic.get("__DateBinding__");
			binding.add("offsetTime", DateBinding, function($offsetTime:Number):Void
				{
					_offsetTime = $offsetTime;
				}
			);
			binding.add("serverDate", null, function($year:Number, $month:Number, $date:Number, $hour:Number, $min:Number, $sec:Number, $msec:Number):Void
				{
					var date:Date = new Date($year, $month, $date, $hour, $min, $sec, $msec);
					
					binding.set("offsetTime", date.getTime() - getTimer());
				}
			);
			
			date = new Date;
			binding.event("serverDate", date.getFullYear(), date.getMonth(), date.getDate(), date.getHours(), date.getMinutes(), date.getSeconds(), date.getMilliseconds());
		}
		
		return	_offsetTime;
	}
	

	static public function getDate():Date
	{
		return	new Date(_getOffsetTime() + getTimer());
	}
	
	
	public function toString():String
	{
		return "[blueside.data.DateBinding1 delay:" + _delay + "sec]";
	}
	
	
	private var _binding:Binding, _delay:Number = 0.1, _intervalID:Number, _bindingKey:String;
	
	
	public function DateBinding($delay:Number)
	{
		if (!($delay > 0))	$delay = 0.1;
		_delay = $delay;
		
		_getOffsetTime();
		
		_bindingKey = "" + (_uid ++);
		_binding = BindingDic.get("__DateBinding__");
	}
		
		
	public function play():Void
	{
		_intervalID = setInterval(function ($binding:Binding, $key:String):Void
			{
				$binding.event($key, new Date(_offsetTime + getTimer()));
			}
			, _delay * 1000, _binding, _bindingKey
		);
	}
		
		
	public function stop():Void
	{
		clearInterval(_intervalID);
		_intervalID = NaN;
	}
		
		
	public function add($scope, $handler:Function):Number
	{
		arguments.unshift(_bindingKey);
		
		return	_binding.add.apply(_binding, arguments);
	}
	
	
	public function addPlay($scope, $handler:Function):Number
	{
		var uid:Number = add.apply(this, arguments), args:Array = arguments.slice(1);
		
		args[0] = getDate();
		$handler.apply($scope, args);
		
		return	uid;
	}
	
	
	public function del($scope, $handler:Function, $uid:Number):Void
	{
		_binding.del(_bindingKey, $scope, $handler, $uid);
	}
	
	
	public function getDelay():Number
	{
		return	_delay;
	}
	
	
	public function getIsPlaying():Boolean
	{
		return	Boolean(_intervalID);
	}
}
