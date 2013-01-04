/**
 * 
 */
package com.minarto.data {
	import flash.external.ExternalInterface;
	import flash.utils.*;
	
	import scaleform.gfx.Extensions;
	
	
	public class DataBinding {
		private static var valueDic:* = {}, bindingDic:* = {};
		
		
		/**
		 * 초기화
		 * 
		 * @param $timeInterval	시간 데이터 갱신 주기
		 * 
		 */
		public static function init($timeInterval:uint=100):void {
			if(ExternalInterface.available && Extensions.isScaleform)	ExternalInterface.call("DataBinding", DataBinding);
			trace("DataBinding.init");
			
			_setValue("date", new Date);
			setInterval(function():void{
							_setValue("date", new Date);
						}, $timeInterval || 100);
		}
		
		
		/**
		 * 바인딩 
		 * @param $key	바인딩 키
		 * @param $handlerOrProperty	바인딩 핸들러 또는 속성
		 * @param $scope	바인딩 속성 사용시 해당 객체
		 * 
		 */				
		public static function createBinding($key:String, $handlerOrProperty:Object, $scope:Object=null):void {
			if(!$key)	return;
			
			var v:* = valueDic[$key];
			var dic:Dictionary = bindingDic[$key] || (bindingDic[$key] = new Dictionary(true));
			if($scope){
				var f:* = dic[$scope] || (dic[$scope] = {});
				f[$handlerOrProperty] = $handlerOrProperty;
				$scope[$handlerOrProperty] = v;
			}
			else{
				dic[$handlerOrProperty] = $handlerOrProperty;
				$handlerOrProperty(v);
			}
		}
		
		/**
		 * 바인딩 해제
		 * @param $key	바인딩 키
		 * @param $handlerOrProperty	바인딩 핸들러 또는 속성
		 * @param $scope	바인딩 속성 사용시 해당 객체
		 * 
		 */			
		public static function deleteBinding($key:String, $handlerOrProperty:Object, $scope:Object=null):void {
			if($key){
				var dic:Dictionary = bindingDic[$key];
				if(dic){
					var f:* = dic[$scope];
					if(f){
						if($handlerOrProperty){
							delete f[$handlerOrProperty];
						}
						else{
							delete	dic[$scope];
						}
					}
				}
			}
			else{
				bindingDic = {};
			}
		}
		
		
		/**
		 * 값 설정 
		 * @param $key	바인딩 키. null로 설정하면 모든 바인딩 값을 초기화 한다
		 * @param $value	바인딩 값
		 */			
		public static function setValue($key:String, $value:*):void {
			if($key){
				_setValue($key, $value);
			}
			else{
				$value = undefined;
				for($key in valueDic){
					_setValue($key, $value);
				}
			}
		}
		
		
		private static function _setValue($key:String, $value:*):void {
			var f:*, v:*, p:*;
			
			for(p in $value)	_setValue($key + "." + p, $value[p]);
			
			v = valueDic[$key];
			if (v == $value) return;
			valueDic[$key] = $value;
			
			var dic:Dictionary = bindingDic[$key];
			for (p in dic){
				f = dic[p];
				if(f as Function){
					f($value);
				}
				else{
					for (v in f){
						f[v] = $value;
					}
				}
			}
		}
		
		
		/**
		 * 특정 바인딩 값을 가져온다 
		 * @param $key	바인딩키
		 * @return 바인딩 값
		 * 
		 */		
		public static function getValue($key:String):* {
			return	valueDic[$key];
		}
	}
}