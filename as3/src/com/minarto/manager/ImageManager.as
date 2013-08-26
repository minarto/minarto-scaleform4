package com.minarto.manager {
	import com.minarto.utils.Utils;
	
	import flash.display.*;
	
	import scaleform.gfx.Extensions;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class ImageManager {
		private static var	dic:* = { }, funDic:* = {};
		
		
		public static function add($src:String, $onComplete:Function):void{
			var bd:BitmapData = dic[$src], a:Array;
			
			if(bd)	$onComplete(bd);
			else{
				a = funDic[$src];
				if(a)	a.push($onComplete);
				else{
					funDic[$src] = a = [$onComplete];
					
					LoadManager.load(Extensions.isScaleform ? "img://" + $src : $src, function($bm:Bitmap):void {
						var i:uint, l:uint;
						
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
		
		public static function get($src:String):BitmapData{
			return	dic[$src];
		}
		
		
		public static function del($srcOrBitmapData:*=null):void {
			var bd:BitmapData, i:*;
			
			if ($srcOrBitmapData){
				if($srcOrBitmapData as String){
					bd = dic[$srcOrBitmapData];
					if(bd){
						bd.dispose();
						delete dic[$srcOrBitmapData];
					}
				}
				else if($srcOrBitmapData as BitmapData){
					for(i in dic){
						bd = dic[i];
						if(bd == $srcOrBitmapData)	bd.dispose();
					}
				}
			}
			else{
				for(i in dic){
					bd = dic[i];
					bd.dispose();
				}
				dic = {};
			}
		}
	}
}