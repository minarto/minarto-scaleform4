package com.minarto.manager {
	import com.minarto.utils.GPool;
	
	import flash.display.*;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class ImageManager {
		private static var	dic:* = { }, reservations:* = {};
		
		
		public static function load($src:String, $onComplete:Function):void{
			if(!$src || !Boolean($onComplete))	return;
			
			var bd:BitmapData = dic[$src];
			if(bd){
				$onComplete(bd);
			}
			else{
				var a:Array = reservations[$src];
				if(!a){
					a = [];
					reservations[$src] = a;
					
					LoadSourceManager.load("img://" + $src, function($bm:Bitmap):void{
						if($bm){
							var bd:BitmapData = $bm.bitmapData;
							dic[$src] = bd;
							GPool.getPool(Bitmap).object = $bm;
							
							var i:uint = a.length;
							while(i --){
								a[i](bd);
							}
						}
						
						delete	reservations[$src];				
					});
				}
				
				a.push($onComplete);
			}
		}
		
		
		public static function dispose($src:String=null):void {
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