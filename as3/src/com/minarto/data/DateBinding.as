package com.minarto.data
{
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	

	public class DateBinding
	{
		static private const _dic:* = {}, _binding:Binding = BindingDic.get("__DateBinding__");
		
		
		static private var _offsetTime:Number = 0;
		
		
		static public function init(...$api):void
		{
			var onTime:Function, timer:Timer = new Timer(60000);
			
			onTime = function($year:uint, $month:uint, $date:uint, $hour:uint, $sec:uint, $millisec:uint=0):void
			{
				_offsetTime = (new Date).time - (new Date($year, $month, $date, $hour, $sec, $millisec)).time;
			};
			_binding.add("serverDate", onTime);
			
			timer.addEventListener(TimerEvent.TIMER, function($e:TimerEvent):void
				{
					ExternalInterface.call.apply(null, $api);
				}
			);
			timer.dispatchEvent(new TimerEvent(TimerEvent.TIMER));
			timer.start();
		}
		
		
		static public function get($delay:Number=0.1):DateBinding
		{
			return	_dic[$delay] || (_dic[$delay] = new DateBinding($delay));
		}
		
		
		/**
		 * 알람 등록 
		 * @param $date
		 * @param $handler
		 * @param $args
		 * 
		 */		
		static public function getDate():Date
		{
			var date:Date = new Date;
			
			date.setTime(_offsetTime + date.time);
			
			return	date;
		}
		
		
		private var _delay:Number = 0.1;
		
		
		public function DateBinding($delay:Number=0.1)
		{
			var timer:Timer, key:String;
			
			if(_dic[$delay])	throw	new Error("don't create new instance");
			
			_delay = $delay;
			_dic[$delay] = this;
			
			key = "" + $delay;
			
			timer = new Timer($delay * 1000);
			timer.addEventListener(TimerEvent.TIMER, function($e:TimerEvent):void
				{
					var date:Date = new Date;
				
					date.setTime(_offsetTime + date.time);
					_binding.event(key, date);
				}
			);
			
			timer.dispatchEvent(new TimerEvent(TimerEvent.TIMER));
			timer.start();
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
			$args.unshift("" + _delay, $handler);
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
			_binding.del("" + _delay, $handler);
		}
		
		
		public function getDelay():Number
		{
			return	_delay;
		}
	}
}