/**
 * 
 */
package com.minarto.data {
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	
	import scaleform.clik.controls.CoreList;
	import scaleform.clik.data.DataProvider;
	
	
	public class ListBinding {
		private static var valueDic:* = {}, listDic:* = {}, dataDic:Dictionary = new Dictionary(true);
		
		
		/**
		 * 초기화 및 위임
		 *  
		 * @param $delegateObj	위임 객체
		 *  
		 */		
		public static function init():void{
			ExternalInterface.call("ListBinding", ListBinding);
		}
		
		
		/**
		 * 값 설정 
		 * @param $key	바인딩 키
		 * @param $datas	바인딩 값
		 */
		public static function set($key:String, $datas:Array):void {
			var dataProvider:DataProvider = valueDic[$key];
			
			if(!dataProvider)	valueDic[$key] = dataProvider = new DataProvider();
			dataProvider.setSource($datas);
			for($key in $datas)	dataDic[$datas[$key]] = dataProvider;
			dataProvider.invalidate();
		}
		
		
		/**
		 * 데이터 설정 
		 * @param $key	바인딩 키
		 * @param $datas	바인딩 값
		 */
		public static function setItem($key:String, $data:*, $index:int=NaN):void {
			var dataProvider:DataProvider = valueDic[$key];
			
			if(!dataProvider)	valueDic[$key] = dataProvider = new DataProvider();

			dataDic[$data] = dataProvider;
			if($index > -1)	dataProvider[$index] = $data;
			else	dataProvider.push($data);
			dataProvider.invalidate();
		}
		
		
		/**
		 * 데이터 속성값 설정  
		 * @param $data
		 * @param $prpos
		 * @param $value
		 * @param $args
		 * 
		 */		
		public static function setItemProps($data:*, $prpos:String, $value:*, ...$args):void {
			var dataProvider:DataProvider = dataDic[$data], key:String, a:Array, i:uint, l:uint, arg:Array;
			
			if(!dataProvider)	return;
			$data[$prpos] = $value;
			
			for(i = 0, l = $args.length; i<l;){
				$data[$args[i++]] = $args[i++];
			}
			dataProvider.invalidate();
		}
		
		
		/**
		 * 리스트 추가 
		 * @param $key
		 * @param $list
		 * 
		 */		
		public static function add($key:String, $list:CoreList):void {
			var dataProvider:DataProvider = valueDic[$key], d:Dictionary = listDic[$key];
			
			if(!dataProvider)	valueDic[$key] = dataProvider = new DataProvider();
			
			if(!d)	listDic[$key] = d = new Dictionary(true);
			for ($key in d)	if (d[$key] == $list)	return;
			d[$list] = $list;
			$list.dataProvider = dataProvider;
		}
		
		
		/**
		 * 리스트 추가 및 데이터 바로 적용 
		 * @param $key
		 * @param $list
		 * 
		 */		
		public static function addNPlay($key:String, $list:CoreList):void {
			add($key, $list);
			$list.invalidate();
		}
		
		
		/**
		 * 리스트 삭제 
		 * @param $list
		 * 
		 */		
		public static function del($list:CoreList):void {
			var key:String;
			
			for(key in listDic)	delete	listDic[key][$list];
		}
		
		
		/**
		 * 리스트의 값을 가져온다 
		 * @param $key	키 값
		 * @return 
		 * 
		 */		
		public static function get($key:String):DataProvider {
			return	valueDic[$key];
		}
		
		
		/**
		 * 데이터에 연동된 리스트 바인딩 키를 가져온다 
		 * @param $dataProvider	데이터
		 * @return 바인딩 키
		 * 
		 */		
		public static function getDataKey($dataProvider:DataProvider):String {
			var key:String;
			
			for(key in valueDic)	if(valueDic[key] == $dataProvider)	return	key;

			return	null;
		}
		
		
		/**
		 * 리스트에 연동된 리스트 바인딩 키를 가져온다 
		 * @param $list	리스트
		 * @return 바인딩 키
		 * 
		 */		
		public static function getListKey($list:CoreList):String {
			var key:String;
			
			for(key in listDic)	if(listDic[key][$list])	return	key;
			
			return	null;
		}
	}
}