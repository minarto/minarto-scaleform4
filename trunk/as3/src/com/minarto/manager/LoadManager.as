package com.minarto.manager {
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	

	public class LoadManager {
		static private const _DA_LOADER:URLLoader = new URLLoader, _REQUEST:URLRequest = new URLRequest, _RESERVATIONS:Array = [];
		
		
		static private var _CURRENT_LOAD_ITEM:Array, _DO_LOADER:Loader = new Loader, _LOAD_ID:Number = 0;
		
		
		/**
		 * 로드 
		 * @param $type
		 * @param $src
		 * @param $onComplete
		 * @param $onError
		 * @param $args
		 * @return 
		 * 
		 */		
		static public function ADD($type:String, $src:String, $onComplete:Function, $onError:Function=null, ...$args):Number{
			var info:LoaderInfo;
			
			$args.unshift($type, $src, $onComplete, $onError, ++ _LOAD_ID);
			_RESERVATIONS.push($args);
			
			if(!_CURRENT_LOAD_ITEM){
				_DA_LOADER.addEventListener(Event.COMPLETE, _OnComplete);
				_DA_LOADER.addEventListener(IOErrorEvent.IO_ERROR, _OnError);
				
				_DO_LOADER = new Loader;
				info = _DO_LOADER.contentLoaderInfo;
				info.addEventListener(Event.COMPLETE, _OnComplete);
				info.addEventListener(IOErrorEvent.IO_ERROR, _OnError);
				
				_ADD();
			}
			
			return	_LOAD_ID;
		}
		
		
		/**
		 * 로드 id로 삭제 
		 * @param $loadID
		 * 
		 */		
		static public function DEL($loadID:Number):void{
			var i:uint;
			
			if(_CURRENT_LOAD_ITEM){
				if($loadID){
					if(_CURRENT_LOAD_ITEM[4] == $loadID){
						switch(_CURRENT_LOAD_ITEM[0]){
							case "xml" :
							case "txt" :
								_DA_LOADER.close();
								break;
							
							default :
								_DO_LOADER.close();
						}
						_ADD();
					}
					else{
						i = _RESERVATIONS.length;
						while(i --){
							arguments = _RESERVATIONS[i];
							if(arguments[4] == $loadID){
								_RESERVATIONS.splice(i, 1);
								return;
							}
						}
					}
				}
				else{
					_RESERVATIONS.length = 0;
					
					switch(_CURRENT_LOAD_ITEM[0]){
						case "xml" :
						case "txt" :
							_DA_LOADER.close();
							break;
						
						default :
							_DO_LOADER.close();
					}
					
					_ADD();
				}
			}
		}
		
		
		/**
		 * 로드 url로 삭제 
		 * @param $url
		 * 
		 */		
		static public function DEL_URL($url:String):void{
			var i:uint;
			
			if(_CURRENT_LOAD_ITEM){
				if($url){
					if(_CURRENT_LOAD_ITEM[1] == $url){
						switch(_CURRENT_LOAD_ITEM[0]){
							case "xml" :
							case "txt" :
								_DA_LOADER.close();
								break;
							
							default :
								_DO_LOADER.close();
						}
						_ADD();
					}
					else{
						i = _RESERVATIONS.length;
						while(i --){
							arguments = _RESERVATIONS[i];
							if(arguments[1] == $url)	_RESERVATIONS.splice(i, 1);
						}
					}
				}
				else{
					_RESERVATIONS.length = 0;
					
					switch(_CURRENT_LOAD_ITEM[0]){
						case "xml" :
						case "txt" :
							_DA_LOADER.close();
							break;
						
						default :
							_DO_LOADER.close();
					}
					
					_ADD();
				}
			}
		}
		
		
		static private function _OnComplete($e:Event):void{
			var data:*;
			
			switch(_CURRENT_LOAD_ITEM[0]){
				case "xml" :
					try{
						data = XML(_DA_LOADER.data);
					}
					catch($error:Error){}
					
					break;
				
				case "txt" :
					data = _DA_LOADER.data;
					break;
				
				default :
					data = _DO_LOADER.content;
			}
			
			arguments = _CURRENT_LOAD_ITEM.slice(4);
			arguments[0] = data;
			_CURRENT_LOAD_ITEM[2].apply(null, arguments);
			
			_ADD();
		}
		
		
		static private function _OnError($e:IOErrorEvent):void {
			var f:Function = _CURRENT_LOAD_ITEM[3];
			
			if(f){
				arguments = _CURRENT_LOAD_ITEM.slice(4);
				arguments[0] = null;
				f.apply(null, arguments);
			}
			_ADD();
		}
		
		
		static private function _ADD():void {
			var info:LoaderInfo, type:String;
			
			if(_CURRENT_LOAD_ITEM){
				type = _CURRENT_LOAD_ITEM[0];
				
				if(type != "xml" && type != "txt"){
					info = _DO_LOADER.contentLoaderInfo;
					info.removeEventListener(Event.COMPLETE, _OnComplete);
					info.removeEventListener(IOErrorEvent.IO_ERROR, _OnError);
				}
			}
			
			if(_CURRENT_LOAD_ITEM = _RESERVATIONS.shift()){
				type = _CURRENT_LOAD_ITEM[0];
				_REQUEST.url = _CURRENT_LOAD_ITEM[1];
				
				switch(type){
					case "xml" :
					case "txt" :
						_DA_LOADER.load(_REQUEST);
						break;
					
					default :
						_DO_LOADER = new Loader;
						_DO_LOADER.load(_REQUEST);
						
						info = _DO_LOADER.contentLoaderInfo;
						info.addEventListener(Event.COMPLETE, _OnComplete);
						info.addEventListener(IOErrorEvent.IO_ERROR, _OnError);
				}
			}
			else{
				_DA_LOADER.removeEventListener(Event.COMPLETE, _OnComplete);
				_DA_LOADER.removeEventListener(IOErrorEvent.IO_ERROR, _OnError);
			}
		}
	}
}