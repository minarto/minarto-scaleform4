import flash.external.ExternalInterface;
import gfx.controls.*;
import gfx.managers.FocusHandler;


class com.minarto.ui.KeyBinding {
	private static var _keyDic = { }, _downDic = {}, _upDic = {}, onKeyDown:Function, onKeyUp:Function;
	
	
	public static function init($delegateObj):Void {
		if ($delegateObj)	$delegateObj.setKey = setKey;
		else				ExternalInterface.call("KeyBinding", KeyBinding);
		
		trace("KeyBinding.init");
		
		delete KeyBinding.init;
	}
	
	
	public static function setKey($bindingKey:String, $keyCode:Number, $combi:Number):Void {
		var combi = {};
		
		Key.addListener(KeyBinding);
		
		onKeyDown = function() {
			var k:Number, h:Array, i, arg, c:Number;
			
			arg = FocusHandler.instance.getFocus();
			if (arg instanceof TextField || arg instanceof TextInput || arg instanceof TextArea) return;
			
			k = Key.getCode();
			switch(k) {
				case Key.CONTROL :	combi[k] = 1;	break;
				case Key.ALT :		combi[k] = 1;	break;
				case Key.SHIFT :	combi[k] = 1;	break;
			}
			
			for (i in combi) {
				h = _downDic[_keyDic[i + "," + k]];
				for (i = 0, c = h ? h.length : 0; i < c; ++ i) {
					arg = h[i];
					arg[2].call(arg[3]);
				}
				return;
			}
			
			h = _downDic[_keyDic[k]];
			for (i = 0, c = h ? h.length : 0; i < c; ++ i) {
				arg = h[i];
				arg[2].call(arg[3]);
			}
		}
		
		onKeyUp = function() {
			var k:Number, h:Array, i, arg, c:Number;
			
			arg = FocusHandler.instance.getFocus();
			if (arg instanceof TextField || arg instanceof TextInput || arg instanceof TextArea) return;
			
			k = Key.getCode();
			switch(k) {
				case Key.CONTROL :	delete	combi[k];	break;
				case Key.ALT :		delete	combi[k];	break;
				case Key.SHIFT :	delete	combi[k];	break;
			}
			
			for (i in combi) {
				h = _upDic[_keyDic[i + "," + k]];
				for (i = 0, c = h ? h.length : 0; i < c; ++ i) {
					arg = h[i];
					arg[2].call(arg[3]);
				}
				return;
			}
			
			h = _upDic[_keyDic[k]];
			for (i = 0, c = h ? h.length : 0; i < c; ++ i) {
				arg = h[i];
				arg[2].call(arg[3]);
			}
		}
		
		
		setKey = function($bindingKey:String, $keyCode:Number, $combi:Number) {
			if ($bindingKey)	_keyDic[$combi ? $combi + "," + $keyCode : $keyCode] = $bindingKey;
			else				_keyDic = { };
		};
		setKey($bindingKey, $keyCode, $combi);
	}
	
	
	public static function has($bindingKey:String, $isDown, $handler:Function, $scope):Boolean {
		var h:Array, i, arg;
		
		h = $isDown ? _downDic[$bindingKey] : _upDic[$bindingKey];

		for (i in h) {
			arg = h[i];
			if (arg[2] === $handler && arg[3] == $scope) return	true;
		}
		
		return	false;
	}
	
	
	public static function add($bindingKey:String, $isDown, $handler:Function, $scope):Void {
		var h:Array, i, arg;
		
		if ($isDown) {
			h = _downDic[$bindingKey];
			if (!h) {
				_downDic[$bindingKey] = h = [arguments];
				return;
			}
		}
		else {
			h = _upDic[$bindingKey];
			if (!h) {
				_upDic[$bindingKey] = h = [arguments];
				return;
			}
		}
		
		for (i in h) {
			arg = h[i];
			if (arg[2] === $handler && arg[3] == $scope) return;
		}
		h.push(arguments);
	}
	
	
	public static function del($bindingKey:String, $isDown, $handler:Function, $scope):Void {
		var h:Array, i, arg;
		
		if ($bindingKey) {
			h = $isDown ? _downDic[$bindingKey] : _upDic[$bindingKey];
			for (i in h) {
				arg = h[i];
				if (arg[2] === $handler && arg[3] == $scope) {
					h.splice(i, 1);
					if (!h.length) {
						if ($isDown)	delete	_downDic[$bindingKey];
						else			delete	_upDic[$bindingKey];
					}					
					return;
				}
			}
		}
		else {
			if ($isDown)	_downDic = {};
			else			_upDic = {};
		}
	}
}