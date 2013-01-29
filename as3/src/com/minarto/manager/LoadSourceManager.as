package com.minarto.manager {
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	

	public class LoadSourceManager {
		private static var loader:Loader, request:URLRequest = new URLRequest(), reservations:Array = [], currentURL:String, currentComplete:Function;
		
		
		public static function getURL():String{
			return	currentURL;
		}
		
		
		public function LoadSourceManager() {
			throw new Error("don't create instance");
		}
		
		
		public static function load($src:String, $onComplete:Function, ...$srcAndOnComplete):void{
			if(!$src)	return;
			
			reservations.push($src, $onComplete);
			reservations.push.apply(null, $srcAndOnComplete);
			
			if(!loader)	_load();
		}
		
		
		public static function unLoad($src:String, $onComplete:Function):void{
			if($src){
				if(loader && (currentURL == $src && currentComplete == $onComplete)){
					loader.close();
					
					var info:LoaderInfo = loader.contentLoaderInfo;
					info.removeEventListener(Event.COMPLETE, _onComplete);
					info.removeEventListener(IOErrorEvent.IO_ERROR, _onIoError);

					loader = null;
					currentURL = null;
					currentComplete = null;
				}
				
				var i:int = reservations.indexOf($src);
				while(i > - 1 && reservations[i + 1] == $onComplete){
					reservations.splice(i, 2);
					i = reservations.indexOf($src, i + 1);
				}
			}
			else{
				if(loader){
					loader.close();
					
					info = loader.contentLoaderInfo;
					info.removeEventListener(Event.COMPLETE, _onComplete);
					info.removeEventListener(IOErrorEvent.IO_ERROR, _onIoError);
					
					loader = null;
					currentURL = null;
					currentComplete = null;
				}
				
				reservations.length = 0;
			}			
		}
		
		
		public static function clear():void{
			reservations.length = 0;
			
			if(loader){
				loader.close();
				
				var info:LoaderInfo = loader.contentLoaderInfo;
				info.removeEventListener(Event.COMPLETE, _onComplete);
				info.removeEventListener(IOErrorEvent.IO_ERROR, _onIoError);
				
				loader = null;
				currentURL = null;
				currentComplete = null;
			}
		}
		
		
		private static function _load():void {
			request.url = currentURL = reservations[0];
			currentComplete = reservations[1];
			
			reservations = reservations.slice(2, reservations.length);
			
			loader = new Loader;
			
			var info:LoaderInfo = loader.contentLoaderInfo;
			info.addEventListener(Event.COMPLETE, _onComplete);
			info.addEventListener(IOErrorEvent.IO_ERROR, _onIoError);
			
			loader.load(request);
		}
		
		
		private static function _onComplete($e:Event):void {
			var info:LoaderInfo = loader.contentLoaderInfo;
			
			currentComplete(info.content);
			
			info.removeEventListener(Event.COMPLETE, _onComplete);
			info.removeEventListener(IOErrorEvent.IO_ERROR, _onIoError);
			
			loader = null;
			currentURL = null;
			currentComplete = null;
			
			if(reservations.length)	_load();
		}
		
		
		private static function _onIoError($e:IOErrorEvent):void {
			DebugManager.error(IOErrorEvent.IO_ERROR, currentURL);
			
			var info:LoaderInfo = loader.contentLoaderInfo;
			info.removeEventListener(Event.COMPLETE, _onComplete);
			info.removeEventListener(IOErrorEvent.IO_ERROR, _onIoError);

			loader = null;
			currentURL = null;
			currentComplete = null;
			
			if(reservations.length)	_load();
		}
	}
}