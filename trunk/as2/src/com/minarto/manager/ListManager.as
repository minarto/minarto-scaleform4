import gfx.controls.CoreList;
import gfx.data.DataProvider;


class com.minarto.manager.ListManager {
	private static function _init() {
		var valueDic = { }, listDic:Array = [];
		
		add = function($key:String, $list:CoreList) {
			var i;
			
			$list.__listKey__ = $key;
			for (i in listDic)	if (listDic[i] == $list)	return;
			
			listDic.push($list);
			
			$list.dataProvider = valueDic[$key];
		}
		
		
		del = function($list:CoreList) {
			var i;
			
			for (i in listDic) {
				if (listDic[i] == $list) {
					listDic.splice(i, 1);
					return;
				}
			}
			else	listDic = [];
		}

		
		set = function($key:String, $datas:Array) {
			var i, list:CoreList;
			
			DataProvider.initialize($datas);
			valueDic[$key] = $datas;
			
			for (i in listDic) {
				list = listDic[i];
				if (list.__listKey__ == $key)	list.dataProvider = $datas;
			}
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