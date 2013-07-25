import flash.external.ExternalInterface;
import gfx.controls.*;
import gfx.managers.FocusHandler;


class com.minarto.ui.KeyBinding {
	private static var onKeyDown:Function, onKeyUp:Function;
	
	
	public static function init($delegateObj):Void {
		_init();
		
		if ($delegateObj)	$delegateObj.setKey = KeyBinding.set;
		else				ExternalInterface.call("KeyBinding", KeyBinding);
		
		trace("KeyBinding.init");
		
		delete init;
	}
	
	
	private static function _init() {
		var combi = {}, keyDic = { }, downDic = {}, upDic = {};
		
		Key.addListener(KeyBinding);
		
		onKeyDown = function() {
			var k:Number, a:Array, i, arg;
			
			arg = FocusHandler.instance.getFocus();
			if (arg instanceof TextField || arg instanceof TextInput || arg instanceof TextArea) return;
			
			k = Key.getCode();
			switch(k) {
				case Key.CONTROL :	combi[k] = 1;	break;
				case Key.ALT :		combi[k] = 1;	break;
				case Key.SHIFT :	combi[k] = 1;	break;
			}
			
			for (i in combi) {
				a = downDic[keyDic[i + "," + k]];
				for (i = 0, k = a ? a.length : 0; i < k; ++ i) {
					arg = a[i];
					arg[2].apply(arg[3], arg[4]);
				}
				return;
			}
			
			a = downDic[keyDic[k]];
			for (i = 0, k = a ? a.length : 0; i < k; ++ i) {
				arg = a[i];
				arg[2].apply(arg[3], arg[4]);
			}
		}
		
		onKeyUp = function() {
			var k:Number, a:Array, i, arg;
			
			arg = FocusHandler.instance.getFocus();
			if (arg instanceof TextField || arg instanceof TextInput || arg instanceof TextArea) return;
			
			k = Key.getCode();
			switch(k) {
				case Key.CONTROL :	delete	combi[k];	break;
				case Key.ALT :		delete	combi[k];	break;
				case Key.SHIFT :	delete	combi[k];	break;
			}
			
			for (i in combi) {
				a = upDic[keyDic[i + "," + k]];
				for (i = 0, k = a ? a.length : 0; i < k; ++ i) {
					arg = a[i];
					arg[2].apply(arg[3], arg[4]);
				}
				return;
			}
			
			a = upDic[keyDic[k]];
			for (i = 0, k = a ? a.length : 0; i < k; ++ i) {
				arg = a[i];
				arg[2].apply(arg[3], arg[4]);
			}
		}
		
		
		has = function($bindingKey:String, $isDown, $handler:Function, $scope) {
			var a:Array = $isDown ? downDic[$bindingKey] : upDic[$bindingKey];
			for ($bindingKey in a) {
				$isDown = a[$bindingKey];
				if ($isDown[2] === $handler && $isDown[3] == $scope) return	$isDown;
			}
			
			return	0;
		}
		
		
		set = function($bindingKey:String, $key, $combi:Number) {
			if ($bindingKey) {
				if (typeof($key) === "string")	$key = $key.toUpperCase().charCodeAt(0);
				keyDic[$combi ? $combi + "," + $key : $key] = $bindingKey;
			}
			else				keyDic = { };
		};
		
		
		add = function($bindingKey:String, $isDown, $handler:Function, $scope) {
			var arg, a:Array;
			
			arguments[4] = arguments.slice(4);
			
			arg = $isDown ? downDic : upDic;
			a = arg[$bindingKey];
			if (a) {
				for ($bindingKey in a) {
					arg = a[$bindingKey];
					if (arg[2] === $handler && arg[3] == $scope) {
						a[$bindingKey] = arguments;
						return;
					}
				}
				a.push(arguments);
			}
			else	arg[$bindingKey] = a = [arguments];
		};
		
		
		del = function($bindingKey:String, $isDown, $handler:Function, $scope):Void {
			var a:Array, i, arg;
			
			if ($bindingKey) {
				a = $isDown ? downDic[$bindingKey] : upDic[$bindingKey];
				for (i in a) {
					arg = a[i];
					if (arg[2] === $handler && arg[3] == $scope) {
						a.splice(i, 1);
						if (!a.length) {
							if ($isDown)	delete	downDic[$bindingKey];
							else			delete	upDic[$bindingKey];
						}					
						return;
					}
				}
			}
			else {
				downDic = {};
				upDic = {};
			}
		};
		
		delete	_init;
	}
	
	
	public static function set($bindingKey:String, $key, $combi:Number):Void {
		_init();
		set.apply(KeyBinding, arguments);
	}
	
	
	public static function has($bindingKey:String, $isDown:Boolean, $handler:Function, $scope):Boolean {
		_init();
		return	has.apply(KeyBinding, arguments);
	}
	
	
	public static function add($bindingKey:String, $isDown:Boolean, $handler:Function, $scope):Void {
		_init();
		add.apply(KeyBinding, arguments);
	}
	
	
	public static function del($bindingKey:String, $isDown:Boolean, $handler:Function, $scope):Void {
		_init();
		del.apply(KeyBinding, arguments);
	}
}