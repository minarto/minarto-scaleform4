package com.minarto.manager 
{
	import flash.display.*;
	import flash.utils.Dictionary;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class ImageManager 
	{
		static private var _dic:Dictionary = new Dictionary(true), _loadUID:Number, _reservations:* = {};
		
		
		/**
		 * 이미지 로드 완료 
		 * @param $bm
		 * @param $src
		 * 
		 */		
		static private function _onComplete($bm:Bitmap, $src:String):void
		{
			resist($src, $bm ? $bm.bitmapData : null);
		}
		
		
		/**
		 * 이미지 로드 
		 * @param $src
		 * @param $onComplete
		 * @param $args
		 * 
		 */		
		static public function add($src:String, $onComplete:Function, ...$args):Number
		{
			var bd:* = _dic[$src] as BitmapData, a:Array, loadID:Number;
			
			for(bd in _dic)
			{
				if(_dic[bd] == $src)
				{
					$args.unshift(bd);
					$onComplete.apply(null, $args);
					return	NaN;
				}
			}
			
			$args.unshift(loadID = LoadManager.ADD("img", $src, _onComplete, _onComplete, $src), $onComplete);
			
			if(a = _reservations[$src])	a.push($args);
			else	_reservations[$src] = a = [$args];
			
			return	loadID;
		}
		
		
		/**
		 * 직접 bd 등록 
		 * @param $src
		 * @param $bd
		 * 
		 */			
		static public function resist($src:String, $bd:BitmapData):void
		{
			var i:uint, l:uint, args:Array, f:Function;
			
			_dic[$bd] = $src;
			
			if(arguments = _reservations[$src])
			{
				for(l = arguments.length; i<l; ++i)
				{
					args = arguments[i];
					args = args.slice(1);
					f = args[0];
					args[0] = $bd;
					f.apply(null, args);
				}
				
				delete	_reservations[$src];
			}
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
		static public function del($src:String=null, $onComplete:Function=null):void 
		{
			var i:uint, args:Array;
			
			if ($src)
			{
				if($onComplete)
				{
					if(arguments = _reservations[$src])
					{
						i = arguments.length;
						while(i --)
						{
							args = arguments[i];
							if(args[1] == $onComplete)
							{
								arguments.splice(i, 1);
								if(!arguments.length)	delete	_reservations[$src];
							}
						}
					}
				}
				else	delete	_reservations[$src];
			}
			else if($onComplete)
			{
				for($src in _reservations)
				{
					arguments = _reservations[$src];
					i = arguments.length;
					while(i --)
					{
						args = arguments[i];
						if(args[1] == $onComplete)
						{
							arguments.splice(i, 1);
							if(!arguments.length)	delete	_reservations[$src];
						}
					}
				}
			}
			else	_reservations = {};
		}
		
		
		/**
		 * 핸들러 삭제
		 * @param $src
		 * 
		 */		
		static public function delUID($loadID:Number=NaN):void 
		{
			var src:String, i:uint, args:Array;
			
			if ($loadID)
			{
				for(src in _reservations)
				{
					arguments = _reservations[src];
					i = arguments.length;
					while(i --)
					{
						args = arguments[i];
						if(args[0] == $loadID)
						{
							arguments.splice(i, 1);
							if(!arguments.length)	delete	_reservations[src];
						}
					}
				}
			}
			else	_reservations = {};
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