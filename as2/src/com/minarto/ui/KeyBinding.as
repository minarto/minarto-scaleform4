import gfx.controls.*;
import gfx.managers.FocusHandler;


class com.minarto.ui.KeyBinding {
	private static var onKeyDown:Function, onKeyUp:Function;
	
	
	public static function init():Void {
		if(_init)	_init();
		delete init;
	}
	
	
	private static function _init() {
		var keyDic = { }, bindingDic = {}, lastKeys = {};
		
		Key.addListener(KeyBinding);
		
		onKeyDown = function() {
			var k:Number, d, lastKey:String, bindingKey:String, a:Array, i:Number, l:Number, arg:Array;
			
			d = FocusHandler.instance.getFocus();
			if (d instanceof TextField || d instanceof TextInput || d instanceof TextArea) return;
			
			k = Key.getCode();
			if (lastKeys[k])	return;
			
			//	눌러진 키로 검색
			d = keyDic["1." + k];
			for (bindingKey in d) {
				a = bindingDic[bindingKey];
				for (i = 0, l = a ? a.length : 0; i < l; ++ i) {
					arg = a[i];
					arg[1].apply(arg[2], arg[3]);
				}
			}
			
			//	키 조합으로 검색
			for (lastKey in lastKeys) {
				d = keyDic["1." + k + "." + lastKey];
				for (bindingKey in d) {
					a = bindingDic[bindingKey];
					for (i = 0, l = a ? a.length : 0; i < l; ++ i) {
						arg = a[i];
						arg[1].apply(arg[2], arg[3]);
					}
				}
				
				//	키 반대 조합으로 다시 검색
				d = keyDic["1." + lastKey + "." + k];
				for (bindingKey in d) {
					a = bindingDic[bindingKey];
					for (i = 0, l = a ? a.length : 0; i < l; ++ i) {
						arg = a[i];
						arg[1].apply(arg[2], arg[3]);
					}
				}
			}
			
			lastKeys[k] = 1;
		}
		
		onKeyUp = function() {
			var d, bindingKey:String, a:Array, i, l:Number, arg:Array;
			
			d = FocusHandler.instance.getFocus();
			if (d instanceof TextField || d instanceof TextInput || d instanceof TextArea) return;
			
			d = Key.getCode();
			delete	lastKeys[d];
			
			d = keyDic["." + d];
			for (bindingKey in d) {
				a = bindingDic[bindingKey];
				for (i = 0, l = a ? a.length : 0; i < l; ++ i) {
					arg = a[i];
					arg[1].apply(arg[2], arg[3]);
				}
			}
		}
		
		
		isOn = function($on:Boolean) {
			if ($on)	Key.addListener(KeyBinding);
			else	Key.removeListener(KeyBinding);
		}
		
		set = function($bindingKey:String, $isDown:Boolean, $key, $combi) {
			if ($bindingKey) {
				if (arguments.length > 1) {
					if (typeof($key) == "string") {
						$key = $key.toUpperCase();
						switch($key) {
							case "CTRL" :
								$key = Key.CONTROL;
								break;
							case "ESC" :
								$key = Key.ESCAPE;
								break;
							default :
								$key = Key[$key] || $key.charCodeAt(0);
						}
					}
					
					if ($isDown) {
						if (arguments.length > 3) {
							if (typeof($combi) == "string") {
								$combi = $combi.toUpperCase();
								switch($combi) {
									case "CTRL" :
										$combi = Key.CONTROL;
										break;
									case "ESC" :
										$combi = Key.ESCAPE;
										break;
									default :
										$combi = Key[$combi] || $combi.charCodeAt(0);
								}
							}
						}
						
						$key = isNaN($combi) ? "1." + $key : "1." + $key + "." + $combi;
					} else	$key = "." + $key;
					
					$combi = keyDic[$key];
					if (!$combi)	keyDic[$key] = $combi = {};
					$combi[$bindingKey] = 1;
				}
				else	for ($key in keyDic)	delete	keyDic[$key][$bindingKey];
			}
			else	keyDic = { };
		};
		
		
		get = function($bindingKey:String) {
			var key:String, a:Array = [];
			
			for (key in keyDic)	if (keyDic[key][$bindingKey])	a.push(key.split("."));
			
			return	a;
		};
		
		
		add = function($bindingKey:String, $handler:Function, $scope) {
			var a:Array = bindingDic[$bindingKey], i, arg:Array;
			
			arguments[3] = arguments.slice(3);
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
		KeyBinding.set($bindingKey, $isDown, $key, $combi);
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