import gfx.controls.*;
import gfx.managers.FocusHandler;


class com.minarto.ui.KeyBinding {
	private static var onKeyDown:Function, onKeyUp:Function;
	
	
	public static function init():Void {
		if(_init)	_init();
		delete init;
	}
	
	
	private static function _init() {
		var keyDic = { }, bindingDic = { }, lastKeys = { }, bindingKeys = { }, 
			keyList = { CTRL:Key.CONTROL, ALT:Key.ALT, ESC:Key.ESCAPE, F1:112, F2:113, F3:114, F4:115, F5:116, F6:117, F7:118, F8:119, F9:120, F10:121, F11:122, F12:123};
		
		Key.addListener(KeyBinding);
		
		onKeyDown = function() {
			var k, d, lastKey:String, bindingKey:String, a:Array, i:Number, l:Number, item:Array, arg:Array;
			
			d = FocusHandler.instance.getFocus();
			if (d instanceof TextField || d instanceof TextInput || d instanceof TextArea) return;
			
			k = Key.getCode();
			if (lastKeys[k])	return;
			
			k = "1." + k;
			//	눌러진 키로 검색
			d = keyDic[k];
			for (bindingKey in d) {
				a = bindingDic[bindingKey];
				for (i = 0, l = a ? a.length : 0; i < l; ++ i) {
					item = a[i];
					arg = item[3];
					arg[0] = k;
					item[1].apply(item[2], arg);
				}
			}
			
			//	키 조합으로 검색
			for (lastKey in lastKeys) {
				k = "1." + k + "." + lastKey;
				d = keyDic[k];
				for (bindingKey in d) {
					a = bindingDic[bindingKey];
					for (i = 0, l = a ? a.length : 0; i < l; ++ i) {
						item = a[i];
						arg = item[3];
						arg[0] = k;
						item[1].apply(item[2], arg);
					}
				}
				
				//	키 반대 조합으로 다시 검색
				k = "1." + lastKey + "." + k;
				d = keyDic[k];
				for (bindingKey in d) {
					a = bindingDic[bindingKey];
					for (i = 0, l = a ? a.length : 0; i < l; ++ i) {
						item = a[i];
						arg = item[3];
						arg[0] = k;
						item[1].apply(item[2], arg);
					}
				}
			}
			
			lastKeys[k] = 1;
		}
		
		onKeyUp = function() {
			var d, bindingKey:String, a:Array, i:Number, l:Number, item:Array, arg:Array, k:String;
			
			d = FocusHandler.instance.getFocus();
			if (d instanceof TextField || d instanceof TextInput || d instanceof TextArea) return;
			
			d = Key.getCode();
			delete	lastKeys[d];
			
			k = "." + d;
			d = keyDic[k];
			for (bindingKey in d) {
				a = bindingDic[bindingKey];
				for (i = 0, l = a ? a.length : 0; i < l; ++ i) {
					item = a[i];
					arg = item[3];
					arg[0] = k;
					item[1].apply(item[2], arg);
				}
			}
		}
		
		
		isOn = function($on:Boolean) {
			if ($on)	Key.addListener(KeyBinding);
			else	Key.removeListener(KeyBinding);
		}
		
		set = function($bindingKey, $isDown, $key) {
			var combi = arguments[3];
			
			if ($bindingKey) {
				if (arguments.length > 1) {
					if (typeof($key) == "string") {
						$key = $key.toUpperCase();
						$key = Key[$key] || keyList[$key] || $key.charCodeAt(0);
					}
					
					if ($isDown) {
						if (arguments.length > 3) {
							if (typeof(combi) == "string") {
								combi = combi.toUpperCase();
								combi = Key[combi] || keyList[combi] || combi.charCodeAt(0);
							}
							$key = "1." + $key + "." + combi;
						}
						else	$key = "1." + $key;
					} else	$key = "." + $key;
					
					combi = keyDic[$key];
					if (!combi)	keyDic[$key] = combi = {};
					combi[$bindingKey] = 1;
					
					combi = bindingKeys[$bindingKey];
					if (!combi)	bindingKeys[$bindingKey] = combi = [];
					
					for ($isDown in combi)	if (combi[$isDown] == $key)	return;
					combi.push($key);
				}
				else {
					for ($key in keyDic)	delete	keyDic[$key][$bindingKey];
					delete bindingKeys[$bindingKey];
				}
			}
			else	keyDic = { };
		};
		
		
		get = function($bindingKey) {
			var r:Array = [], i:Number, l:Number;
			
			$bindingKey = bindingKeys[$bindingKey]
			for (i = 0, l = $bindingKey ? $bindingKey.length : 0; i < l; ++i)	r.push($bindingKey[i].split("."));
			
			return	r;
		};
		
		
		add = function($bindingKey:String, $handler:Function, $scope) {
			var a:Array = bindingDic[$bindingKey], i, arg:Array;
			
			arguments[3] = arguments.slice(2);
			arguments.length  = 4;
			
			if (a) {
				for (i in a) {
					arg = a[i];
					if (arg[1] == $handler && arg[2] == $scope) {
						a[i] = arguments;
						return;
					}
					a.push(arguments);
				}
			}	else	bindingDic[$bindingKey] = a = [arguments];
		};
		
		
		del = function($bindingKey:String, $handler:Function, $scope) {
			var a:Array, i, arg:Array;
			
			if ($bindingKey) {
				a = bindingDic[$bindingKey];
				for (i in a) {
					arg = a[i];
					if (arg[1] == $handler && arg[2] == $scope) {
						a.splice(i, 1);
						if (!a.length)	delete	bindingDic[$bindingKey];
						return;
					}
				}
			}	else	bindingDic = {};
		};
		
		delete	_init;
	}
	
	
	public static function isOn($on:Boolean):Void {
		_init();
		isOn($on);
	}
	
	
	public static function set($bindingKey:String, $isDown:Boolean, $key, $combi):Void {
		_init();
		KeyBinding.set.apply(KeyBinding, arguments);
	}
	
	
	public static function get($bindingKey:String):Array {
		_init();
		return	KeyBinding.get($bindingKey);
	}
	
	
	public static function add($bindingKey:String, $handler:Function, $scope):Void {
		_init();
		add.apply(KeyBinding, arguments);
	}
	
	
	public static function del($bindingKey:String, $handler:Function, $scope):Void {
		_init();
		del($bindingKey, $handler, $scope);
	}
}