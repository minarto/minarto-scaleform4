package com.minarto.manager 
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class ImgManager 
	{
		static private const _dic:Dictionary = new Dictionary(true), _reservations:Array = [], loader:Loader = new Loader
			, _urq:URLRequest = new URLRequest;
		
		static private var _currentVars:*;
		
		
		/**
		 * 이미지 로드 완료 
		 * @param $bm
		 * @param $src
		 * 
		 */		
		static private function _complete($e:Event):void
		{
			var bm:Bitmap = loader.content as Bitmap, bd:BitmapData = bm ? bm.bitmapData : undefined, onComplete:Function = _currentVars.onComplete
				, onCompleteParams:Array;
			
			set(_currentVars.src, bd);
			
			if(onComplete)
			{
				onCompleteParams = _currentVars.onCompleteParams;
				if(onCompleteParams)
				{
					onCompleteParams.unshift(bd);
					onComplete.apply(null, onCompleteParams);
				}
				else
				{
					onComplete(bd);
				}
			}
		}
		
		
		/**
		 * 이미지 로드 완료 
		 * @param $bm
		 * @param $src
		 * 
		 */		
		static private function _error($:IOErrorEvent):void
		{
			var bd:BitmapData = undefined, onError:Function = _currentVars.onError, onErrorParams:Array;
			
			set(_currentVars.src, bd);
			
			if(onError)
			{
				onErrorParams = _currentVars.onErrorParams;
				if(onErrorParams)
				{
					onError.apply(null, onErrorParams);
				}
				else
				{
					onError();
				}
			}
		}
		
		
		/**
		 * 이미지 로드 
		 * @param $src
		 * @param $onComplete
		 * @param $args
		 * 
		 */		
		static public function add($src:String, $onComplete:Function, $vars:*=null):void
		{
			var info:LoaderInfo;
			
			if(!$vars)	$vars = {};
			
			$vars.src = $src;
			$vars.onComplete = $onComplete;
			
			_reservations.push($vars);
			
			if(!_currentVars)
			{
				info = loader.contentLoaderInfo;
				if(!info.hasEventListener(Event.COMPLETE))
				{
					info.addEventListener(Event.COMPLETE, _complete);
					info.addEventListener(IOErrorEvent.IO_ERROR, _error);
				}
				
				_load();
			}
		}
		
		
		/**
		 * 이미지 로드 
		 * 
		 */		
		static private function _load():void
		{
			var src:String, bd:BitmapData, onComplete:Function, onCompleteParams:Array;
			
			_currentVars = _reservations.shift();
			
			if(_currentVars)
			{
				src = _currentVars.src;
				bd = get(src);
				if(bd)
				{
					onComplete = _currentVars.onComplete;
					if(onComplete)
					{
						onCompleteParams = _currentVars.onCompleteParams;
						if(onCompleteParams)
						{
							onCompleteParams.unshift(bd);
							onComplete.apply(null, onCompleteParams);
						}
						else
						{
							onComplete(bd);
						}
					}				
					
					_load();
				}
				else
				{
					_urq.url = src;
					loader.load(_urq);
				}
			}					
		}
		
		
		/**
		 * 직접 bd 등록 
		 * @param $src
		 * @param $bd
		 * 
		 */			
		static public function set($src:String, $bd:BitmapData):void
		{
			var bd:*, src:String;
			
			for(bd in _dic)
			{
				if(_dic[bd] == $src)
				{
					delete	_dic[bd];
					break;
				}
			}
			
			_dic[$bd] = $src;
		}
		
		
		/**
		 * 비트맵 데이터 가져오기 
		 * @param $src
		 * @return 
		 * 
		 */				
		static public function get($src:String):BitmapData
		{
			var bd:*;
			
			for(bd in _dic)
			{
				if($src == _dic[bd])	return	bd;
			}
			
			return	undefined;
		}
		
		
		/**
		 * 핸들러 삭제
		 * @param $src
		 * 
		 */		
		static public function del($key:String, $v:*):void 
		{
			var i:uint = _reservations.length, vars:*;
			
			while(i --)
			{
				vars = _reservations[i];
				if(vars[$key] == $v)	_reservations.splice(i, 1);
			}
			
			if(_currentVars && (_currentVars[$key] == $v))
			{
				loader.close();
				_load();
			}
		}
		
		
		/**
		 * 이미지 경로 가져오기 
		 * @param $bitmapData
		 * 
		 */		
		static public function getSrc($bd:BitmapData):String 
		{
			return	_dic[$bd];
		}
	}
}