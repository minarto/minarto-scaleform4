/**
 * 
 */
package com.minarto.manager {
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	import scaleform.clik.controls.*;
	import scaleform.clik.core.CLIK;
	import scaleform.clik.managers.FocusHandler;
	
	
	public class KeyManager {
		static private const _BINDING_DIC:* = { };
		
		
		static private var _HANDLER_DIC:* = {}, _REPEAT_KEY:String;
		
		
		static public var REPEAT:Boolean;
		
		
		/**
		 * 키 핸들러
		 * @param $e
		 *  
		 */		
		static private function _onKey($e:KeyboardEvent):void{
			var f:* = FocusHandler.getInstance().getFocus(0), dic:Dictionary;
			
			if (f as TextField || f as TextInput || f as TextArea) return;
			
			f = $e.type + "." + $e.keyCode + "." + $e.ctrlKey + "." + $e.altKey + "." + $e.shiftKey;
			if(!REPEAT && (_REPEAT_KEY == f))	return;
			
			_REPEAT_KEY = f;
			dic = _HANDLER_DIC[_BINDING_DIC[f]];
			for (f in dic) {
				f.apply(null, dic[f]);
			}
		}
		
		
		static public function ENABLE($on:Boolean):void {
			var stage:Stage = CLIK.stage;
			
			if(stage){
				if($on){
					stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKey);
					stage.addEventListener(KeyboardEvent.KEY_UP, _onKey);
				}
				else{
					stage.removeEventListener(KeyboardEvent.KEY_DOWN, _onKey);
					stage.removeEventListener(KeyboardEvent.KEY_UP, _onKey);
				}
			}			
		}
		
		
		/**
		 * 키 설정 
		 * @param $bindingKey
		 * @param $eventType
		 * @param $keyCode
		 * @param $ctrlKey
		 * @param $altKey
		 * @param $shiftKey
		 * @param $enable	//	등록된키 등록/삭제여부
		 * 
		 */
		static public function SET($bindingKey:String, $eventType:String, $keyCode:uint, $ctrlKey:Boolean = false, $altKey:Boolean = false, $shiftKey:Boolean = false, $enable:Boolean=true):void {
			$eventType += "." + $keyCode + "." + $ctrlKey + "." + $altKey + "." + $shiftKey;
			
			if($enable)	_BINDING_DIC[$eventType] = $bindingKey;
			else	delete	_BINDING_DIC[$eventType];
			
			ENABLE(true);
		}
		
		
		/**
		 * 특정 바인딩키에 매칭된 키값을 가져온다 
		 * @param $bindingKey	바인딩키
		 * @return 키 값
		 * 
		 */		
		static public function GET_EVENT($bindingKey:String):Array {
			arguments.length = 0;
			for(var k:String in _BINDING_DIC){
				if(_BINDING_DIC[k] == $bindingKey){
					arguments.push(k);
				}
			}
			
			return	arguments;
		}
		
		
		/**
		 * 특정 바인딩키 값을 가져온다 
		 * @param $eventType
		 * @param $keyCode
		 * @param $ctrlKey
		 * @param $altKey
		 * @param $shiftKey
		 * @return 
		 * 
		 */			
		static public function GET_BINDINGKEY($eventType:String, $keyCode:uint, $ctrlKey:Boolean = false, $altKey:Boolean = false, $shiftKey:Boolean = false):String {
			return	_BINDING_DIC[$eventType + "." + $keyCode+ "." + $ctrlKey + "." + $altKey + "." + $shiftKey];
		}
		
		
		/**
		 * 바인딩 
		 * @param $bindingKey		바인딩 키
		 * @param $handler	바인딩 핸들러
		 * @param $args		바인딩 추가 인자
		 */				
		static public function ADD($bindingKey:String, $handler:Function, ...$args):void {
			(_HANDLER_DIC[$bindingKey] || (_HANDLER_DIC[$bindingKey] = new Dictionary(true)))[$handler] = $args;
		}
		
		
		/**
		 * 바인딩 해제
		 * @param $bindingKey	바인딩 키
		 * @param $handler	바인딩 핸들러
		 * 
		 */			
		static public function DEL($bindingKey:String, $handler:Function):void {
			var dic:Dictionary;
			
			if ($bindingKey) {
				if($handler){
					dic = _HANDLER_DIC[$bindingKey];
					if(dic)	delete	dic[$handler];
				}
				else	delete	_HANDLER_DIC[$bindingKey];
			}
			else	_HANDLER_DIC = {};
		}
	}
}