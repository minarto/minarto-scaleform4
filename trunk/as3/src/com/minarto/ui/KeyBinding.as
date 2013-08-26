/**
 * 
 */
package com.minarto.ui {
	import com.minarto.data.Binding;
	
	import flash.display.Stage;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import scaleform.clik.controls.*;
	import scaleform.clik.managers.FocusHandler;
	
	
	public class KeyBinding {
		private static var keyDic:* = { }, bindingDic:* = {}, bindingKeys:* = {}, keyList:* = { CTRL:Keyboard.CONTROL, ALT:Keyboard.ALTERNATE, ESC:Keyboard.ESCAPE, F1:112, F2:113, F3:114, F4:115, F5:116, F6:117, F7:118, F8:119, F9:120, F10:121, F11:122, F12:123 },
							lastKey:uint = 4294967295, _isOn:Boolean = true;
		
		
		private static function _init():void{
			Binding.addNPlay("stage", _setListener);
		}
		
		
		private static function _setListener($stage:Stage):void{
			if($stage){
				Binding.del("stage", _setListener);
				$stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				$stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			}
		}
		
		
		/**
		 * 초기화 및 위임
		 *  
		 * @param $delegateObj	위임 객체
		 *  
		 */		
		private static function onKeyDown($e:KeyboardEvent):void{
			var d:* = FocusHandler.getInstance().getFocus(0), k:uint, bindingKey:String, a:Array, i:uint, l:uint, arg:*;
			
			if (d as TextField || d as TextInput || d as TextArea) return;
			
			k = $e.keyCode;
			if (lastKey == k)	return;
			
			d = isNaN(lastKey) ? keyDic["1." + k] : keyDic["1." + k + "." + lastKey];
			for (bindingKey in d) {
				a = bindingDic[bindingKey];
				for (i = 0, l = a.length; i < l; ++ i) {
					arg = a[i];
					arg.handler.apply(null, arg.args);
				}
			}
			
			lastKey = k;
		}
		
		
		/**
		 * 초기화 및 위임
		 *  
		 * @param $delegateObj	위임 객체
		 *  
		 */		
		private static function onKeyUp($e:KeyboardEvent):void{
			var d:*= FocusHandler.getInstance().getFocus(0), bindingKey:String, a:Array, i:Number, l:Number, arg:*;
			
			if (d as TextField || d as TextInput || d as TextArea) return;
			
			d = $e.keyCode;
			lastKey = 4294967295;
			
			d = keyDic["." + d];
			for (bindingKey in d) {
				a = bindingDic[bindingKey];
				for (i = 0, l = a.length; i < l; ++ i) {
					arg = a[i];
					arg.handler.apply(null, arg.args);
				}
			}
		}
		
		
		/**
		 * 초기화 및 위임
		 *  
		 * @param $delegateObj	위임 객체
		 *  
		 */		
		public static function init($delegateObj:*, $stage:Stage):void{
			if ($delegateObj)	$delegateObj.setKey = KeyBinding.set;
			else ExternalInterface.call("KeyBinding", KeyBinding);
			
			if(Binding.get("stage") != $stage)	Binding.set("stage", $stage);
		}
		
		
		public static function isOn($on:Boolean):void {
			var stage:Stage;
			
			if($on)	Binding.addNPlay("stage", _setListener);
			else{
				Binding.del("stage", _setListener);
				stage = Binding.get("stage");
				if(stage){
					stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
					stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				}
			}
			
			_isOn = $on;
		}
		
		
		/**
		 * 키 설정 
		 * @param $key	바인딩 키
		 * @param $value	바인딩 값
		 */
		public static function set($bindingKey:String, $isDown:Boolean, $key:*, $combi:* = null):void {
			var k:String, ba:*, a:Array;
			
			if ($bindingKey) {
				if($key !== undefined){
					if (typeof($key) == "string"){
						$key = $key.toUpperCase();
						$key = Keyboard[$key] || keyList[$key] || $key.charCodeAt(0);
					}
				
					if ($combi !== undefined && typeof($combi) == "string") {
						$combi = $combi.toUpperCase();
						$combi = Keyboard[$combi] || keyList[$combi] || $combi.charCodeAt(0);
					}
					
					if (isNaN($combi))	k = $isDown ? "1." + $key : "." + $key;
					else {
						k = $isDown ? "1." + $key + "." + $combi : "." + $key + "." + $combi;
						
						ba = keyDic[k];
						if (!ba)	keyDic[k] = ba = {};
						ba[$bindingKey] = 1;
						
						k = $isDown ? "1." + $combi + "." + $key : "." + $combi + "." + $key;
					}
					
					ba = keyDic[k];
					if (!ba)	keyDic[k] = ba = {};
					ba[$bindingKey] = 1;
					
					ba = bindingKeys[$bindingKey];
					if (!ba)	bindingKeys[$bindingKey] = ba = [];
					
					if (isNaN($combi))	k = $isDown ? "1." + $key : "." + $key;
					else	k = $isDown ? "1." + $key + "." + $combi : "." + $key + "." + $combi;
					
					a = k.split(".");
					a[1] = uint(a[1]);
					if(a.length > 2)	a[2] = uint(a[2]);
					for (k in ba) {
						$combi = ba[k];
						if($combi[0] == a[0] && $combi[1] == a[1] && $combi[2] == a[2])	return;
					}
					ba.push(a);
				}
				else{
					for (k in keyDic)	delete	keyDic[k][$bindingKey];
					delete bindingKeys[$bindingKey];
				}
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
			return	bindingKeys[$bindingKey];
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