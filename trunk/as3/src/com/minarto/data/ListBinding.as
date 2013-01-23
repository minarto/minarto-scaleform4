/**
 * 
 */
package com.minarto.data {
	import com.minarto.utils.GPool;
	
	import de.polygonal.core.ObjectPool;
	
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	
	import scaleform.clik.controls.CoreList;
	import scaleform.clik.data.DataProvider;
	import scaleform.gfx.Extensions;
	
	
	public class ListBinding {
		private static var _listDic:* = {}, _listBindingDic:* = {},
			_dataListKey:Dictionary = new Dictionary(true),	//	아이템이 포함된 리스트의 키를 반환
			_dataBindingDic:Dictionary = new Dictionary(true),	//	모든 아이템의 바인딩 데이터
			_bridge:ListBridge;
		
		
		public function ListBinding(){
			throw	new Error("don't create instance");
		}
		
		
		public static function addListBind($key:String, $listOrScope:*, $property:String=null):void{
			if(!$key)	return;
			
			var dataProvider:DataProvider = _listDic[$key];
			if(!dataProvider)	_listDic[$key] = dataProvider = GPool.getPool(DataProvider).object;
			
			var dic:Dictionary = _listBindingDic[$key] || (_listBindingDic[$key] = new Dictionary(true));
			if($listOrScope as CoreList){
				dic[$listOrScope] = $listOrScope;
				$listOrScope.dataProvider = dataProvider;
			}
			else if($listOrScope as Function){
				dic[$listOrScope] = $listOrScope;
				$listOrScope(dataProvider);
			}
			else {
				var t:* = dic[$listOrScope] || (dic[$listOrScope] = {});
				t[$property] = $property;
				$listOrScope[$property] = dataProvider;
			}
		}
		
		
		public static function delListBind($key:String, $listOrScope:*, $property:String=null):void{
			if($key){
				var dic:Dictionary = _listBindingDic[$key];
				if(dic){
					if($listOrScope as CoreList){
						$listOrScope.dataProvider = null;
						delete	dic[$listOrScope];
					}
					else if($listOrScope as Function){
						$listOrScope(null);
						delete	dic[$listOrScope];
					}
					else{
						var t:* = dic[$listOrScope];
						if(t)	delete	t[$property];
					}
				}
			}
			else{
				_listBindingDic = {};
			}
		}
		
		
		public static function init($bridge:ListBridge):void{
			_bridge = $bridge;
			trace("ListBinding.init");
		}
		
		
		public static function action($e:Event):void{
			_bridge.dispatchEvent($e);
		}
		
		
		/**
		 * 
		 * @param $key
		 * @param $a
		 * 
		 */		
		public static function setList($key:String, $a:Array):void {
			if($key){
				var dataProvider:DataProvider = _listDic[$key];
				if(dataProvider){
					for(var i:* in dataProvider){
						var d:* = dataProvider[i];
						delete _dataListKey[d];
						delete _dataBindingDic[d];
					}
					dataProvider.setSource($a);
				}
				else{
					var p:ObjectPool = GPool.getPool(DataProvider);
					dataProvider = p.object;
					dataProvider.setSource($a);
					_listDic[$key] = dataProvider;
				}
				
				for(i in dataProvider){
					d = dataProvider[i];
					_setData(d, $key);
				}
				
				var dic:Dictionary = _listBindingDic[$key];
				for(i in dic){
					var list:CoreList = d[i];
					if(list.dataProvider == dataProvider){
						dataProvider.invalidate();
					}
					else{
						list.dataProvider = dataProvider;
					}
				}
			}
			else{
				_listDic = {};
				_dataListKey = new Dictionary(true);
				_dataBindingDic = new Dictionary(true);
			}
		}
		
		
		public static function getList($key:String):DataProvider {
			return _listDic[$key];
		}
		
		
		protected static function _setData($data:*, $key:String):void {
			if(!$data)	return;
			
			_dataListKey[$data] = $key;
			_dataBindingDic[$data] = {};
		}
		
		
		public static function addDataBind($data:*, $handler:Function, ...$properties):void {
			if($data){
				$data = _dataBindingDic[$data];
				if($data){
					for(var p:String in $properties){
						var d:Dictionary = $data[$properties[p]] || ($data[$properties[p]] = new Dictionary(true));
						d[$handler] = $handler;
					}
				}
			}
			
			$handler();
		}
		
		
		public static function delDataBind($data:*, $handler:Function, ...$properties):void {
			if(Boolean($handler)){
				$data = _dataBindingDic[$data];
				if($data){
					for(var p:String in $properties){
						var d:Dictionary = $data[$properties[p]];
						if(d)	delete d[$handler];
					}
				}
			}
			else{
				_dataBindingDic = new Dictionary(true);
			}
		}
		
		
		public static function setDataProperty($data:*, $p:String, $value:*):void {
			if(!$data)	return;
			
			$data[$p] = $value;
			
			//	해당 아이템 바인딩
			$value = _dataBindingDic[$data];
			$data = $value[$p];
			for($value in $data){
				$data[$value]();
			}
		}
		
		
		public static function setData($target:*, $data:*, $index:uint=0):void {
			var data:*, key:String, dataProvider:DataProvider;
			
			if($target as String){
				key = $target;
				
				dataProvider = _listDic[key];
				if(dataProvider){
					_setData($data, key);
					
					data = dataProvider[$index];
					if(data){
						delete _dataListKey[data];
						delete _dataBindingDic[data];
					}
					dataProvider[$index] = $data;
					dataProvider.invalidate();
				}
				else{
					var a:Array = [];
					a[$index] = $data;
					setList(key, a);
				}
			}
			else if($target){
				data = $target;
				if(data){
					key = _dataListKey[data];
					delete _dataListKey[data];
					delete _dataBindingDic[data];
					
					dataProvider = _listDic[key];
					dataProvider[(dataProvider as Array).indexOf(data)] = $data;
					
					_setData($data, key);
					
					dataProvider.invalidate();
				}
			}
		}
	}
}