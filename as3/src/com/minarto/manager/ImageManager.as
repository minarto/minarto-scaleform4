package com.minarto.manager {
	import com.minarto.utils.Utils;
	
	import flash.display.*;
	
	import scaleform.gfx.Extensions;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class ImageManager {
		private static var	dic:* = { }, funDic:* = {};
		
		
		public static function load($src:String, $onComplete:Function):void{
			var bd:BitmapData = dic[$src], a:Array;
			
			if(bd){
				$onComplete(bd);
			}
			else{
				a = funDic[$src];
				if(a){
					a.push($onComplete);
				}
				else{
					funDic[$src] = a = [$onComplete];
					
					LoadManager.load(Extensions.isScaleform ? "img://" + $src : $src, function($bm:Bitmap):void {
						var bd:BitmapData, i:uint, l:uint;
						
						if($bm){
							bd = $bm.bitmapData;
							dic[$src] = bd;
							Utils.getPool(Bitmap).object = $bm;
							
							for(i = 0, l = a.length; i<l; ++ i)	a[i](bd);
						}
						
						delete	funDic[$src];
					});
				}
			}
		}
		
		
		public static function destroy($src:String=null):void {
			var bd:BitmapData;
			
			if ($src){
				bd = dic[$src];
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