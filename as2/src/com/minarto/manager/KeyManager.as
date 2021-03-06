import com.minarto.data.*;
import com.minarto.managers.*;

import gfx.controls.*;
import gfx.managers.FocusHandler;


class com.minarto.managers.KeyManager extends Key
{
	static private var binding:Binding, keyMap = {}, _isShift:Boolean = false, _isControl:Boolean = false, _isAlt:Boolean = false, _lastKey:String, _isEnable:Boolean;
	
	
	static public var repeat:Boolean;
	

	static public function init($enable:Boolean):Void
	{
		binding = BindingDic.get("KeyManager");
		
		if ($enable)
		{
			addListener(KeyManager);
		}
		else
		{
			removeListener(KeyManager);
		}
	}
	

	static public function getEnable():Boolean
	{
		return	_isEnable;
	}
	

	static private function onKeyDown ():Void
	{
		var f = FocusHandler.instance.getFocus(0), keyCode:Number, e:String;
		
		if (TextField(f) || TextInput(f) || TextArea(f))	return;
		
		keyCode = Key.getCode();
		switch(keyCode)
		{
			case Key.SHIFT :
				_isShift = true;
				break;
			case Key.CONTROL :
				_isControl = true;
				break;
			case Key.ALT :
				_isAlt = true;
				break;
		}
		
		e = "keyDown." + keyCode + "." + _isControl + "." + _isAlt + "." + _isShift;
		
		if (!repeat && (_lastKey == e))	return;
		
		f = keyMap[e];
		if (f)
		{
			binding.event(f, { type:"keyDown", keyCode:keyCode, ctrlKey:_isControl, altKey:_isAlt, shiftKey:_isShift });
		}
		
		_lastKey = e;
	}
		
		
	static private function onKeyUp ():Void
	{
		var f = FocusHandler.instance.getFocus(0), keyCode:Number = Key.getCode(), e:String;
		
		switch(keyCode)
		{
			case Key.SHIFT :
				_isShift = false;
				break;
			case Key.CONTROL :
				_isControl = false;
				break;
			case Key.ALT :
				_isAlt = false;
				break;
		}
		
		e = "keyUp." + keyCode + "." + _isControl + "." + _isAlt + "." + _isShift;
		_lastKey = null;
		if (TextField(f) || TextInput(f) || TextArea(f))
		{
			if (e != "keyDown.13.false.false.false")	return;	//	enter 예외
		}
		
		f = keyMap[e];
		if (f)
		{
			binding.event(f, { type:"keyUp", keyCode:keyCode, ctrlKey:_isControl, altKey:_isAlt, shiftKey:_isShift });
		}
	}
	
	
	/**
	 * 키설정
	 * @param	$binding
	 * @param	$type
	 * @param	$keyCode
	 * @param	$ctrlKey
	 * @param	$altKey
	 * @param	$shiftKey
	 */
	static public function setKey($keyBinding:String, $type:String, $keyCode:Number, $ctrlKey:Boolean, $altKey:Boolean, $shiftKey:Boolean):Void
	{
		var e:String = $type + "." + $keyCode + "." + Boolean($ctrlKey) + "." + Boolean($altKey) + "." + Boolean($shiftKey);
		
		if ($keyBinding)
		{
			keyMap[e] = $keyBinding;
		}
		else
		{
			delete	keyMap[e];
		}
	}
	
	
	/**
	 * 
	 * @param	$bindingKey
	 */
	static public function delKey($keyBinding:String):Void
	{
		var e:String;
		
		for (e in keyMap)
		{
			if (keyMap[e] == $keyBinding)
			{
				delete	keyMap[e];
			}
		}
	}
	
	
	static public function getKey($keyBinding:String):Array
	{
		var e:String, a:Array = [], a1:Array;
		
		for (e in keyMap)
		{
			if (keyMap[e] == $keyBinding)
			{
				a1 = e.split(".");
				a.push({type:a1[0], keyCode:a1[1], ctrlKey:a1[2], altKey:a1[3], shiftKey:a1[4]});
			}
		}
		
		return	a;
	}
	
	
	static public function add($keyBinding:String, $scope, $handler:Function):Number
	{
		binding = BindingDic.get("KeyManager");
		return	binding.add.apply(binding, arguments);
	}
	
	
	static public function del($keyBinding:String, $scope, $handler:Function):Void
	{
		binding = BindingDic.get("KeyManager");
		binding.del.apply(binding, arguments);
	}
}
