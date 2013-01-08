package com.minarto.manager {
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	

	public class LoadSourceManager {
		protected static var _instance: LoadSourceManager = new LoadSourceManager;
		
		
		protected var loader:Loader, request:URLRequest = new URLRequest(), reservations:Array = [], functionDic:* = {};
		
		
		public static function getInstance():LoadSourceManager{
			return	_instance;
		}
		
		
		public function LoadSourceManager() {
			if(_instance)	throw new Error("don't create instance");
		}
		
		
		public function load($src:String, $onComplete:Function):void{
			if(!$src)	return;
			
			var dic:Dictionary = functionDic[$src];
			if(dic){
				dic[$onComplete] = $onComplete;
			}
			else{
				dic = new Dictionary;
				dic[$onComplete] = $onComplete;
				functionDic[$src] = dic;
				
				reservations.push($src);
				
				_load();
			}
		}
		
		
		public function close($src:String, $onComplete:Function):void{
			if(!$src)	return;
			
			var dic:Dictionary = functionDic[$src];
			if(dic){
				delete	dic[$onComplete];
			}
			
			if(loader){
				var info:LoaderInfo = loader.contentLoaderInfo;
				info.removeEventListener(Event.COMPLETE, onComplete);
				info.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
				loader = null;
			}
		}
		
		
		protected function _load():void {
			request.url = reservations[0];
			
			if(loader){
				var info:LoaderInfo = loader.contentLoaderInfo;
				info.removeEventListener(Event.COMPLETE, onComplete);
				info.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
			}
			
			
			loader = new Loader;
			info = loader.contentLoaderInfo;
			info.addEventListener(Event.COMPLETE, onComplete);
			info.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			loader.load(request);
		}
		
		
		protected function onComplete($e:Event):void {
			var info:LoaderInfo = loader.contentLoaderInfo;
			
			var content:DisplayObject = info.content;
			
			var src:String = reservations.shift();
			var dic:Dictionary = functionDic[src];
			for(var f:* in dic){
				dic[f](content);
			}
			
			delete	functionDic[src];
			
			info.removeEventListener(Event.COMPLETE, onComplete);
			info.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
			loader = null;
			
			if(reservations.length)	_load();
		}
		
		
		protected function onIoError($e:IOErrorEvent):void {
			DebugManager.error(IOErrorEvent.IO_ERROR, reservations.shift());
			
			if(reservations.length)	_load();
		}
	}
}