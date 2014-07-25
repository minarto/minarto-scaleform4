package com.minarto.manager {
	import flash.display.*;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class ImageManager {
		static private const _DIC:* = { };
		
		
		/**
		 * 이미지 로드 완료 
		 * @param $bm
		 * @param $src
		 * 
		 */		
		static private function _OnComplete($bm:Bitmap, $src:String):void{
			var bd:BitmapData, f:Function, args:Array, i:uint, l:uint;
			
			arguments = _DIC[$src];
			if($bm)	bd = $bm.bitmapData;
			
			_DIC[$src] = bd;
			
			for(l = arguments.length; i<l; ++i){
				args = arguments[i];
				f = args[0];
				args[0] = bd;
				f.apply(null, args);
			}
		}
		
		
		/**
		 * 이미지 로드 
		 * @param $src
		 * @param $onComplete
		 * @param $args
		 * 
		 */		
		static public function ADD($src:String, $onComplete:Function, ...$args):void{
			var bd:BitmapData = _DIC[$src] as BitmapData, a:Array;
			
			if($src){
				if(bd){
					$args.unshift(bd);
					$onComplete.apply(null, $args);
				}
				else{
					$args.unshift($onComplete);
					a = _DIC[$src] as Array;
					if(a)	a.push($args);
					else{
						_DIC[$src] = a = [$args];
						a["loadID"] = LoadManager.ADD("img", $src, _OnComplete, _OnComplete, $src);
					}
				}
			}
			else{
				$args.unshift(bd);
				$onComplete.apply(null, $args);
			}
		}
		
		
		/**
		 * 이미지 파괴 
		 * @param $src
		 * 
		 */		
		static public function DEL($src:String=null):void {
			var bd:BitmapData;
			
			if ($src){
				if(bd = _DIC[$src] as BitmapData){
					bd.dispose();
					delete _DIC[$src];
				}
				else if(arguments = _DIC[$src] as Array){
					LoadManager.DEL(arguments["loadID"]);
					delete _DIC[$src];
				}
			}
			else{
				for($src in _DIC){
					if(bd = _DIC[$src] as BitmapData)	bd.dispose();
					else if(arguments = _DIC[$src] as Array){
						LoadManager.DEL(arguments["loadID"]);
						delete _DIC[$src];
					}
				}
			}
		}
	}
}