package com.minarto.utils {
	import de.polygonal.core.ObjectPool;
	
	import flash.external.ExternalInterface;
	import flash.geom.*;
	import flash.utils.Dictionary;
	

	public class Utils 	{
		private static var localeDic:* = {};
		
		
		public static var rectangle:Rectangle = new Rectangle;
		
		
		public static var point:Point = new Point;
		
		
		public static function error($type:String, $msg:String):void{
			ExternalInterface.call("error", $type, $msg);
			trace("error - " + $type + " : " + $msg);
		}
		
		
		public static function addComma($n:Number, $cipher:uint = 3):String {
			var s:String, c:uint, i:int, t:String;
			
			if (isNaN($n))	return	s;
			
			s = "" + $n;
			
			c = s.length;
			i = s.indexOf(".", 0) - $cipher;
			if (i < - ($cipher - 1)) i = c - $cipher;
			
			while (i > 0) {
				t = s.substring(0, i);
				if(t === "-")	return	s;
				else	s = t + "," + s.substring(i, c ++);
				
				i -= $cipher;
			}
			
			return	s;
		}
		
		
		public static function locale($msg:String):String {
			var r:String = localeDic[$msg];
			
			if(!r){
				r = ExternalInterface.call("locale", $msg);
				if(r)	localeDic[$msg] = r;
				else	error("locale", $msg);
			}
			
			return	r;
		}
		
		private static var _poolDic:Dictionary = new Dictionary(true);
		
		
		public static function getPool($c:Class, $size:int=-1):ObjectPool{
			var p:ObjectPool = _poolDic[$c];
			
			if(!p){
				if($size < 0){
					p = new ObjectPool(true);
					p.allocate(1, $c);
				}
				else{
					p = new ObjectPool;
					p.allocate($size, $c);
				}
				
				_poolDic[$c] = p;
			}			
			
			return	p;
		}
		
		
		public static function delPool($c:Class):void{
			delete	_poolDic[$c];
		}
	}
}