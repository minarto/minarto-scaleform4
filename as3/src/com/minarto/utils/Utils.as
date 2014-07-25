package com.minarto.utils {
	import de.polygonal.core.ObjectPool;
	
	import flash.display.GraphicsPath;
	import flash.external.ExternalInterface;
	import flash.geom.*;
	import flash.utils.Dictionary;
	

	public class Utils 	{
		static private const _LOCALE_DIC:* = {}, _POOL_DIC:Dictionary = new Dictionary; 
		
		
		static public const POINT:Point = new Point, RECTANGLE:Rectangle = new Rectangle, RADIAN:Number = Math.PI / 180,
			GRAPHICS_PATH:GraphicsPath = new GraphicsPath(new <int>[], new <Number>[]);
		
		
		static public function LOCALE($msg:String):String {
			var r:String = _LOCALE_DIC[$msg];
			
			if(!r){
				r = ExternalInterface.call("locale", $msg);
				if(r)	_LOCALE_DIC[$msg] = r;
			}
			
			return	r || $msg;
		}
		
		
		static public function POOL($c:Class):ObjectPool{
			var p:ObjectPool = _POOL_DIC[$c];
			
			if(!p){
				p = new ObjectPool(true);
				p.allocate(1, $c);
				_POOL_DIC[$c] = p;
			}			
			
			return	p;
		}
	}
}