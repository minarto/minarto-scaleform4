import gfx.controls.*;
import gfx.managers.FocusHandler;


class com.minarto.ui.KeyBinding {
	private static var onKeyDown:Function, onKeyUp:Function;
	
	
	public static function init():Void {
		if(_init)	_init();
		
		delete init;
	}
	
	
	private static function _init() {
		var keyDic = { }, bindingDic = {}, lastKeys = {}, bindingKeys = {};
		
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
		
		set = function($bindingKey:String, $isDown:Boolean, $key, $combi) {
			var a:Array, i;
			
			if ($bindingKey) {
				if (arguments.length > 1) {
					if (typeof($key) == "string") {
						$key = $key.toUpperCase();
						switch($key) {
							case "CTRL" :
								$key = Key.CONTROL;
								break;
							case "ALT" :
								$key = Key.ALT;
								break;
							case "ESC" :
								$key = Key.ESCAPE;
								break;
							case "F1" :
								$key = 112;
								break;
							case "F2" :
								$key = 113;
								break;
							case "F3" :
								$key = 114;
								break;
							case "F4" :
								$key = 115;
								break;
							case "F5" :
								$key = 116;
								break;
							case "F6" :
								$key = 117;
								break;
							case "F7" :
								$key = 118;
								break;
							case "F8" :
								$key = 119;
								break;
							case "F9" :
								$key = 120;
								break;
							case "F10" :
								$key = 121;
								break;
							case "F11" :
								$key = 122;
								break;
							case "F12" :
								$key = 123;
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
									case "ALT" :
										$combi = Key.ALT;
										break;
									case "ESC" :
										$combi = Key.ESCAPE;
										break;
									case "F1" :
										$combi = 112;
										break;
									case "F2" :
										$combi = 113;
										break;
									case "F3" :
										$combi = 114;
										break;
									case "F4" :
										$combi = 115;
										break;
									case "F5" :
										$combi = 116;
										break;
									case "F6" :
										$combi = 117;
										break;
									case "F7" :
										$combi = 118;
										break;
									case "F8" :
										$combi = 119;
										break;
									case "F9" :
										$combi = 120;
										break;
									case "F10" :
										$combi = 121;
										break;
									case "F11" :
										$combi = 122;
										break;
									case "F12" :
										$combi = 123;
										break;
									default :
										$combi = Key[$combi] || $combi.charCodeAt(0);
								}
							}
							$key = "1." + $key + "." + $combi;
						}
						else	$key = "1." + $key;
					} else	$key = "." + $key;
					
					$combi = keyDic[$key];
					if (!$combi)	keyDic[$key] = $combi = {};
					$combi[$bindingKey] = 1;
					
					a = bindingKeys[$bindingKey];
					if (!a)	bindingKeys[$bindingKey] = a = [];
					
					for (i in a) {
						if (a[i] == $key)	return;
					}
					a.push($key);
				}
				else {
					for ($key in keyDic)	delete	keyDic[$key][$bindingKey];
					
					delete bindingKeys[$bindingKey];
				}
			}
			else	keyDic = { };
		};
		
		
		get = function($bindingKey:String) {
			var key:String, a:Array = bindingKeys[$bindingKey], r:Array = [], i:Number, l:Number;
			
			if (a) {
				for (i = 0, l = a.length; i < l; ++i) {
					r.push(a[i].split("."));
				}
			}
			
			
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