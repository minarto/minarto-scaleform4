package com.minarto.loader
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	
	
	/**
	 * @author minarto
	 */
	public class SLoader 
	{
		private const _uLoader:URLLoader = new URLLoader, _urq:URLRequest = new URLRequest, _reservations:Array = [];
		
		
		private var _currentVars:*, _dLoader:Loader = new Loader, _allVars:*, _count:uint;
		
		
		/**
		 * 로드 
		 * @param $type
		 * @param $src
		 * @param $vars
		 * @return 
		 * 
		 */		
		public function add($type:String, $src:String, $vars:*):void
		{
			var info:LoaderInfo, onComplete:Function = $vars as Function;
			
			if(onComplete)
			{
				$vars = {};
				$vars.onComplete = onComplete;
			}
			else if(!$vars)
			{
				$vars = {};
			}
			
			switch($type = ($type || "").toLowerCase())
			{
				case "img" :
					break;
				case "swf" :
					break;
				case "txt" :
					break;
				case "xml" :
					break;
				
				default :
					throw	new Error("load type error");
			}
			
			$vars.type = $type;
			$vars.src = $src;

			_reservations.push($vars);
			++ _count;
		}
		
		
		/**
		 * 로드 id로 삭제 
		 * @param $loadID
		 * 
		 */		
		public function del($key:String, $v:*):void
		{
			var i:uint = _reservations.length, vars:*, loader:*, info:LoaderInfo;
			
			if(_currentVars && (_currentVars[$key] == $v))
			{
				switch(_currentVars.type)
				{
					case "xml" :
					case "txt" :
						loader = _uLoader;
						break;
					
					default :
						info = _dLoader.contentLoaderInfo;
						info.removeEventListener(Event.COMPLETE, _complete);
						info.removeEventListener(IOErrorEvent.IO_ERROR, _error);
						
						loader = _dLoader;
				}
				
				-- _count;
				loader.close();
				
				_load();
			}
			
			while(i --)
			{
				vars = _reservations[i];
				if(vars[$key] == $v)
				{
					-- _count;
					_reservations.splice(i, 1);
				}
			}
		}
		
		
		/**
		 * 로드
		 * @param $complete
		 * @param $args
		 * 
		 */		
		public function load($complete:Function, $vars:*=null):void
		{
			if(_currentVars)	return;
			
			if(!$vars)	$vars = {};
			$vars.onComplete = $complete;
			$vars.content = [];
			_allVars = $vars;
			
			_uLoader.addEventListener(Event.COMPLETE, _complete);
			_uLoader.addEventListener(IOErrorEvent.IO_ERROR, _error);
			
			_load();
		}
		
		
		private function _complete($e:Event):void
		{
			var data:*, info:LoaderInfo, onComplete:Function = _currentVars.onComplete, a:Array = _allVars.content;
			
			switch(_currentVars.type)
			{
				case "xml" :
					try
					{
						data = XML(_uLoader.data);
					}
					catch($error:Error)
					{
					}
					
					break;
				
				case "txt" :
					data = _uLoader.data;
					break;
				
				default :
					info = _dLoader.contentLoaderInfo;
					info.removeEventListener(Event.COMPLETE, _complete);
					info.removeEventListener(IOErrorEvent.IO_ERROR, _error);
					
					data = info.content;
			}
			
			_currentVars.data = data;
			a.push(_currentVars);
			
			if(onComplete)
			{
				a = _currentVars.onCompleteParams;
				
				if(a)
				{
					a.unshift(data);
					onComplete.apply(null, a);
				}
				else
				{
					onComplete(data);
				}
			}
			
			_load();
		}
		
		
		/**
		 * io error 이벤트 핸들러 
		 * @param $e
		 * 
		 */		
		private function _error($e:IOErrorEvent):void 
		{
			var data:* = undefined, info:LoaderInfo, onError:Function = _currentVars.onError, contents:Array = _allVars.content;
			
			switch(_currentVars.type)
			{
				case "swf" :
				case "img" :
					info = _dLoader.contentLoaderInfo;
					info.removeEventListener(Event.COMPLETE, _complete);
					info.removeEventListener(IOErrorEvent.IO_ERROR, _error);

					break;
			}
			
			_currentVars.data = data;
			contents.push(_currentVars);
			
			if(onError)	onError.apply(null, _currentVars.onErrorParams);
			
			_load();
		}
		
		
		private function _load():void 
		{
			var loader:*, info:LoaderInfo, func:Function, funcParams:Array, loadedFileLength:uint = _count - _reservations.length;
			
			if(loadedFileLength < _count)
			{
				func = _allVars.onProgress;
				if(func)
				{
					funcParams = _allVars.onProgressParams;
					if(funcParams)
					{
						funcParams.unshift(loadedFileLength, _count);
						func.apply(null, funcParams);
					}
					else	func(loadedFileLength, _count);
				}
			}
			
			if(_currentVars = _reservations.shift())
			{
				_urq.url = _currentVars.src;
				
				switch(_currentVars.type)
				{
					case "txt" :
					case "xml" :
						loader = _uLoader;
						break;
					
					default :
						_dLoader = new Loader;
						
						info = _dLoader.contentLoaderInfo;
						info.addEventListener(Event.COMPLETE, _complete);
						info.addEventListener(IOErrorEvent.IO_ERROR, _error);
						
						loader = _dLoader;
				}
				
				loader.load(_urq);
			}
			else
			{
				_uLoader.removeEventListener(Event.COMPLETE, _complete);
				_uLoader.removeEventListener(IOErrorEvent.IO_ERROR, _error);
				
				func = _allVars.onComplete;
				if(func)
				{
					funcParams = _allVars.onCompleteParams;
					if(funcParams)
					{
						funcParams.unshift(_allVars.content);
						func.apply(null, funcParams);
					}
					else	func(_allVars.content);
				}
				
				_allVars = null;
				_count = 0;
				_dLoader = null;
			}
		}
	}
}