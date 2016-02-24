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
		protected const urq:URLRequest = new URLRequest, reservations:Array = [];
		
		
		protected var allVar:*, loadedCount:uint;
		
		
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
			var cVar:*;
			
			if(allVar)	throw	new Error("can't add on Loading");
			
			if($completeOrVar as Function)
			{
				cVar = {};
				cVar.onComplete = $completeOrVar;
			}
			else	cVar = $completeOrVar || {};
			
			switch($type = ($type || "").toLowerCase())
			{
				case "img" :
				case "swf" :
				case "txt" :
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
			var i:uint = reservations.length, cVar:*, loader:*, info:LoaderInfo;
			
			while(i --)
			{
				cVar = reservations[i];
				if(cVar[$key] == $v)
				{
					loader = cVar.__loader__;
					
					if(loader as Loader)
					{
						info = loader.contentLoaderInfo;
						info.removeEventListener(Event.COMPLETE, complete);
						info.removeEventListener(IOErrorEvent.IO_ERROR, error);
					}
					
					loader.close();
					
					delete	cVar.__loader__;
					
					reservations.splice(i, 1);
				}
			}
			
			checkAllComplete();
		}
		
		
		/**
		 * 로드
		 * @param $complete
		 * @param $vargs
		 * 
		 */		
		public function load($complete:Function, $var:*=null):void
		{
			var i:uint = reservations.length, cVar:*, loader:*, info:LoaderInfo, key:String = "onProgress", funcParams:Array;
		
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
				
				switch(cVar.type)
				{
					case "txt" :
					case "xml" :
						loader = new URLLoader;
						
						loader.addEventListener(Event.COMPLETE, complete);
						loader.addEventListener(IOErrorEvent.IO_ERROR, error);
						break;
					
					default :
						loader = new Loader;
						
						info = loader.contentLoaderInfo;
						info.addEventListener(Event.COMPLETE, complete);
						info.addEventListener(IOErrorEvent.IO_ERROR, error);
				}
				
				cVar.__loader__ = loader;
				urq.url = cVar.src;
				loader.load(urq);
			}
		}
		
		
		protected function complete($e:Event):void
		{
			var info:LoaderInfo = $e.target as LoaderInfo, loader:*, i:*, cVar:*, data:*
				, key:String = "onProgress", func:Function = allVar[key], funcParams:Array;
			
			++ loadedCount;
			
			if(info)
			{
				info.removeEventListener(Event.COMPLETE, complete);
				info.removeEventListener(IOErrorEvent.IO_ERROR, error);
				
				data = info.content;
				loader = info.loader;
			}
			else	loader = $e.target as URLLoader;
			
			for(i in reservations)
			{
				cVar = reservations[i];
				if(cVar.__loader__ == loader)
				{
					delete	cVar.__loader__;
					
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
					
					cVar.content = data;
					
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
							funcParams.unshift(data);
							func.apply(null, funcParams);
						}
						else	func(data);
					}
					
					checkAllComplete();
					
					return;
				}
			}
			
			
		}
		
		
		/**
		 * io error 이벤트 핸들러 
		 * @param $e
		 * 
		 */		
		protected function error($e:IOErrorEvent):void 
		{
			var info:LoaderInfo = $e.target as LoaderInfo, loader:*, i:*, cVar:*
				, key:String = "onProgress", func:Function, funcParams:Array;
			
			++ loadedCount;
			
			if(info)
			{
				info.removeEventListener(Event.COMPLETE, complete);
				info.removeEventListener(IOErrorEvent.IO_ERROR, error);
				
				loader = info.loader;
			}
			else	loader = $e.target as URLLoader;
			
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