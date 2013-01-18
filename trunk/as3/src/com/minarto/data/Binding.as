/**
 * 
 */
package com.minarto.data {
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.utils.*;
	
	import scaleform.gfx.Extensions;
	
	
	public class Binding extends EventDispatcher {
		private static var _valueDic:* = {}, _bindingDic:* = {}, _instance:Binding = new Binding;
		
		
		public function Binding(){
			if(_instance)	throw	new Error("don't create instance");
		}
		
		
		/**
		 * 초기화
		 * 
		 * @param $dateInterval	시간 데이터 갱신 주기
		 * 
		 */
		public static function init($dateInterval:uint=10):Binding {
			if(ExternalInterface.available && Extensions.isScaleform)	ExternalInterface.call("Binding", _instance);
			
			_setValue("date", new Date);
			setInterval(function():void{
							_setValue("date", new Date);
						}, $dateInterval || 10);
			
			trace("Binding.init");
			
			return	_instance;
		}
		
		
		public static function action($e:Event):void{
			_instance.dispatchEvent($e);
		}
		
		
		/**
		 * 바인딩 
		 * @param $key	바인딩 키
		 * @param $handlerOrProperty	바인딩 핸들러 또는 속성
		 * @param $scope	바인딩 속성 사용시 해당 객체
		 * 
		 */				
		public static function addBind($key:String, $handlerOrProperty:Object, $scope:Object=null):void {
			var v:* = _valueDic[$key];
			var dic:Dictionary = _bindingDic[$key] || (_bindingDic[$key] = new Dictionary(true));
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
		public static function delBind($key:String, $handlerOrProperty:Object, $scope:Object=null):void {
			if($key){
				var dic:Dictionary = _bindingDic[$key];
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
				_bindingDic = {};
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
				for($key in _valueDic){
					_setValue($key, $value);
				}
			}
		}
		
		
		private static function _setValue($key:String, $value:*):void {
			var f:*, v:*, p:*;
			
			for(p in $value)	_setValue($key + "." + p, $value[p]);
			
			v = _valueDic[$key];
			if (v == $value) return;
			_valueDic[$key] = $value;
			
			var dic:Dictionary = _bindingDic[$key];
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
			return	_valueDic[$key];
		}
	}
}