package com.minarto.controls
{
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	
	
	public class VideoPlayerBase extends Video
	{
		override public function toString():String
		{
			return "[com.minarto.controls.VideoPlayerBase " + name + "]";
		}
		
		
		private var _volume:Number = 1, _duration:Number, _connection:NetConnection;
		
		
		protected var _stream:NetStream;
		
		
		/**
		 * 
		 */		
		
		public function getStream():NetStream
		{
			return	_stream;
		}
		
		
		/**
		 * 
		 */		
		
		public function setVolume($v:Number):void
		{
			var soundTransform:SoundTransform;
			
			if($v == _volume)	return;
			_volume = $v;
			
			soundTransform = _stream.soundTransform || new SoundTransform;
			soundTransform.volume = $v;
			_stream.soundTransform = soundTransform;
		}
		
		public function getVolume():Number
		{
			return	_volume;
		}
		
		
		/**
		 */
		public function VideoPlayerBase()
		{
			_connection = new NetConnection;
			_connection.connect(null);
			_connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			
			_stream = new NetStream(_connection);
			_stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			_stream.client = this;
			attachNetStream(_stream);
		}
		
		
		/**
		 * 
		 */		
		public function destroy():void
		{
			clear();
			
			_connection.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			_stream.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			
			_connection = null;
			
			try
			{
				_stream.close();
			}
			catch(error:Error)	{}
		}
		
		
		/**
		 * 
		 * @param $info
		 * 
		 */		
		public function onMetaData($info:Object):void
		{
			_duration = $info.duration;
		}
		
		
		/**
		 * 
		 * @param $info
		 * 
		 */		
		public function onXMPData(...$datas):void
		{
			trace($datas);
		}
		
		
		/**
		 * 
		 * @param $info
		 * 
		 */		
		public function onPlayStatus(...$datas):void
		{
			trace($datas);
		}
		
		
		/**
		 * 
		 */
		public function setSource($v:String):void
		{
			var soundTransform:SoundTransform = _stream.soundTransform || new SoundTransform;
			
			_stream.play($v, 0);
			soundTransform.volume = _volume;
			_stream.soundTransform = soundTransform;
		}
		
		
		/**
		 * 
		 */
		private function netStatusHandler($e:NetStatusEvent):void
		{
			if(_connection == $e.target)	_connection.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			
			var code:String = $e.info.code;

			switch (code)
			{
				case "NetStream.Play.StreamNotFound":
					dispatchEvent(new Event(code));
					break;
				case "NetStream.Play.Stop":
					//if(Math.abs(_duration - _stream.time) < 1)	dispatchEvent(new Event("playComplete"));
					dispatchEvent(new Event("playComplete"));
					break;
				case "NetStream.Play.Start":
					dispatchEvent(new Event(code));
					break;
				
				default :
					dispatchEvent(new Event(code));
					break;
			}
		}
		
		
		/**
		 * 
		 */
		public function seek($v:Number):void
		{
			_stream.seek($v || 0);
		}
		
		
		/**
		 * 
		 */
		public function getBytesLoaded():uint
		{
			return	_stream.bytesLoaded;
		}
		
		
		/**
		 * 
		 */
		public function getBytesTotal():uint
		{
			return	_stream.bytesTotal;
		}
		
		
		/**
		 * 총 재생시간
		 */
		public function getDuration():Number
		{
			return	_duration;
		}
		
		
		/**
		 * 재생
		 */
		public function play():void
		{
			_stream.resume();
		}
		
		
		/**
		 * 일시정지
		 */
		public function pause():void
		{
			_stream.pause();
		}
		
		
		/**
		 * 정지
		 */
		public function stop():void
		{
			pause();
			_stream.seek(0);
			clear();
		}
	}
}