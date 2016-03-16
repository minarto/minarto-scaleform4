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
		protected const urq:URLRequest = new URLRequest, reservations:Array = [];
		
		
		protected var allVar:*, loadedCount:uint;
		
		
		/**
		 * 로드 
		 * @param $src
		 * @param $vars
		 * @return 
		 * 
		 */		
		public function add($src:String, $completeOrVar:*=null):void
		{
			var cVar:* = {}, p:*;
			
			if($completeOrVar as Function)	cVar.onComplete = $completeOrVar;
			else if($completeOrVar)	for(p in $completeOrVar)	cVar[p] = $completeOrVar[p];
			
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
			var i:uint = reservations.length, cVar:*, loader:Loader, info:LoaderInfo;
			
			while(i --)
			{
				cVar = reservations[i];
				if(cVar[$key] == $v)
				{
					loader = cVar.__loader__;
					loader.close();
					
					info = loader.contentLoaderInfo;
					info.removeEventListener(Event.COMPLETE, complete);
					info.removeEventListener(IOErrorEvent.IO_ERROR, error);
					
					delete	cVar.__loader__;
					
					reservations.splice(i, 1);
				}
			}
			
			checkAllComplete();
		}
		
		
		/**
		 * 로드
		 * @param $complete
		 * @param $var
		 * 
		 */		
		public function load($complete:Function, $var:*=null):void
		{
			var i:uint = reservations.length, cVar:*, loader:Loader, info:LoaderInfo, key:String = "onProgress", funcParams:Array;
			
			loadedCount = 0;
			
			if(!$var) $var = {};
			$var.onComplete = $complete;
			allVar = $var;
			
			$complete = $var[key];
			if($complete)
			{
				funcParams = $var[key + "Params"];
				if(funcParams)	funcParams.unshift(0, i);
				else	$var[key + "Params"] = funcParams = [0, i];
				$complete.apply(null, funcParams);
			}
			
			while(i --)
			{
				cVar = reservations[i];
				
				loader = new Loader;
				
				info = loader.contentLoaderInfo;
				info.addEventListener(Event.COMPLETE, complete);
				info.addEventListener(IOErrorEvent.IO_ERROR, error);
				
				cVar.__loader__ = loader;
				urq.url = cVar.src;
				loader.load(urq);
			}
		}
		
		
		protected function complete($e:Event):void
		{
			var info:LoaderInfo = $e.target as LoaderInfo, loader:Loader = info.loader, i:*, cVar:*
				, content:DisplayObject = info.content, key:String = "onProgress", func:Function, funcParams:Array;
			
			++ loadedCount;
			
			info.removeEventListener(Event.COMPLETE, complete);
			info.removeEventListener(IOErrorEvent.IO_ERROR, error);
			
			for(i in reservations)
			{
				cVar = reservations[i];
				if(cVar.__loader__ == loader)
				{
					delete	cVar.__loader__;
					
					cVar.content = content;
					
					if(func)
					{
						funcParams = allVar[key + "Params"];
						funcParams[0] = loadedCount;
						func.apply(null, funcParams);
					}
					
					key = "onComplete";
					func = cVar[key];
					if(func)
					{
						funcParams = cVar[key + "Params"];
						if(funcParams)
						{
							funcParams.unshift(content);
							func.apply(null, funcParams);
						}
						else	func(content);
					}
					
					checkAllComplete();
					
					return;
				}
			}
		}
		
		
		protected function error($e:IOErrorEvent):void
		{
			var info:LoaderInfo = $e.target as LoaderInfo, loader:Loader = info.loader, i:*, cVar:*
				, key:String = "onProgress", func:Function, funcParams:Array;
			
			++ loadedCount;
			
			info.removeEventListener(Event.COMPLETE, complete);
			info.removeEventListener(IOErrorEvent.IO_ERROR, error);
			
			for(i in reservations)
			{
				cVar = reservations[i];
				if(cVar.__loader__ == loader)
				{
					delete	cVar.__loader__;
					
					cVar.content = null;
					
					if(func)
					{
						funcParams = allVar[key + "Params"];
						funcParams[0] = loadedCount;
						func.apply(null, funcParams);
					}
					
					key = "onError";
					func = cVar[key];
					if(func)	func.apply(null, cVar[key + "Params"]);
					
					checkAllComplete();
					
					return;
				}
			}
		}
		
		
		protected function checkAllComplete():void
		{
			var i:uint = reservations.length, key:String, func:Function, funcParams:Array, contents:Array, cVar:*;
			
			if(loadedCount < i)	return;
			
			key = "onComplete";
			func = allVar[key];
			if(func)
			{
				contents = [];
				while(i --)
				{
					cVar = reservations[i];
					contents[i] = cVar.content;
				}
				
				funcParams = allVar[key + "Params"];
				if(funcParams)
				{
					funcParams.unshift(contents);
					func.apply(null, funcParams);
				}
				else	func(contents);
			}
			
			reservations.length = 0;
			loadedCount = 0;
			allVar = null;
		}
	}
}