import com.minarto.data.*;
import flash.external.ExternalInterface;


class com.minarto.data.DateBinding
{
	static private var _binding:Binding, _offsetTime:Number = 0, _dic = {};
	

	static private function _init():Void
	{
		var date:Date, intervalID:Number;
		
		_binding = BindingDic.get("__DateBinding__");
		_binding.add("serverDate", null, function($year:Number, $month:Number, $date:Number, $hour:Number, $min:Number, $sec:Number, $msec:Number):Void
			{
				var date:Date = new Date($year, $month, $date, $hour, $min, $sec, $msec);
				
				_offsetTime = date.getTime() - getTimer();
			}
		);
		
		date = new Date;
		_binding.event("serverDate", date.getFullYear(), date.getMonth(), date.getDate(), date.getHours(), date.getMinutes(), date.getSeconds(), date.getMilliseconds());
		
		DateBinding.get = function($delay:Number):DateBinding
		{
			if (!($delay > 0))	$delay = 0.1;
			return	_dic[$delay] || (_dic[$delay] = new DateBinding($delay));
		}
		
		getDate = function():Date
		{
			return	new Date(_offsetTime + getTimer());
		}
		
		init =  function($api:String):Void
		{
			var args:Array = arguments;
			
			ExternalInterface.call.apply(ExternalInterface, arguments);
			
			if(intervalID)	clearInterval(intervalID);
			intervalID = setInterval(function():Void {	ExternalInterface.call.apply(ExternalInterface, args);	}, 60000);
		}
		
		delete	_init;
	}
	

	static public function init($api:String):Void
	{
		_init();
		init.apply(DateBinding, arguments);
	}
	

	static public function get($delay:Number):DateBinding
	{
		_init();
		return	DateBinding.get($delay);
	}
	

	static public function getDate():Date
	{
		_init();
		return	getDate();
	}
	
	
	public function toString():String
	{
		return "[blueside.data.DateBinding delay:" + _delay + "sec]";
	}
	
	
	private var _delay:Number = 0.1;
	
	
	public function DateBinding($delay:Number)
	{
		var key:String, func:Function;
		
		if (!_binding)
		{
			trace("Error - don't create new instance, use DateBinding.get");
			return;
		}
		
		if (!($delay > 0))	$delay = 0.1;
		_delay = $delay;
		_dic[$delay] = this;
		
		key = "" + $delay;
		
		func = function():Void
		{
			_binding.event(key, new Date(_offsetTime + getTimer()));
		}
		
		setInterval(func, $delay * 1000);
	}
		
		
	public function add($scope, $handler:Function):Number
	{
		arguments.unshift("" + _delay);
		
		return	_binding.add.apply(_binding, arguments);
	}
	
	
	public function addPlay($scope, $handler:Function):Number
	{
		var uid:Number = add.apply(null, arguments);
		
		arguments[0] = getDate();
		$handler.apply(null, arguments);
		
		return	uid;
	}
	
	
	public function del($scope, $handler:Function, $uid:Number):Void
	{
		_binding.del("" + _delay, $scope, $handler, $uid);
	}
	
	
	public function getDelay():Number
	{
		return	_delay;
	}
}
