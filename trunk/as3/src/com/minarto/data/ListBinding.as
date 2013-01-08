/**
 * 
 */
package com.minarto.data {
	import flash.utils.Dictionary;
	
	import scaleform.clik.controls.CoreList;
	import scaleform.clik.data.DataProvider;
	
	
	public class ListBinding {
		protected static var listDic:Dictionary = new Dictionary(true),  listData:* = {},
							dataListKey:Dictionary = new Dictionary(true),	//	아이템이 포함된 리스트의 키를 반환
							dataBindingDic:Dictionary = new Dictionary(true);	//	모든 아이템의 바인딩 데이터
		
		
		public static function regist($listKey:String, $list:CoreList):void{
			if(!$listKey || !$list)	return;
			
			listDic[$list] = $list;
			
			var dataProvider:DataProvider = listData[$listKey] || (listData[$listKey] = new DataProvider);
			
			setList($listKey);
			$list.dataProvider = dataProvider;
			$list.validateNow();
		}
		
		
		public static function unregist($listKey:String, $list:CoreList):void{
			if(!$listKey || !$list)	return;
			
			delete	listDic[$listKey];
			
			$list.dataProvider = null;
			$list.validateNow();
		}
		
		
		protected static function setList($listKey:String):void{
			var dataProvider:DataProvider = listData[$listKey];
			for(var i:* in dataProvider){
				_setData(dataProvider[i], $listKey);
			}
		}
		
		
		/**
		 * 
		 * @param $listKey
		 * @param $a
		 * 
		 */		
		public static function setListData($listKey:String, $a:Array):void {
			var dataProvider:DataProvider = listData[$listKey];
			if(dataProvider){
				for(var i:* in dataProvider){
					var data:* = dataProvider[i];
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
		
		
		public static function getListData($listKey:String):DataProvider {
			return listData[$listKey];
		}
		
		
		public static function getDataListKey($data:*):String {
			return dataListKey[$data];
		}
		
		
		protected static function _setData($data:*, $listKey:String):void {
			if(!$data)	return;
			
			dataListKey[$data] = $listKey;
			dataBindingDic[$data] = {};
		}
		
		
		public static function addBindingData($data:*, $handler:Function, ...$properties):void {
			if($data){
				var binding:* = dataBindingDic[$data];
				if(binding){
					for(var p:String in $properties){
						var d:Dictionary = binding[$properties[p]] || (binding[$properties[p]] = new Dictionary(true));
						d[$handler] = $handler;
					}
				}
			}
			
			$handler();
		}
		
		
		public static function deleBindingData($data:*, $handler:Function, ...$properties):void {
			if(!$data)	return;
			
			var binding:* = dataBindingDic[$data];
			if(binding){
				for(var p:String in $properties){
					var d:Dictionary = binding[$properties[p]];
					if(d)	delete d[$handler];
				}
			}
		}
		
		
		public static function setDataProperty($data:*, $p:String, $value:*):void {
			if(!$data)	return;
			
			$data[$p] = $value;
			
			//	해당 아이템 바인딩
			var binding:* = dataBindingDic[$data];
			var dic:Dictionary = binding[$p];
			for(var h:* in dic){
				dic[h]();
			}
		}
		
		
		public static function getData($listKey:String, $index:int):*{
			var dataProvider:DataProvider = listData[$listKey];
			return	dataProvider ? dataProvider[$index] : undefined;
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
				
				var i:int = (dataProvider as Array).indexOf(data);
				if(i > - 1)	dataProvider.splice(i, 1, $data);
				
				delete dataListKey[data];
				delete dataBindingDic[data];
				
				_setData($data, listKey);
				
				dataProvider.invalidate();
			}
		}
	}
}