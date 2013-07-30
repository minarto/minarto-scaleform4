package com.minarto.manager {
	import com.minarto.utils.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	

	public class LoadManager {
		private static var loader:Loader, request:URLRequest = new URLRequest(), reservations:Array = [], item:LoadItem;
		
		
		public function LoadManager() {
			throw new Error("don't create instance");
		}
		
		
		public static function load($src:String, $onComplete:Function, $onError:Function=null):void{
			var i:LoadItem, info:LoaderInfo;
			
			if(!$src)	return;
			
			i = Utils.getPool(LoadItem).object;
			i.src = $src;
			i.onComplete = $onComplete;
			i.onError = $onError;
			
			reservations.push(i);
			
			if(!item){
				info = loader.contentLoaderInfo;
				info.addEventListener(Event.COMPLETE, _onComplete);
				info.addEventListener(IOErrorEvent.IO_ERROR, _onError);
					
				_load();
			}
		}
		
		
		public static function unLoad($src:String, $onComplete:Function):void{
			var i:uint, _item:LoadItem, info:LoaderInfo;
			
			if($src){
				if(item && item.src == $src && item.onComplete == $onComplete){
					loader.close();
				}
				
				i = reservations.length;
				while(i --){
					_item = reservations[i];
					if(_item && item.src == $src && _item.onComplete == $onComplete)	reservations.splice(i, 1);
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
		
		
		private static function _load():void {
			var info:LoaderInfo = loader.contentLoaderInfo;
			
			if(item)	Utils.getPool(LoadItem).object = item;
			item = reservations.shift();
			if(item){
				request.url = item.src;
				loader.load(request);
			}
			else{
				info.removeEventListener(Event.COMPLETE, _onComplete);
				info.removeEventListener(IOErrorEvent.IO_ERROR, _onError);
			}
		}
		
		
		private static function _onComplete($e:Event):void {
			item.onComplete(loader.contentLoaderInfo.content);
			_load();
		}
		
		
		private static function _onError($e:IOErrorEvent):void {
			var f:Function = item.onError;
			
			Utils.error(IOErrorEvent.IO_ERROR, item.src);
			
			if(Boolean(f))	f(loader.contentLoaderInfo.content);
			
			_load();
		}
	}
}


internal class LoadItem{
	public var src:String;
	public var onComplete:Function;
	public var onError:Function;
}