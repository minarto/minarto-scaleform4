package com.minarto.utils {
	import de.polygonal.core.ObjectPool;
	import flash.utils.Dictionary;
	
    public class GPool {
		private static var _dic:Dictionary = new Dictionary(true);
		
		private static function _createPool($c:Class, $size:uint):ObjectPool {
			var p:ObjectPool = new ObjectPool(true);
			p.allocate($size, $c);
			_dic[$c] = p;
			
			return	p;
		}
		
		
		public static function getPool($c:Class):ObjectPool {
			return	_dic[$c] || _createPool($c, 1);
		}
		
		
		public static function addPool($c:Class, $size:uint):ObjectPool {
			return	_dic[$c] || _createPool($c, $size);
		}
		
		
		public static function delPool($c:Class):void {
			var p:ObjectPool = _dic[$c];
			if (p) p.deconstruct();
			delete _dic[$c];
		}
	}
}