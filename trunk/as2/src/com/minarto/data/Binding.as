import flash.external.ExternalInterface;
import com.minarto.data.*;
import gfx.events.EventDispatcher;


class com.minarto.data.Binding extends EventDispatcher {
	private static var _valueDic = { }, _bindingDic = { }, _instance:Binding = new Binding;
	
	
	public function Binding() {
		if(_instance)	throw	new Error("don't create instance");
	}
	
	
	/**
	 * 초기화
	 */
	public static function init():Void {
		if(ExternalInterface.available)	ExternalInterface.call("Binding", _instance);
		trace("Binding.init");
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
	
	
	public static function addBind($key:String, $handlerOrProperty:String, $scope):Void {
		if(!$key)	return;
		
		var a:Array = _bindingDic[$key] || (_bindingDic[$key] = []);
		for (var i in a) {
			var o = a[i];
			if (o.obj == $scope) {
				break;
			}
		}
		if (!o) {
			o = { obj:$scope, key: { }};
			a.push(o);
		}
		
		o.key[$handlerOrProperty] = $handlerOrProperty;
	}
		
		
	public static function addBindAndPlay($key:String, $handlerOrProperty:String, $scope):Void {
		if(!$key)	return;
		
		addBind($key, $handlerOrProperty, $scope);
		if($scope){
			$scope[$handlerOrProperty] = _valueDic[$key];
		}
		else{
			$handlerOrProperty(_valueDic[$key]);
		}
	}
		
		
	public static function delBind($key:String, $handlerOrProperty:String, $scope):Void {
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