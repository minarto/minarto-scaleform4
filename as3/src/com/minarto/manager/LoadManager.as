package com.minarto.manager {
	import com.minarto.debug.Debug;
	import com.minarto.utils.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	

	public class LoadManager {
		static private var loader:Loader, request:URLRequest = new URLRequest(), reservations:Array = [], item:*;
		
		
		static public function load($src:String, $onComplete:Function, $onError:Function=null):void{
			var info:LoaderInfo;
			
			if(!$src)	return;
			
			reservations.push(arguments);
			
			if(!item){
				//info = loader.contentLoaderInfo;
				//info.addEventListener(Event.COMPLETE, _onComplete);
				//info.addEventListener(IOErrorEvent.IO_ERROR, _onError);
					
				_load();
			}
		}
		
		
		static public function unLoad($src:String, $onComplete:Function):void{
			var i:*, _item:*, info:LoaderInfo;
			
			if($src){
				if(item && item[0] == $src && item[1] == $onComplete)	loader.close();
				
				for(i in reservations){
					_item = reservations[i];
					if(_item && item[0] == $src && _item[1] == $onComplete)	reservations.splice(i, 1);
				}
			}
			else{
				if(item)	loader.close();
				
				info = loader.contentLoaderInfo;
				info.removeEventListener(Event.COMPLETE, _onComplete);
				info.removeEventListener(IOErrorEvent.IO_ERROR, _onError);
				
				reservations.length = 0;
			}
		}
		
		
		static private function _load():void {
			var info:LoaderInfo;
			
			loader = new Loader;
			info = loader.contentLoaderInfo;
			info.addEventListener(Event.COMPLETE, _onComplete);
			info.addEventListener(IOErrorEvent.IO_ERROR, _onError);
			
			item = reservations.shift();
			if(item){
				request.url = item[0];
				loader.load(request);
			}
			else{
				info.removeEventListener(Event.COMPLETE, _onComplete);
				info.removeEventListener(IOErrorEvent.IO_ERROR, _onError);
			}
		}
		
		
		private static function _onComplete($e:Event):void {
			item[1](item[0], loader.contentLoaderInfo.content);
			_load();
		}
		
		
		private static function _onError($e:IOErrorEvent):void {
			var src:String = item[0], f:Function = item[2];
			
			Debug.error(IOErrorEvent.IO_ERROR, src);
			
			if(Boolean(f))	f(src);
			
			_load();
		}
	}
}