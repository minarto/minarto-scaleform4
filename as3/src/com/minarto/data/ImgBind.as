package com.minarto.data
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	

	public class ImgBind
	{
		static private const imgManager:ImgBind = new ImgBind;
		
		
		static function getInstance():ImgBind
		{
			return	imgManager;
		}
		
		
		protected var gcDic:Dictionary = new Dictionary(true), dic:* = {}, reservations:Array = [], loader:Loader = new Loader
			, urq:URLRequest = new URLRequest, currentVars:*, bind:Bind = new Bind;
		
		
		public function ImgBind()
		{
			var info:LoaderInfo = loader.contentLoaderInfo;
			
			info.addEventListener(Event.COMPLETE, complete);
			info.addEventListener(IOErrorEvent.IO_ERROR, error);
		}
		
		
		/**
		 * 이미지 로드 완료 
		 * @param $bm
		 * @param $src
		 * 
		 */		
		protected function complete($e:Event):void
		{
			var bm:Bitmap = loader.content as Bitmap;
			
			set(currentVars.src, bm ? bm.bitmapData : undefined, currentVars.gc);
		}
		
		
		/**
		 * 이미지 로드 완료 
		 * @param $bm
		 * @param $src
		 * 
		 */		
		protected function error($:IOErrorEvent):void
		{
			set(currentVars.src, undefined, currentVars.gc);
		}
		
		
		/**
		 * 이미지 로드 
		 * @param $src
		 * @param $onComplete
		 * @param $vars
		 * 
		 */		
		public function add($src:String, $onComplete:Function, $vars:*):void
		{
			var onCompleteParams:Array;
			
			if(!$vars)
			{
				$vars = {};
			}
			$vars.src = $src;
			$vars.onComplete = $onComplete;
			
			onCompleteParams = $vars.onCompleteParams;
			if(!onCompleteParams)
			{
				$vars.onCompleteParams = onCompleteParams = [];
			}
			
			reservations.push($vars);
			
			if(!currentVars)
			{
				load();
			}
		}
		
		
		/**
		 * 이미지 로드 
		 * 
		 */		
		protected function load():void
		{
			var src:String, bd:BitmapData, key:String = "onComplete", func:Function, funcParams:Array;
			
			if(currentVars = reservations.shift())
			{
				src = currentVars.src;
				bd = this.get(src);
				if(bd)
				{
					func = currentVars.onComplete;
					if(func)
					{
						funcParams = currentVars[key + "Params"];
						funcParams[0] = bd;
						func.apply(null, funcParams);
					}					
					
					load();
				}
				else
				{
					urq.url = src;
					loader.load(urq);
				}
			}					
		}
		
		
		/**
		 * 직접 bd 등록 
		 * @param $src
		 * @param $bd
		 * @param $gc
		 * 
		 */			
		public function set($src:String, $bd:BitmapData, $gc:Boolean=true):void
		{
			var bd:*, i:uint = reservations.length, args:Array, func:Function, funcParams:Array;
			
			for(bd in gcDic)
			{
				if(gcDic[bd] == $src)
				{
					delete	gcDic[bd];
					break;
				}
			}
			
			if(!$gc)
			{
				dic[$src] = $bd;
			}
			gcDic[$bd] = $src;
			
			while(i --)
			{
				args = reservations[i];
				if(args.src == $src)
				{
					if($bd)
					{
						func = args.onComplete;
						if(func)
						{
							funcParams = args.onCompleteParams;
							funcParams[0] = $bd;
							func.apply(null, funcParams);
						}
					}
					else
					{
						func = args.onError;
						if(func)
						{
							func.apply(null, args.onErrorParams);
						}
					}
					
					reservations.splice(i, 1);
				}
			}
			
			if(currentVars)
			{
				if(currentVars.src == $src)
				{
					if($bd)
					{
						func = currentVars.onComplete;
						if(func)
						{
							funcParams = currentVars.onCompleteParams;
							funcParams[0] = $bd;
							func.apply(null, funcParams);
						}
					}
					else
					{
						func = currentVars.onError;
						if(func)
						{
							func.apply(null, currentVars.onErrorParams);
						}
					}
				}
				
				load();
			}
		}
		
		
		/**
		 * 비트맵 데이터 가져오기 
		 * @param $src
		 * @return 
		 * 
		 */				
		public function get($src:String):BitmapData
		{
			var bd:* = dic[$src];
			
			if(bd)
			{
				return	bd;
			}
			
			for(bd in gcDic)
			{
				if($src == gcDic[bd])
				{
					return	bd;
				}
			}
			
			return	undefined;
		}
		
		
		/**
		 * 등록 삭제
		 * @param $key
		 * @param $v
		 * 
		 */		
		public function del($key:String, $v:*):void 
		{
			var i:uint = reservations.length, args:Array, bd:*;
			
			while(i --)
			{
				args = reservations[i];
				if(args[$key] == $v)
				{
					reservations.splice(i, 1);
				}
			}
			
			if(currentVars && (currentVars[$key] == $v))
			{
				loader.close();
				load();
			}
		}
		
		
		/**
		 * 이미지 경로 가져오기 
		 * @param $bitmapData
		 * 
		 */		
		public function getSrc($bd:BitmapData):String 
		{
			var src:String = gcDic[$bd], bd:*;
			
			if(src)
			{
				return	src;
			}
			
			for(src in dic)
			{
				if(dic[src] == $bd)
				{
					return	src;
				}
			}
			
			return	undefined;
		}
	}
}