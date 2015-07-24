/**
 * 
 */
package com.minarto.manager 
{
	import com.minarto.data.*;
	
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	
	import scaleform.clik.controls.*;
	import scaleform.clik.managers.FocusHandler;
	
	
	public class KeyManager 
	{
		static private const _binding:Binding = BindingDic.get("__KeyManager__");
		
		
		static private var _lastKey:String, _stage:Stage, _enable:Boolean;
		
		
		static public var repeat:Boolean;
		
		
		/**
		 * 키 핸들러
		 * @param $e
		 *  
		 */		
		static private function _onKey($e:KeyboardEvent):void
		{
			var f:* = FocusHandler.getInstance().getFocus(0), obj:*, bindingKey:String;

			if (f as TextField || f as TextInput || f as TextArea)
			{
				return;
			}
			
			f = _getKey($e);
			
			if(!repeat && (_lastKey == f))
			{
				return;
			}
			
			_lastKey = f;
			
			obj = _binding.getAt("__keyMap__");
			bindingKey = obj[f];
			if(bindingKey)	_binding.event(bindingKey, $e);
		}
		
		
		static public function init($stage:Stage):void 
		{
			enable(_stage = $stage);
		}
		
		
		static public function enable($enable:Boolean):void
		{
			var obj:* = _binding.getAt("__keyMap__");
			
			if(!obj)
			{
				obj = {};
				_binding.set("__keyMap__", obj);
			}
			
			if(_enable == $enable)
			{
				return;
			}

			_enable = $enable;
			
			if(_stage)
			{
				if($enable)
				{
					_stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKey);
					_stage.addEventListener(KeyboardEvent.KEY_UP, _onKey);
				}
				else
				{
					_stage.removeEventListener(KeyboardEvent.KEY_DOWN, _onKey);
					_stage.removeEventListener(KeyboardEvent.KEY_UP, _onKey);
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
		static public function set($bindingKey:String, $type:String, $keyCode:uint, $ctrlKey:Boolean=false, $altKey:Boolean=false
								   , $shiftKey:Boolean=false):void 
		{
			var obj:* = _binding.getAt("__keyMap__")
				, e:String = $type + "." + $keyCode + "." + $ctrlKey + "." + $altKey + "." + $shiftKey;
			
			if(!obj)
			{
				obj = {};
				_binding.set("__keyMap__", obj);
			}

			//var e:String = _getKey($e);
			
			if($bindingKey)
			{
				obj[e] = $bindingKey;
			}
			else
			{
				delete	obj[e];
			}
		}
		
		
		/**
		 * 특정 바인딩키에 매칭된 키이벤트를 가져온다 
		 * @param $bindingKey	바인딩키
		 * @return
		 * 
		 */		
		static public function get($bindingKey:String=null):Vector.<KeyboardEvent> 
		{
			var obj:* = _binding.getAt("__keyMap__"), e:String, v:Vector.<KeyboardEvent> = new Vector.<KeyboardEvent>([]);
			
			if($bindingKey)
			{
				for(e in obj)
				{
					if(obj[e] == $bindingKey)
					{
						arguments = e.split(".");
						v.push(new KeyboardEvent(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5],
							arguments[6], arguments[7], arguments[8]));
					}
				}
			}
			else
			{
				for(e in obj)
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
			var obj:* = _binding.getAt("__keyMap__");
			
			return	obj ? obj[_getKey($e)] : obj;
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