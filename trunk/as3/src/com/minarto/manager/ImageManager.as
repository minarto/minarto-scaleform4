package com.minarto.manager {
	import com.minarto.utils.GPool;
	
	import flash.display.*;
	
	import scaleform.gfx.Extensions;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class ImageManager {
		private static var	dic:* = { }, funDic:* = {};
		
		
		public static function load($src:String, $onComplete:Function):void{
			var bd:BitmapData = dic[$src];
			if(bd){
				$onComplete(bd);
			}
			else{
				var a:Array = funDic[$src];
				if(a){
					a.push($onComplete);
				}
				else{
					a = [];
					a.push($onComplete);
					funDic[$src] = a;
				}
				
				var f:Function = function($bm:Bitmap):void {
					if($bm){
						var bd:BitmapData = $bm.bitmapData;
						dic[$src] = bd;
						GPool.getPool(Bitmap).object = $bm;
						
						for(var i:uint = 0, c:uint = a.length; i<c; ++ i){
							a[i](bd);
						}
					}
					
					delete	funDic[$src];
				}
				
				LoadSourceManager.load(Extensions.isScaleform ? "img://" + $src : $src, f);
			}
		}
		
		
		public static function clear($src:String=null):void {
			if ($src){
				var bd:BitmapData = dic[$src];
				if(bd){
					bd.dispose();
					delete dic[$src];
				}
			}
			else{
				for($src in dic){
					bd = dic[$src];
					bd.dispose();
				}
				dic = {};
			}
		}
	}
}