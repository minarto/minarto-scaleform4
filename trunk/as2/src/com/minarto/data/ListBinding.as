import com.minarto.data.ListDataBinding;
import flash.external.ExternalInterface;
import gfx.controls.CoreList;
import gfx.data.DataProvider;


class com.minarto.data.ListBinding {
	private static var listDic = {}, listData = {},
							dataListKey = {},	//	아이템이 포함된 리스트의 키를 반환
							dataBindingDic = {};	//	모든 아이템의 바인딩 데이터
	
	
	public static function regist($listKey:String, $list:CoreList):Void{
		if(!$listKey || !$list)	return;
		
		listDic[$listKey] = $list;
		
		var dataProvider = listData[$listKey];
		
		setList($listKey);
		$list.dataProvider = dataProvider;
		$list.validateNow();
	}
	
	
	public static function unregist($listKey:String, $list:CoreList):Void{
		if (!$listKey || !$list)	return;
		
		delete listDic[$listKey];
		
		$list.dataProvider = null;
		$list.validateNow();
	}
		
		
	private static function setList($listKey:String):Void{
		var dataProvider = listData[$listKey];
		for (var i in dataProvider) {
			_setData(dataProvider[i], $listKey);
		}
	}
		
		
	/**
	 * 
	 * @param $listKey
	 * @param $a
	 * 
	 */		
	public static function setListData($listKey:String, $a:Array):Void {
		var dataProvider = listData[$listKey];
		for(var i in dataProvider){
			var data = dataProvider[i];
			delete dataListKey[data];
			delete dataBindingDic[data];
		}
		
		var list:CoreList = listDic[$listKey];
		if (list) {
			list.dataProvider = [$a];
			for(var i in dataProvider){
				var data = dataProvider[i];
				delete dataListKey[data];
				delete dataBindingDic[data];
			}
			dataProvider.setSource($a);
		}
		else{
			dataProvider = new DataProvider($a);
			listData[$listKey] = dataProvider;
		}
		
		setList($listKey);
		
		dataProvider.invalidate();
	}
		
		
	public static function getListData($listKey:String):Array {
		return listData[$listKey];
	}
		
		
	public static function addBind($data, $handler:String, $scope, $property:String):Void {
		if ($data) {
			ListDataBinding.bind($data);
			
			var p:Array = arguments.slice(3, arguments.length);
			for ($property in p) {
				$data.addBind($property, $handler, $scope);
			}
		}
	}
		
		
	public static function delBind($data, $handler:String, $scope, $property:String):Void {
		if(!$data)	return;
		
		var p:Array = arguments.slice(3, arguments.length);
		for ($property in p) {
			$data.delBind($property, $handler, $scope);
		}
	}
}