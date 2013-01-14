/**
 * 
 */
package com.minarto.data {
	import flash.utils.Dictionary;
	
	import scaleform.clik.controls.CoreList;
	import scaleform.clik.data.DataProvider;
	
	
	public class ListBinding {
		protected static var listDic:* = {},  listData:* = {},
			dataListKey:Dictionary = new Dictionary(true),	//	아이템이 포함된 리스트의 키를 반환
			dataBindingDic:Dictionary = new Dictionary(true);	//	모든 아이템의 바인딩 데이터
		
		
		public static function regist($key:String, $list:CoreList):void{
			if(!$key || !$list)	return;
			
			var dic:Dictionary = listDic[$key] || (listDic[$key] = new Dictionary(true));
			dic[$list] = $list;
			$list.dataProvider = listData[$key];
		}
		
		
		public static function unregist($key:String, $list:CoreList):void{
			if($key){
				if($list){
					var dic:Dictionary = listDic[$key];
					if(dic)	delete	dic[$list];
					
					$list.dataProvider = null;
					$list.validateNow();
				}
				else{
					dic = listDic[$key];
					for(var i:* in dic){
						$list = dic[i];
						
						$list.dataProvider = null;
						$list.validateNow();
						
						delete	dic[i];
					}
					
					delete	listDic[$key];
				}
			}
			else{
				for($key in listDic){
					dic = listDic[$key];
					for(i in dic){
						$list = dic[i];
						$list.dataProvider = null;
						$list.validateNow();
					}
				}
				
				listDic = {};
			}
		}
		
		
		/**
		 * 
		 * @param $key
		 * @param $a
		 * 
		 */		
		public static function setListData($key:String, $a:Array):void {
			if($key){
				var dataProvider:DataProvider = listData[$key];
				if(dataProvider){
					for(var i:* in dataProvider){
						var d:* = dataProvider[i];
						delete dataListKey[d];
						delete dataBindingDic[d];
					}
					dataProvider.setSource($a);
				}
				else{
					listData[$key] = dataProvider = new DataProvider($a);
					var n:Boolean = true;
				}
				
				for(i in dataProvider){
					d = dataProvider[i];
					_setData(d, $key);
				}
				
				if(n){
					d = listDic[$key];
					for(i in d){
						var list:CoreList = d[i];
						list.dataProvider = dataProvider;
					}
				}
				else{
					dataProvider.invalidate();
				}
			}
			else{
				listData = {};
				dataListKey = new Dictionary(true);
				dataBindingDic = new Dictionary(true);
			}
		}
		
		
		public static function getListData($key:String):DataProvider {
			return listData[$key];
		}
		
		
		protected static function _setData($data:*, $key:String):void {
			if(!$data)	return;
			
			dataListKey[$data] = $key;
			dataBindingDic[$data] = {};
		}
		
		
		public static function addBind($data:*, $handler:Function, ...$properties):void {
			if($data){
				$data = dataBindingDic[$data];
				if($data){
					for(var p:String in $properties){
						var d:Dictionary = $data[$properties[p]] || ($data[$properties[p]] = new Dictionary(true));
						d[$handler] = $handler;
					}
				}
			}
			
			$handler();
		}
		
		
		public static function delBind($data:*, $handler:Function, ...$properties):void {
			if(!$data && !Boolean($handler)){
				dataBindingDic = new Dictionary(true);
			}
			else{
				$data = dataBindingDic[$data];
				if($data){
					for(var p:String in $properties){
						var d:Dictionary = $data[$properties[p]];
						if(d)	delete d[$handler];
					}
				}
			}
		}
		
		
		public static function setDataProperty($data:*, $p:String, $value:*):void {
			if(!$data)	return;
			
			$data[$p] = $value;
			
			//	해당 아이템 바인딩
			$value = dataBindingDic[$data];
			$data = $value[$p];
			for($value in $data){
				$data[$value]();
			}
		}
		
		
		public static function setData($target:*, $data:*, $index:int = - 1):void {
			var data:*, listKey:String, dataProvider:DataProvider;
			
			if($target as String){
				listKey = $target;
				
				dataProvider = listData[listKey];
				if(dataProvider){
					_setData($data, listKey);
					if($index < 0)	dataProvider.push($data)
					else{
						data = dataProvider[$index];
						delete dataListKey[data];
						delete dataBindingDic[data];
						
						dataProvider[$index] = $data;
					}
					dataProvider.invalidate();
				}
				else{
					var a:Array = [];
					if($index < 0){
						a[0] = $data;
					}
					else{
						a[$index] = $data;
					}
					
					setListData(listKey, a);
				}
			}
			else if($target){
				data = $target;
				listKey = dataListKey[data];
				dataProvider = listData[listKey];
				
				$index = (dataProvider as Array).indexOf(data);
				if($index > - 1)	dataProvider.splice($index, 1, $data);
				
				delete dataListKey[data];
				delete dataBindingDic[data];
				
				_setData($data, listKey);
				
				dataProvider.invalidate();
			}
		}
	}
}