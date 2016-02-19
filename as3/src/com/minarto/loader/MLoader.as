package com.minarto.loader
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	

	/**
	 * @author minarto
	 */
	public class MLoader 
	{
		private const _urq:URLRequest = new URLRequest;
		
		
		protected var reservations:Array = [], currentLoadVars:Array = [], length:uint, contents:Array, allComplete:Function, allVar:*, loadedCount:uint;
		
		
		/**
		 * 로드 
		 * @param $type
		 * @param $src
		 * @param $completeOrVar
		 * @return 
		 * 
		 */		
		public function add($type:String, $src:String, $completeOrVar:*=null):void
		{
			var onComplete:Function = $completeOrVar as Function, cVar:*;
			
			if(onComplete)
			{
				cVar = {};
				cVar.onComplete = onComplete;
			}
			else if($completeOrVar)	cVar = $completeOrVar;
			else	cVar = {};
			
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
			
			cVar.type = $type;
			cVar.src = $src;
			
			reservations.push(cVar);
		}
		
		
		/**
		 * 로드 삭제 
		 * @param $key
		 * @param $v
		 * 
		 */		
		public function del($key:String, $v:*):void
		{
			var i:uint = currentLoadVars.length, cVar:*, loader:*, info:LoaderInfo;
			
			while(i --)
			{
				cVar = currentLoadVars[i];
				if(cVar[$key] == $v)
				{
					loader = cVar.__loader__;
					
					if(loader as Loader)
					{
						info = loader.contentLoaderInfo;
						info.removeEventListener(Event.COMPLETE, _complete);
						info.removeEventListener(IOErrorEvent.IO_ERROR, _error);
					}
					
					loader.close();
					
					delete	cVar.__loader__;
					
					-- length;
					
					currentLoadVars.splice(i, 1);
				}
			}
			
			i = reservations.length;
			while(i --)
			{
				cVar = reservations[i];
				if(cVar[$key] == $v)	currentLoadVars.splice(i, 1);
			}
			
			_checkAllComplete();
		}
		
		
		/**
		 * 로드
		 * @param $complete
		 * @param $vargs
		 * 
		 */		
		public function load($complete:Function, $var:*=null):void
		{
			var cVar:*, i:*, loader:*, info:LoaderInfo, funcParams:Array;
		
			for(i in reservations)
			{
				cVar = reservations[i];
				
				switch(cVar.type)
				{
					case "txt" :
					case "xml" :
						loader = new URLLoader;
						
						loader.addEventListener(Event.COMPLETE, _complete);
						loader.addEventListener(IOErrorEvent.IO_ERROR, _error);
						break;
					
					default :
						loader = new Loader;
						
						info = loader.contentLoaderInfo;
						info.addEventListener(Event.COMPLETE, _complete);
						info.addEventListener(IOErrorEvent.IO_ERROR, _error);
				}
				
				cVar.__loader__ = loader;
				_urq.url = cVar.src;
				loader.load(_urq);
				
				++ length;
			}
			
			currentLoadVars = currentLoadVars.concat(reservations);
			
			reservations.length = 0;
			allComplete = $complete;
			allVar = $var;
			
			if($var)
			{
				$complete = $var.onProgress;
				if($complete)
				{
					funcParams = $var.onProgressParams;
					if(funcParams)
					{
						funcParams.unshift(0, length);
						$complete.apply(null, funcParams);
					}
					else	$complete(0, length);
				}
			}
		}
		
		
		private function _complete($e:Event):void
		{
			var info:LoaderInfo = $e.target as LoaderInfo, loader:*, i:*, cVar:*, data:*, onComplete:Function, funcParams:Array;
			
			++ loadedCount;
			
			if(info)
			{
				info.removeEventListener(Event.COMPLETE, _complete);
				info.removeEventListener(IOErrorEvent.IO_ERROR, _error);
				
				data = info.content;
				loader = info.loader;
			}
			else	loader = $e.target as URLLoader;
			
			for(i in currentLoadVars)
			{
				cVar = currentLoadVars[i];
				if(cVar.__loader__ == loader)
				{
					delete	cVar.__loader__;
					
					onComplete = cVar.onComplete;
					
					switch(cVar.type)
					{
						case "xml" :
							try	{	data = XML(loader.data);	}
							catch($error:Error)	{}
							
							break;
						
						case "txt" :
							data = loader.data;
							break;
					}
					
					contents[i] = data;
					
					if(onComplete)
					{
						funcParams = cVar.onCompleteParams;
						if(funcParams)
						{
							funcParams.unshift(data);
							onComplete.apply(null, funcParams);
						}
						else	onComplete(data);
					}
					
					_checkAllComplete();
					
					return;
				}
			}
			
			
		}
		
		
		/**
		 * io error 이벤트 핸들러 
		 * @param $e
		 * 
		 */		
		private function _error($e:IOErrorEvent):void 
		{
			var info:LoaderInfo = $e.target as LoaderInfo, loader:*, i:*, cVar:*, onError:Function, funcParams:Array;
			
			++ loadedCount;
			
			if(info)
			{
				info.removeEventListener(Event.COMPLETE, _complete);
				info.removeEventListener(IOErrorEvent.IO_ERROR, _error);
				
				loader = info.loader;
			}
			else	loader = $e.target as URLLoader;
			
			for(i in currentLoadVars)
			{
				cVar = currentLoadVars[i];
				if(cVar.__loader__ == loader)
				{
					delete	cVar.__loader__;
					
					onError = cVar.onError;
					
					contents[i] = null;
					
					if(onError)
					{
						funcParams = cVar.onErrorParams;
						if(funcParams)	onError.apply(null, funcParams);
						else	onError();
					}
			
					_checkAllComplete();
					
					return;
				}
			}
		}
		
		
		private function _checkAllComplete():void
		{
			var i:*, func:Function, funcParams:Array;
			
			if(loadedCount < length)
			{
				if(allVar)
				{
					func = allVar.onProgress;
					if(func)
					{
						funcParams = allVar.onProgressParams;
						if(funcParams)
						{
							funcParams[0] = loadedCount;
							func.apply(null, funcParams);
						}
						else	func(loadedCount, length);
					}
				}
				
				return;
			}
			
			if(allComplete)
			{
				if(allVar)	funcParams = allVar.onProgressParams;
				else	funcParams = null;
				
				if(funcParams)
				{
					funcParams[0] = contents;
					allComplete.apply(null, funcParams);
				}
				else	allComplete(contents);
			}
			
			contents = [];
			loadedCount = 0;
			length = 0;
			allComplete = null;
			allVar = null;
		}
	}
}