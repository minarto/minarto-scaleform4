package com.minarto.loader
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;

	
	/**
	 * @author minarto
	 */
	public class MUILoader 
	{
		protected const _urq:URLRequest = new URLRequest, contents:Array = [];
		
		
		protected var reservations:Array = [], currentLoadVars:Array, total:uint, allComplete:Function, allVar:*, loadedCount:uint;
		
		
		public function getLoaded():uint
		{
			return	loadedCount;
		}
		
		
		public function getTotal():uint
		{
			return	total;
		}
		
		
		public function getContentAt($uint=0):DisplayObject
		{
			return	contents[$uint];
		}
		
		
		public function getContents():Array
		{
			return	contents.concat();
		}
		
		
		/**
		 * 로드 
		 * @param $src
		 * @param $vars
		 * @return 
		 * 
		 */		
		public function add($src:String, $completeOrVar:*=null):void
		{
			var onComplete:Function = $completeOrVar as Function, cVar:*;
			
			if(onComplete)
			{
				cVar = {};
				cVar.onComplete = onComplete;
			}
			else if($completeOrVar)	cVar = $completeOrVar;
			else	cVar = {};
			
			cVar.src = $src;
			
			reservations.push(cVar);
		}
		
		
		/**
		 * 로드 삭제 
		 * @param $loadID
		 * 
		 */		
		public function del($key:String, $v:*):void
		{
			var i:uint = currentLoadVars.length, cVar:*, loader:Loader, info:LoaderInfo;
			
			while(i --)
			{
				cVar = currentLoadVars[i];
				if(cVar[$key] == $v)
				{
					loader = cVar.__loader__;
					loader.close();
					
					info = loader.contentLoaderInfo;
					info.removeEventListener(Event.COMPLETE, _complete);
					info.removeEventListener(IOErrorEvent.IO_ERROR, _error);
					
					-- total;
					delete	cVar.__loader__;
					
					currentLoadVars.splice(i, 1);
				}
			}
			
			i = reservations.length;
			
			while(i --)
			{
				cVar = reservations[i];
				if(cVar[$key] == $v)	reservations.splice(i, 1);
			}
			
			_checkAllComplete();
		}
		
		
		/**
		 * 로드
		 * @param $complete
		 * @param $var
		 * 
		 */		
		public function load($complete:Function, $var:*=null):void
		{
			var i:*, cVar:*, loader:Loader, info:LoaderInfo, funcParams:Array, key:String = "onProgress";
		
			for(i in reservations)
			{
				cVar = reservations[i];
				
				loader = new Loader;
						
				info = loader.contentLoaderInfo;
				info.addEventListener(Event.COMPLETE, _complete);
				info.addEventListener(IOErrorEvent.IO_ERROR, _error);
				
				cVar.__loader__ = loader;
				_urq.url = cVar.src;
				loader.load(_urq);
				
				++ total;
			}
			
			contents.length = 0;
			currentLoadVars = currentLoadVars.concat(reservations);
			reservations.length = 0;
			allComplete = $complete;
			allVar = $var = {};
			
			$complete = $var[key];
			if($complete)	$complete.apply(null, $var[key + "Params"]);
		}
		
		
		private function _complete($e:Event):void
		{
			var info:LoaderInfo = $e.target as LoaderInfo, loader:Loader = info.loader, i:*, cVar:*
				, content:DisplayObject = info.content, k:String = "onComplete", onComplete:*, funcParams:Array;
			
			++ loadedCount;
			
			info.removeEventListener(Event.COMPLETE, _complete);
			info.removeEventListener(IOErrorEvent.IO_ERROR, _error);
			
			for(i in currentLoadVars)
			{
				cVar = currentLoadVars[i];
				if(cVar.__loader__ == loader)
				{
					delete	cVar.__loader__;
					
					onComplete = cVar[k];
					
					cVar.content = content = info.content;
					
					if(onComplete)
					{
						funcParams = cVar[k + "Params"];
						if(funcParams)
						{
							funcParams.unshift(content);
							onComplete.apply(null, funcParams);
						}
						else	onComplete(content);
					}
					
					_checkAllComplete();
					
					return;
				}
			}
		}
		
		
		private function _error($e:IOErrorEvent):void
		{
			var info:LoaderInfo = $e.target as LoaderInfo, loader:Loader = info.loader, i:*, cVar:*
				, onError:Function, funcParams:Array;
			
			++ loadedCount;
			
			info.removeEventListener(Event.COMPLETE, _complete);
			info.removeEventListener(IOErrorEvent.IO_ERROR, _error);
			
			for(i in currentLoadVars)
			{
				cVar = currentLoadVars[i];
				if(cVar.__loader__ == loader)
				{
					delete	cVar.__loader__;
					
					onError = cVar.onError;
					
					cVar.content = undefined;
					
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
			var i:*, func:Function, funcParams:Array, cVar:*, key:String = "onProgress";
			
			if(loadedCount < total)
			{
				if(allVar)
				{
					func = allVar[key];
					if(func)	func.apply(null, allVar[key + "Params"]);
				}
				
				return;
			}
			
			contents.length = total;
			for(i in currentLoadVars)
			{
				cVar = currentLoadVars[i];
				contents[i] = cVar.content;
			}
			currentLoadVars.length = 0;
			
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
			
			contents.length = 0;
			loadedCount = 0;
			total = 0;
			allComplete = null;
			allVar = null;
		}
	}
}