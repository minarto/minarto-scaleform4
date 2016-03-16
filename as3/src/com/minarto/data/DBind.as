package com.minarto.data
{
	import flash.utils.*;
	

	public class DBind extends Bind
	{
		static protected const gbind:Bind = new Bind;
		
		
		static protected var offsetTime:Number;
		
		
		static protected function onTime($year:uint, $month:uint, $date:uint, $hour:uint, $min:uint, $sec:uint=0, $millisec:uint=0):void
		{
			var date:Date = new Date($year, $month, $date, $hour, $min, $sec, $millisec);
			
			offsetTime = date.time - getTimer();
		};
		
		
		static protected function getOffsetTime():Number
		{
			if(isNaN(offsetTime))
			{
				var date:Date = new Date;
				
				gbind.add("serverDate", onTime);
				
				gbind.evt("serverDate", date.fullYear, date.month, date.date, date.hours, date.minutes, date.seconds, date.milliseconds);
			}
			
			return	offsetTime;
		}
		
		
		static public function getDate():Date
		{
			return	new Date(getOffsetTime() + getTimer());
		}
		
		
		public function toString():String
		{
			return	"[com.minarto.data.DBind interval:" + getInterval() + "sec]";
		}
		
		
		protected var interval:uint = 100, intervalID:uint;
		
		
		/**
		 * 
		 */		
		public function init($interval:Number=0.1):void
		{
			interval = $interval * 1000;
			
			if(getIsPlaying())
			{
				play();
			}
		}
		
		
		/**
		 * 
		 */		
		protected function intervalFunc():void
		{
			var key:String, date:Date = getDate();
			
			for(key in handlerDic)
			{
				evt(key, date);
			}
		}
		
		
		/**
		 * 알람 등록 
		 * 
		 */		
		public function play():void
		{
			clearInterval(intervalID);
			intervalID = setInterval(intervalFunc, interval);
		}
		
		
		/**
		 * 알람 등록 
		 * 
		 */		
		public function stop():void
		{
			clearInterval(intervalID);
			intervalID = NaN;
		}
		
		
		/**
		 * 알람 등록 
		 * 
		 */		
		public function getIsPlaying():Boolean
		{
			return	intervalID;
		}
		
		
		public function getInterval():Number
		{
			return	interval * 0.001;
		}
	}
}