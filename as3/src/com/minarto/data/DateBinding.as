package com.minarto.data
{
	import flash.utils.*;
	

	public class DateBinding
	{
		static private const _binding:Binding = new Binding;
		
		
		static private var _offsetTime:Number, _uid:uint;
		
		
		static private function _getOffsetTime():Number
		{
			if(isNaN(_offsetTime))
			{
				var date:Date;
				
				var onTime:Function = function($year:uint, $month:uint, $date:uint, $hour:uint, $sec:uint, $millisec:uint=0):void
				{
					var date:Date = new Date($year, $month, $date, $hour, $sec, $millisec);
					
					_offsetTime = date.time - getTimer();
				};
				
				_binding.add("serverDate", onTime);
				
				date = new Date;
				_binding.event("serverDate", date.fullYear, date.month, date.date, date.hours, date.minutes, date.seconds, date.milliseconds);
			}
			
			return	_offsetTime;
		}
		
		
		static public function getDate($delay:Number=0.1):Date
		{
			return	new Date(_getOffsetTime() + getTimer());
		}
		
		
		public function toString():String
		{
			return	"[com.minarto.data.DateBinding interval:" + getInterval() + "sec]"
		}
		
		
		private var _interval:uint = 100, _bindingKey:String, _intervalID:Number;
		
		
		public function DateBinding($interval:Number=0.1)
		{
			_interval = $interval * 1000;
			_bindingKey = "" + (++ _uid);
		}
		
		
		/**
		 * 
		 */		
		private function _intervalFunc($binding:Binding, $key:String):void
		{
			_binding.event($key, new Date(_offsetTime + getTimer()));
		}
		
		
		/**
		 * 알람 등록 
		 * 
		 */		
		public function play():void
		{
			_getOffsetTime();
			_intervalID = setInterval(_intervalFunc, _interval, _binding, _bindingKey);
		}
		
		
		/**
		 * 알람 등록 
		 * 
		 */		
		public function stop():void
		{
			clearInterval(_intervalID);
			_intervalID = NaN;
		}
		
		
		/**
		 * 알람 등록 
		 * 
		 */		
		public function getIsPlaying():Boolean
		{
			return	_intervalID;
		}
		
		
		/**
		 * 알람 등록 
		 * @param $date
		 * @param $handler
		 * @param $args
		 * 
		 */		
		public function add($handler:Function, ...$args):void
		{
			$args.unshift(_bindingKey, $handler);
			_binding.add.apply(null, $args);
		}
		
		
		/**
		 * 알람 등록 
		 * @param $date
		 * @param $handler
		 * @param $args
		 * 
		 */		
		public function addPlay($handler:Function, ...$args):void
		{
			var a:Array = $args.concat();
			
			$args.unshift($handler);
			add.apply(null, $args);
			
			a.unshift(getDate());
			$handler.apply(null, a);
		}
		
		
		public function del($handler:Function):void
		{
			_binding.del(_bindingKey, $handler);
		}
		
		
		public function getInterval():Number
		{
			return	_interval * 0.001;
		}
	}
}