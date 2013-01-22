import com.minarto.data.*;
import com.minarto.manager.list.ListBridge;
import gfx.controls.CoreList;
import gfx.data.DataProvider;


class com.minarto.data.ListBinding {
	private static var _listDic = { }, _listBindingDic = { },
						_dataListKey:Array = [],	//	아이템이 포함된 리스트의 키를 반환
						_dataBindingDic:Array = [],	//	모든 아이템의 바인딩 데이터
						_bridge:ListBridge;
	
	
	public function ListBinding(){
		throw	new Error("don't create instance");
	}
		
		
	public static function addListBind($key:String, $listOrScope, $property:String):Void{
		if(!$key)	return;
		
		var dataProvider:DataProvider = _listDic[$key];
		if (!dataProvider) {
			var a:Array = [];
			DataProvider.initialize(a);
			_listDic[$key] = dataProvider = a;
		}
		
		var dic:Array = _listBindingDic[$key] || (_listBindingDic[$key] = []);
		if ($listOrScope as CoreList) {
			dic.push($listOrScope);
			$listOrScope.dataProvider = dataProvider;
		}
		else if ($listOrScope[$property] as Function) {
			dic.push($listOrScope);
			$listOrScope[$property](dataProvider);
		}
		else {
			var t:* = dic[$listOrScope] || (dic[$listOrScope] = {});
			t[$property] = $property;
			$listOrScope[$property] = dataProvider;
		}
	}
		
		
	public static function delListBind($key:String, $listOrScope, $property:String):Void{
		if($key){
			var dic:Array = _listBindingDic[$key];
			if(dic){
				if ($listOrScope as CoreList) {
					for (var i in dic) {
						if (dic[i] == $listOrScope) {
							dic.splice(i, 1);
							return;
						}
					}
					$listOrScope.dataProvider = null;
				}
				else if ($property) {
					for (i in dic) {
						if (dic[i] == $listOrScope) {
							dic.splice(i, 1);
							if (typeof($listOrScope[$property]) == "function") {
								$listOrScope[$property](null);
							}
							else {
								$listOrScope[$property] = null;
							}
							return;
						}
					}
				}
				else {
					for (i in dic) {
						if (dic[i] == $listOrScope) {
							dic.splice(i, 1);
							$listOrScope = dic[i];
							for (var j in $listOrScope) {
								if (typeof($listOrScope[j]) == "function") {
									$listOrScope[j](null);
								}
								else {
									$listOrScope[j] = null;
								}
							}
							return;
						}
					}
				}
			}
		}
		else{
			_listBindingDic = {};
		}
	}
		
		
	public static function init($bridge:ListBridge):Void{
		_bridge = $bridge;
		trace("ListBinding.init");
	}
		
		
	/**
	 * 
	 * @param $listKey
	 * @param $a
	 * 
	 */		
	public static function setList($key:String, $a:Array):Void {
		var dataProvider:DataProvider = _listDic[$key];
		if(dataProvider){
			for(var i in dataProvider){
				var d = dataProvider[i];
				delete _dataListKey[d];
				delete _dataBindingDic[d];
			}
		}
		
		DataProvider.initialize($a);
		
		_listDic[$key] = $a;
		
		var dic:Array = _listDic[$listKey];
		for(var i in dic){
			var list:CoreList = dic[i];
			list.dataProvider = null;
			list.dataProvider = $a;
		}
	}
		
		
	public static function action($e):Void{
		_bridge.dispatchEvent($e);
	}
		
		
	public static function getList($key:String):Array {
		return _listDic[$key];
	}
		
		
	private static function _setData($data, $key:String):Void {
		if(!$data)	return;
		
		//_dataListKey[$data] = $key;
		_dataBindingDic.push($data);
	}
	
	
	public static function addDataBind($data:Object, $scope, $handler:String, $property:String):Void {
		if ($data) {
			var ps:Array = arguments.slice(2, arguments.length);
			
			for (var i in ps) {
				$data.addBind(ps[i], $scope, $handler);
			}
			
			_dataBindingDic.push($data);
		}
	}
		
		
	public static function delDataBind($data, $scope, $handler:String, $property:String):Void {
		if ($scope || $handler) {
			if ($data) {
				var ps:Array = arguments.slice(2, arguments.length);
				
				for (var i in ps) {
					$data.delBind(ps[i], $scope, $handler);
				}
			}
		}
		else {
			for (i in _dataBindingDic) {
				$data = _dataBindingDic[i];
				$data.delBind();
			}
		}
	}
		
		
	public static function setData($target, $data, $index:Number):Void {
		var data, key:String, dataProvider:Array;
		
		if($target as String){
			key = $target;
			
			dataProvider = _listDic[key];
			if(dataProvider){
				dataProvider[$index] = $data;
				dataProvider.invalidate();
			}
			else{
				dataProvider = [];
				dataProvider[$index] = $data;
				setList(key, dataProvider);
			}
		}
		else if($target){
			data = $target;
			
			for (key in listData) {
				dataProvider = listData[key];
				for ($index in dataProvider) {
					if (dataProvider[$index] == $target) {
						dataProvider[$index] = $data;
						dataProvider.invalidate();
						return;
					}
				}
			}
		}
	}
}