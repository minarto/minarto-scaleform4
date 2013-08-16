/**
 * 
 */
package com.minarto.ui {
	import flash.display.Stage;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import scaleform.clik.controls.*;
	import scaleform.clik.managers.FocusHandler;
	
	
	public class KeyBinding {
		private static var keyDic:* = { }, bindingDic:* = {};
		
		
		/**
		 * 초기화 및 위임
		 *  
		 * @param $delegateObj	위임 객체
		 *  
		 */		
		public static function init($delegateObj:*, $stage:Stage):void{
			var keyDown:Function, keyUp:Function, lastKeys:* = {};
			
			if ($delegateObj)	$delegateObj.setKey = KeyBinding.set;
			else ExternalInterface.call("KeyBinding", KeyBinding);
			
			keyDown = function($e:KeyboardEvent):void{
				var k:uint, d:*, lastKey:String, bindingKey:String, a:Array, i:Number, l:Number, arg:*;
				
				d = FocusHandler.getInstance().getFocus(0);
				if (d as TextField || d as TextInput || d as TextArea) return;
				
				k = $e.keyCode;
				if (lastKeys[k])	return;
				
				//	눌러진 키로 검색
				d = keyDic["1." + k];
				for (bindingKey in d) {
					a = bindingDic[bindingKey];
					for (i = 0, l = a ? a.length : 0; i < l; ++ i) {
						arg = a[i];
						arg.handler.apply(null, arg.args);
					}
				}
				
				//	키 조합으로 검색
				for (lastKey in lastKeys) {
					d = keyDic["1." + k + "." + lastKey];
					for (bindingKey in d) {
						a = bindingDic[bindingKey];
						for (i = 0, l = a ? a.length : 0; i < l; ++ i) {
							arg = a[i];
							arg.handler.apply(null, arg.args);
						}
					}
					
					//	키 반대 조합으로 다시 검색
					d = keyDic["1." + lastKey + "." + k];
					for (bindingKey in d) {
						a = bindingDic[bindingKey];
						for (i = 0, l = a ? a.length : 0; i < l; ++ i) {
							arg = a[i];
							arg.handler.apply(null, arg.args);
						}
					}
				}
			}
				
			keyUp = function($e:KeyboardEvent):void{
				var d:*, bindingKey:String, a:Array, i:Number, l:Number, arg:*;
				
				d = FocusHandler.getInstance().getFocus(0);
				if (d as TextField || d as TextInput || d as TextArea) return;
				
				d = $e.keyCode;
				delete	lastKeys[d];
				
				d = keyDic["." + d];
				for (bindingKey in d) {
					a = bindingDic[bindingKey];
					for (i = 0, l = a ? a.length : 0; i < l; ++ i) {
						arg = a[i];
						arg.handler.apply(null, arg.args);
					}
				}
			}
			
			$stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			$stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		}
		
		
		/**
		 * 키 설정 
		 * @param $key	바인딩 키
		 * @param $value	바인딩 값
		 */
		public static function set($bindingKey:String, $isDown:Boolean, $key:*, $combi:* = null):void {
			var d:*, k:String;
			
			if ($bindingKey) {
				if (typeof($key) == "string")	$key = $key.toUpperCase().charCodeAt(0);
				
				if ($isDown) {
					if (arguments.length > 3) {
						if (typeof($combi) == "string") {
							$combi = $combi.toUpperCase();
							switch($combi) {
								case "ALT" :
									$combi = Keyboard.ALTERNATE;
									break;
								case "CONTROL" :
								case "CTRL" :
									$combi = Keyboard.CONTROL;
									break;
								case "SHIFT" :
									$combi = Keyboard.SHIFT;
									break;
								default :
									$combi = $combi.toUpperCase().charCodeAt(0);
							}
						}
					}
				}	else	$combi = NaN;
				
				if ($isDown)	k = isNaN($combi) ? "1." + $key : "1." + $key + "." + $combi;
				else	k = "." + $key;
				
				d = keyDic[k];
				if (!d)	keyDic[k] = d = {};
				d[$bindingKey] = 1;
			}
			else	keyDic = { };
		}
		
		
		/**
		 * 특정 바인딩 값을 가져온다 
		 * @param $key	바인딩키
		 * @return 바인딩 값
		 * 
		 */		
		public static function get($bindingKey:String):Array {
			var key:String, a:Array = [];
			
			for (key in keyDic)	if (keyDic[key][$bindingKey])	a.push(key.split("."));
			
			return	a;
		}
		
		
		/**
		 * 바인딩 
		 * @param $key		바인딩 키
		 * @param $handler	바인딩 핸들러
		 * @param $args		바인딩 추가 인자
		 */				
		public static function add($bindingKey:String, $handler:Function, ...$args):void {
			var a:Array = bindingDic[$bindingKey], i:*, arg:*;
			
			if (a) {
				for (i in a) {
					arg = a[i];
					if (arg.handler == $handler) {
						arg.args = $args;
						return;
					}
					a.push({handler:$handler, args:$args});
				}
			}	else	bindingDic[$bindingKey] = a = [{handler:$handler, args:$args}];
		}
		
		
		/**
		 * 바인딩 해제
		 * @param $key	바인딩 키
		 * @param $handler	바인딩 핸들러
		 * 
		 */			
		public static function del($bindingKey:String=null, $handler:Function=null):void {
			var a:Array, i:*, arg:*;
			
			if ($bindingKey) {
				a = bindingDic[$bindingKey];
				for (i in a) {
					arg = a[i];
					if (arg.handler == $handler) {
						a.splice(i, 1);
						if (!a.length)	delete	bindingDic[$bindingKey];
						return;
					}
				}
			}	else	bindingDic = {};
		}
	}
}