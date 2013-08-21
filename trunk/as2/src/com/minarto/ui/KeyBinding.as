import gfx.controls.*;
import gfx.managers.FocusHandler;


class com.minarto.ui.KeyBinding {
	private static var onKeyDown:Function, onKeyUp:Function;
	
	
	public static function init():Void {
		if(_init)	_init();
		delete init;
	}
	
	
	private static function _init() {
		var keyDic = { }, bindingDic = { }, lastKeys:Array = [], bindingKeys = { }, 
			keyList = { CTRL:Key.CONTROL, ALT:Key.ALT, ESC:Key.ESCAPE, F1:112, F2:113, F3:114, F4:115, F5:116, F6:117, F7:118, F8:119, F9:120, F10:121, F11:122, F12:123 },
			lastKey:Number;
		
		Key.addListener(KeyBinding);
		
		onKeyDown = function() {
			var k:Number, d, bindingKey:String, a:Array, i, l:Number, item:Array, j:Number;
			
			d = FocusHandler.instance.getFocus();
			if (d instanceof TextField || d instanceof TextInput || d instanceof TextArea) return;
			
			k = Key.getCode();
			if (lastKey == k)	return;

			//	키 조합으로 검색
			l = lastKeys.length;
			if (l) {
				for (i in lastKeys) {
					d = keyDic["1." + k + "." + lastKeys[i]];

					for (bindingKey in d) {
						a = bindingDic[bindingKey];
						for (j = 0, l = a ? a.length : 0; j < l; ++ j) {
							item = a[j];
							item[1].apply(item[2], item[3]);
						}
					}
				}
			}
			else {
				d = keyDic["1." + k];

				for (bindingKey in d) {
					a = bindingDic[bindingKey];
					for (j = 0, l = a ? a.length : 0; j < l; ++ j) {
						item = a[j];
						item[1].apply(item[2], item[3]);
					}
				}
			}
			
			lastKey = k;
			lastKeys.push(k);
		}
		
		onKeyUp = function() {
			var d, bindingKey:String, a:Array, i, l:Number, item:Array, k:Number;
			
			lastKey = NaN;
			d = FocusHandler.instance.getFocus();
			if (d instanceof TextField || d instanceof TextInput || d instanceof TextArea) return;
			
			k = Key.getCode();
			
			d = keyDic["." + k];
			for (bindingKey in d) {
				a = bindingDic[bindingKey];
				for (i = 0, l = a ? a.length : 0; i < l; ++ i) {
					item = a[i];
					item[1].apply(item[2], item[3]);
				}
			}
			
			for (i in lastKeys) {
				if (lastKeys[i] == k) {
					lastKeys.splice(i, 1);
					return;
				}
			}
		}
		
		
		isOn = function($on:Boolean) {
			if ($on)	Key.addListener(KeyBinding);
			else	Key.removeListener(KeyBinding);
		}
		
		set = function($bindingKey, $isDown, $key) {
			var combi = arguments[3], k:String, ba, a:Array;
			
			if ($bindingKey) {
				if (arguments.length > 1) {
					if (typeof($key) == "string") {
						$key = $key.toUpperCase();
						$key = Key[$key] || keyList[$key] || $key.charCodeAt(0);
					}
					
					if (combi !== undefined && typeof(combi) == "string") {
						combi = combi.toUpperCase();
						combi = Key[combi] || keyList[combi] || combi.charCodeAt(0);
					}
					
					if (isNaN(combi))	k = $isDown ? "1." + $key : "." + $key;
					else {
						k = $isDown ? "1." + $key + "." + combi : "." + $key + "." + combi;
						
						ba = keyDic[k];
						if (!ba)	keyDic[k] = ba = {};
						ba[$bindingKey] = 1;
						
						k = $isDown ? "1." + combi + "." + $key : "." + combi + "." + $key;
					}

					ba = keyDic[k];
					if (!ba)	keyDic[k] = ba = {};
					ba[$bindingKey] = 1;

					
					ba = bindingKeys[$bindingKey];
					if (!ba)	bindingKeys[$bindingKey] = ba = [];
					
					if (isNaN(combi))	k = $isDown ? "1." + $key : "." + $key;
					else	k = $isDown ? "1." + $key + "." + combi : "." + $key + "." + combi;
					
					a = k.split(".");
					a[1] = Number(a[1]);
					if(a.length > 2)	a[2] = Number(a[2]);
					for (k in ba) {
						combi = ba[k];
						if(combi[0] == a[0] && combi[1] == a[1] && combi[2] == a[2])	return;
					}
					ba.push(a);
				}
				else {
					for (k in keyDic)	delete	keyDic[k][$bindingKey];
					delete bindingKeys[$bindingKey];
				}
			}
			else	keyDic = { };
		};
		
		
		get = function($bindingKey) {
			return	bindingKeys[$bindingKey];
		};
		
		
		add = function($bindingKey:String, $handler:Function, $scope) {
			var a:Array = bindingDic[$bindingKey], i, item:Array;
			
			arguments[3] = arguments.slice(3);
			arguments.length  = 4;
			
			if (a) {
				for (i in a) {
					item = a[i];
					if (item[1] == $handler && item[2] == $scope) {
						a[i] = arguments;
						return;
					}
					a.push(arguments);
				}
			}	else	bindingDic[$bindingKey] = [arguments];
		};
		
		
		del = function($bindingKey:String, $handler:Function, $scope) {
			var a:Array, i, item:Array;
			
			if ($bindingKey) {
				a = bindingDic[$bindingKey];
				for (i in a) {
					item = a[i];
					if (item[1] == $handler && item[2] == $scope) {
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