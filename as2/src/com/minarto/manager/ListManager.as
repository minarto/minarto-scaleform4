import gfx.controls.CoreList;
import gfx.data.DataProvider;


class com.minarto.manager.ListManager {
	private static function _init() {
		var valueDic = { }, listDic = {};
		
		add = function($key:String, $list:CoreList) {
			var a:Array = listDic[$key];
			if (!a)	listDic[$key] = a = [];
			a.push($list);
			
			$list.dataProvider = valueDic[$key];
		}
		
		
		del = function($list:CoreList) {
			var a:Array, i;
			
			if ($list) {
				a = listDic[$key]
				if (a) {
					for (i in a) {
						if (a[i] == $list) {
							a.splice(i, 1);
							if (!a.length)	delete	listDic[$key];
							return;
						}
					}
				}
			}
			else	listDic = { };
		}

		
		set = function($key:String, $datas:Array) {
			var i, a:Array = listDic[$key];
			
			DataProvider.initialize($datas);
			valueDic[$key] = $datas;
			
			for (i in a)	a[i].dataProvider = $datas;
		}
		
		
		get = function() {
			return	valueDic[arguments[0]];
		}
	}
		
		
	public static function add($key:String, $list:CoreList):Void {
		_init();
		add.apply(ListManager, arguments);
	}
		
		
	public static function del($list:CoreList):Void {
		_init();
		del.apply(ListManager, arguments);
	}
		
		
	public static function set($key:String, $datas:Array):Void {
		_init();
		ListManager.set($key, $datas);
	}
		
		
	public static function get($key:String):Array {
		_init();
		return	ListManager.get($key);
	}
}