import com.minarto.data.*;
import com.minarto.manager.list.ListBridge;
import gfx.controls.CoreList;
import gfx.data.DataProvider;


class com.minarto.data.ListBinding {
	private static var _listDic = { }, _listBindingDic:* = { },
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
	public static function setListData($listKey:String, $a:Array):Void {
		DataProvider.initialize($a);
		
		listData[$listKey] = $a;
		
		var dic:Array = listDic[$listKey];
		for(var i in dic){
			var list:CoreList = dic[i];
			list.dataProvider = null;
			list.dataProvider = $a;
		}
	}
		
		
	public static function action($e):Void{
		_bridge.dispatchEvent($e);
	}
		
		
	public static function getListData($listKey:String):Array {
		return listData[$listKey];
	}
		
		
	public static function addBind($data, $scope, $handler:String, $property:String):Void {
		if ($data) {
			ListDataBinding.bind($data);
			
			var p:Array = arguments.slice(3, arguments.length);
			for ($property in p) {
				$data.addBind($property, $scope, $handler);
			}
		}
	}
		
		
	public static function delBind($data, $scope, $handler:String, $property:String):Void {
		if(!$data)	return;
		
		var p:Array = arguments.slice(3, arguments.length);
		for ($property in p) {
			$data.delBind($property, $scope, $handler);
		}
	}
		
		
	public static function getData($listKey:String, $index:Number){
		var dataProvider = listData[$listKey];
		return	dataProvider ? dataProvider[$index] : dataProvider;
	}
		
		
	public static function setData($target, $data, $index:Number):Void {
		var data, listKey:String, dataProvider:Array;
		
		if($target as String){
			listKey = $target;
			
			dataProvider = listData[listKey];
			if(dataProvider){
				dataProvider[$index] = $data;
				dataProvider.invalidate();
			}
			else{
				dataProvider = [];
				dataProvider[$index] = $data;
				setListData(listKey, dataProvider);
			}
		}
		else if($target){
			data = $target;
			
			for (listKey in listData) {
				dataProvider = listData[listKey];
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