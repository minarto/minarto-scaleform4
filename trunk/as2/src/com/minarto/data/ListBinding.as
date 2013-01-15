import com.minarto.data.ListDataBinding;
import flash.external.ExternalInterface;
import gfx.controls.CoreList;
import gfx.data.DataProvider;


class com.minarto.data.ListBinding {
	private static var listDic = {}, listData = {},
	
	
	public static function regist($listKey:String, $list:CoreList):Void{
		if(!$listKey || !$list)	return;
		
		var dic:Array = listDic[$listKey] || (listDic[$listKey] = []);
		for (var i in dic) {
			if (dic[i] == $list)	return;
		}
		dic.push($list);
		
		$list.dataProvider = listData[$listKey];
	}
	
	
	public static function unregist($listKey:String, $list:CoreList):Void{
		if (!$listKey || !$list)	return;
		
		$list.dataProvider = null;
		$list.validateNow();
		
		var dic:Array = listDic[$listKey];
		for (var i in dic) {
			if (dic[i] == $list) {
				dic.splice(i, 1);
				return;
			}
		}
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
				if($index < 0)	dataProvider.push($data)
				else{
					dataProvider[$index] = $data;
				}
				dataProvider.invalidate();
			}
			else{
				dataProvider = [];
				if($index < 0){
					dataProvider[0] = $data;
				}
				else{
					dataProvider[$index] = $data;
				}
				
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
						
						dataProvider.invalidate();
						return;
					}
				}
			}
		}
	}
}