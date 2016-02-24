/**
 * 
 */
package com.minarto.manager 
{
	import com.minarto.data.Bind;
	
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import scaleform.clik.controls.*;
	import scaleform.clik.managers.FocusHandler;
	
	
	public class KeyManager 
	{
		static private const _binding:Bind = new Bind, _keyMap:* = {};
		
		
		static private var _lastKey:String, _stage:Stage, _enable:Boolean;
		
		
		static public var repeat:Boolean;
		
		
		/**
		 * 키 핸들러
		 * @param $e
		 *  
		 */		
		static private function _keyDown($e:KeyboardEvent):void
		{
			var f:* = FocusHandler.getInstance().getFocus(0), bindingKey:String;

			if (($e.keyCode != Keyboard.ENTER) && (f as TextField || f as TextInput || f as TextArea))	return;
			
			f = _getKey($e);
			
			if(!repeat && (_lastKey == f))	return;
			
			_lastKey = f;
			
			bindingKey = _keyMap[f];
			if(bindingKey)	_binding.evt(bindingKey, $e);
		}
		
		
		/**
		 * 키 핸들러
		 * @param $e
		 *  
		 */		
		static private function _keyUp($e:KeyboardEvent):void
		{
			var f:* = FocusHandler.getInstance().getFocus(0), bindingKey:String;
			
			if (f as TextField || f as TextInput || f as TextArea)
			{
				return;
			}
			
			f = _getKey($e);
			
			_lastKey = null;
			
			bindingKey = _keyMap[f];
			if(bindingKey)	_binding.evt(bindingKey, $e);
		}
		
		
		static public function init($stage:Stage):void 
		{
			enable(_stage = $stage);
		}
		
		
		static public function enable($enable:Boolean):void
		{
			if(_enable == $enable)	return;

			_enable = $enable;
			
			if(_stage)
			{
				if($enable)
				{
					_stage.addEventListener(KeyboardEvent.KEY_DOWN, _keyDown);
					_stage.addEventListener(KeyboardEvent.KEY_UP, _keyUp);
				}
				else
				{
					_stage.removeEventListener(KeyboardEvent.KEY_DOWN, _keyDown);
					_stage.removeEventListener(KeyboardEvent.KEY_UP, _keyUp);
				}
			}	
		}
		
		
		static public function getEnable():Boolean
		{
			return	_enable;
		}
		
		
		static private function _getKey($e:KeyboardEvent):String
		{
			return	$e.type + "." + $e.keyCode + "." + $e.ctrlKey + "." + $e.altKey + "." + $e.shiftKey;
		}
		
		
		/**
		 * 키 설정 
		 * @param $e
		 * @param $binding
		 *  
		 */
		static public function setKey($bindingKey:String, $e:KeyboardEvent):void 
		{
			var  e:String = _getKey($e);
			
			if($bindingKey)
			{
				_keyMap[e] = $bindingKey;
			}
			else
			{
				delete	_keyMap[e];
			}
		}
		
		
		/**
		 * 특정 바인딩키에 매칭된 키이벤트를 가져온다 
		 * @param $bindingKey	바인딩키
		 * @return
		 * 
		 */		
		static public function getKey($bindingKey:String=null):Vector.<KeyboardEvent> 
		{
			var e:String, v:Vector.<KeyboardEvent> = new Vector.<KeyboardEvent>([]);
			
			if($bindingKey)
			{
				for(e in _keyMap)
				{
					if(_keyMap[e] == $bindingKey)
					{
						arguments = e.split(".");
						v.push(new KeyboardEvent(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5],
							arguments[6], arguments[7], arguments[8]));
					}
				}
			}
			else
			{
				for(e in _keyMap)
				{
					arguments = e.split(".");
					v.push(new KeyboardEvent(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5],
						arguments[6], arguments[7], arguments[8]));
				}
			}
			
			return	v;
		}
		
		
		/**
		 * 특정 바인딩키 값을 가져온다 
		 * @param $e
		 * @return 
		 * 
		 */			
		static public function getBindingKey($e:KeyboardEvent):String 
		{
			return	_keyMap[_getKey($e)];
		}
		
		
		/**
		 * 바인딩 
		 * @param $bindingKey		바인딩 키
		 * @param $handler	바인딩 핸들러
		 * @param $args		바인딩 추가 인자
		 */				
		static public function add($bindingKey:String, $handler:Function, ...$args):void 
		{
			$args.unshift($bindingKey, $handler);
			_binding.add.apply(null, $args);
		}
		
		
		/**
		 * 바인딩 해제
		 * @param $binding	바인딩 키
		 * @param $handler	바인딩 핸들러
		 * 
		 */			
		static public function del($bindingKey:String, $handler:Function):void 
		{
			_binding.del($bindingKey, $handler);
		}
	}
}