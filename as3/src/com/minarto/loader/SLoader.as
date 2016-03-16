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
		protected const uLoader:URLLoader = new URLLoader, urq:URLRequest = new URLRequest, reservations:Array = [], contents:Array = [];
		
		
		protected var currentVar:*, dLoader:Loader, allVar:*, loadedIndex:uint;
		
		
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
			var cVar:* = {}, p:*;
			
			if($vars as Function)	cVar.onComplete = $vars;
			else if($vars)	for(p in $vars)	cVar[p] = $vars[p];
			
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
		 * 로드 id로 삭제 
		 * @param $loadID
		 * 
		 */		
		public function del($key:String, $v:*):void
		{
			var i:uint = reservations.length, cVar:*, loader:*, info:LoaderInfo;
			
			while(i --)
			{
				cVar = reservations[i];
				if (cVar[$key] == $v)	reservations.splice(i, 1);
			}
			
			if(currentVar && (currentVar[$key] == $v))
			{
				switch(currentVar.type)
				{
					case "xml" :
					case "txt" :
						loader = uLoader;
						break;
					
					default :
						info = dLoader.contentLoaderInfo;
						info.removeEventListener(Event.COMPLETE, complete);
						info.removeEventListener(IOErrorEvent.IO_ERROR, error);
						
						loader = dLoader;
				}
				
				loader.close();
				
				_load();
			}
		}
		
		
		/**
		 * 로드
		 * @param $complete
		 * @param $vars
		 * 
		 */		
		public function load($complete:Function, $var:*=null):void
		{
			var key:String = "onProgress", funcParams:Array, total:uint = reservations.length;
			
			loadedIndex = 0;
			
			if(!$var) $var = {};
			$var.onComplete = $complete;
			allVar = $var;
			
			$complete = $var[key];
			if($complete)
			{
				funcParams = $var[key + "Params"];
				if(funcParams)	funcParams.unshift(0, total);
				else	$var[key + "Params"] = funcParams = [0, total];
			}
			
			uLoader.addEventListener(Event.COMPLETE, complete);
			uLoader.addEventListener(IOErrorEvent.IO_ERROR, error);
			
			_load();
		}
		
		
		protected function complete($e:Event):void
		{
			var data:*, info:LoaderInfo, key:String = "onProgress", func:Function = allVar[key], funcParams:Array;
			
			++ loadedIndex;
			
			switch(currentVar.type)
			{
				case "xml" :
					try	{	data = XML(uLoader.data);	}
					catch($error:Error)	{}
					
					break;
				
				case "txt" :
					data = uLoader.data;
					break;
				
				default :
					info = dLoader.contentLoaderInfo;
					info.removeEventListener(Event.COMPLETE, complete);
					info.removeEventListener(IOErrorEvent.IO_ERROR, error);
					
					data = info.content;
			}
			
			contents.push(data);
			
			if(func)
			{
				funcParams = allVar[key + "Params"];
				funcParams[0] = loadedIndex;
				func.apply(null, funcParams);
			}
			
			key = "onComplete";
			func = currentVar[key];
			if (func)
			{
				funcParams = allVar[key + "Params"];
				if (funcParams)
				{
					funcParams.unshift(data);
					func.apply(null, funcParams);
				}
				else	func(data);
			}
			
			_load();
		}
		
		
		/**
		 * io error 이벤트 핸들러 
		 * @param $e
		 * 
		 */		
		protected function error($e:IOErrorEvent):void 
		{
			var info:LoaderInfo, key:String = "onProgress", func:Function = allVar[key], funcParams:Array;
			
			++ loadedIndex;
			
			switch(currentVar.type)
			{
				case "swf" :
				case "img" :
					info = dLoader.contentLoaderInfo;
					info.removeEventListener(Event.COMPLETE, complete);
					info.removeEventListener(IOErrorEvent.IO_ERROR, error);
					
					break;
			}
			
			contents.push(null);
			
			if(func)
			{
				funcParams = allVar[key + "Params"];
				funcParams[0] = loadedIndex;
				func.apply(null, funcParams);
			}

			key = "onError";
			func = currentVar[key];
			if(func)	func.apply(null, currentVar[key + "Params"]);
			
			_load();
		}
		
		
		protected function _load():void 
		{
			var key:String, func:Function, funcParams:Array, loader:*, info:LoaderInfo;
			
			if(currentVar = reservations.shift())
			{
				urq.url = currentVar.src;
				
				switch(currentVar.type)
				{
					case "txt" :
					case "xml" :
						loader = uLoader;
						break;
					
					default :
						loader = dLoader = new Loader;
						
						info = dLoader.contentLoaderInfo;
						info.addEventListener(Event.COMPLETE, complete);
						info.addEventListener(IOErrorEvent.IO_ERROR, error);
				}
				
				loader.load(urq);
			}
			else
			{
				uLoader.removeEventListener(Event.COMPLETE, complete);
				uLoader.removeEventListener(IOErrorEvent.IO_ERROR, error);
				
				key = "onComplete";
				func = allVar[key];
				if (func)
				{
					funcParams = allVar[key + "Params"];
					if (funcParams)
					{
						funcParams.unshift(contents.concat());
						func.apply(null, funcParams);
					}
					else	func(contents.concat());
				}
				
				loadedIndex = 0;
				contents.length = 0;
				allVar = null;
				dLoader = null;
			}
		}
	}
}