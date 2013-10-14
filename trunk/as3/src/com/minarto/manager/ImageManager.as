package com.minarto.manager {
	import com.minarto.utils.Utils;
	
	import flash.display.*;
	
	import scaleform.gfx.Extensions;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class ImageManager {
		static private var	dic:* = { };
		
		
		static private function _onComplete($src:String, $bm:Bitmap):void{
			var bd:BitmapData, a:Array = dic[$src], i:*;
			
			if($bm){
				bd = $bm.bitmapData;
				dic[$src] = bd;
				for(i in a)	a[i](bd);
			}
		}
		
		
		static public function load($src:String, $onComplete:Function):void{
			var bd:BitmapData = get($src), a:Array;
			
			if(bd)	$onComplete(bd);
			else{
				a = dic[$src];
				if(a)	a.push($onComplete);
				else{
					dic[$src] = a = [$onComplete];
					LoadManager.load(Extensions.isScaleform ? "img://" + $src : $src, _onComplete);
				}
			}
		}
		
		
		static public function get($src:String):BitmapData{
			return	dic[$src] as BitmapData;
		}
		
		
		static public function unLoad($src:*=null):void {
			var bd:BitmapData;
			
			if ($src){
				if($src as String){
					bd = get($src);
					if(bd){
						bd.dispose();
						delete dic[$src];
					}
				}
				else{
					bd = $src as BitmapData;
					if(bd){
						for($src in dic){
							if(bd == dic[$src]){
								bd.dispose();
								delete dic[$src];
							}
						}
					}
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