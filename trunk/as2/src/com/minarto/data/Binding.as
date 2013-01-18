﻿import flash.external.ExternalInterface;
import com.minarto.data.*;
import gfx.events.EventDispatcher;


class com.minarto.data.Binding extends EventDispatcher {
	private static var _valueDic = { }, _bindingDic = { }, _instance = new Binding;
	
	
	public function Binding() {
		if(_instance)	throw	new Error("don't create instance");
	}
	
	
	/**
	 * 초기화
	 * 
	 * @param $dateInterval	시간 데이터 갱신 주기 - 값이 0 이상이면 UI 에서 직접 시스템의 시간을 가져다 쓴다. 0이면 클라이언트가 직접 시간 데이터를 넣어줘야 함 
	 * 
	 */
	public static function init($dateInterval:Number):Binding {
		if(ExternalInterface.available)	ExternalInterface.call("Binding", _instance);
		
		if ($dateInterval) {
			_setValue("date", new Date);
			setInterval(function(){
							_setValue("date", new Date);
						}, $dateInterval);
		}
		
					
		trace("Binding.init");
		
		return	_instance;
	}
		
		
	public static function setValue($key:String, $value):Void {
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
	
	
	
	public static function action($e):Void{
		_instance.dispatchEvent($e);
	}
		
		
	private static function _setValue($key:String, $value):Void {
		var o, v, p;
		
		for(p in $value)	_setValue($key + "." + p, $value[p]);
		
		v = _valueDic[$key];
		if (v == $value) return;
		_valueDic[$key] = $value;
		
		var a:Array = _bindingDic[$key];
		for (p in a){
			o = a[p];
			var obj = o.obj;
			var key = o.key;
			for (v in key) {
				if (typeof(obj[v]) == "function") {
					obj[v]($value);
				}
				else {
					obj[v] = $value;
				}
			}
		}
	}
	
	
	public static function addBind($key:String, $scope, $handlerOrProperty:String):Void {
		if(!$key)	return;
		
		var a:Array = _bindingDic[$key] || (_bindingDic[$key] = []);
		for (var i in a) {
			var o = a[i];
			if (o.obj == $scope) {
				break;
			}
		}
		if (!o) a.push((o = { obj:$scope, key: { }}));
		
		o.key[$handlerOrProperty] = $handlerOrProperty;		
		

		i = _valueDic[$key];
		
		if (typeof($scope[$handlerOrProperty]) == "function") {
			$scope[$handlerOrProperty](i);
		}
		else {
			$scope[$handlerOrProperty] = i;
		}
	}
		
		
	public static function delBind($key:String, $scope, $handlerOrProperty:String):Void {
		if($key){
			var a:Array = _bindingDic[$key];
			for (var i in a) {
				var o = a[i];
				if (o.obj == $scope) {
					if ($handlerOrProperty) {
						delete	o.key[$handlerOrProperty];
					}
					else {
						a.splice(i, 1);
					}
				}
			}
		}
		else{
			_bindingDic = {};
		}
	}
		
		
	public static function getValue($key:String) {
		return	_valueDic[$key];
	}
}