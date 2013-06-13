/**
 * 
 */
package com.minarto.data {
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	
	
	public class Binding {
		private static var valueDic:* = {}, bindingDic:* = {}, dateKey:* = {};
		
		
		/**
		 * 초기화 및 위임
		 *  
		 * @param $delegateObj	위임 객체
		 *  
		 */		
		public static function init($delegateObj:*):void{
			if ($delegateObj)	$delegateObj.setValue = set;
			else ExternalInterface.call("Binding", Binding);
		}
		
		
		/**
		 * 시간 관리
		 *  
		 * @param $key
		 * @param $interval
		 * 
		 */		
		public static function dateInit($key:String, $interval:Number=NaN):void {
			var o:* = dateKey[$key], timer:Timer, f:Function;
			
			if(o){
				timer = o.timer;
				timer.stop();
				if($interval){
					timer.delay = $interval * 1000;
					timer.reset();
					timer.start();
				}
				else{
					timer.removeEventListener(TimerEvent.TIMER, o.func);
					delete	dateKey[$key];
				}
			}
			else if($interval){
				timer = new Timer($interval * 1000);
				
				f = function($$e:*):void{
					set($key, new Date);
				};
				
				f($interval);
				
				timer.addEventListener(TimerEvent.TIMER, f);
				timer.start();
				
				dateKey[$key] = o = {timer:timer, func:f};
			}
		}
		
		
		/**
		 * 값 설정 
		 * @param $key	바인딩 키
		 * @param $value	바인딩 값
		 */
		public static function set($key:String, $value:*):void {
			var a:Array, i:Number, l:Number, item:*, arg:Array;
			
			if($value == valueDic[$key])	return;
			
			valueDic[$key] = $value;
			
			a = bindingDic[$key];
			for (i = 0, l = a ? a.length : 0; i < l; ++ i) {
				item = a[i];
				arg = item.arg;
				arg[0] = $value;
				item.handler.apply(null, arg);
			}
		}
		
		
		/**
		 * 바인딩 여부
		 */				
		public static function has($key:String, $handler:Function):Boolean {
			var a:Array = bindingDic[$key];
			
			for ($key in a) if (a[$key].handler == $handler) return	true;
			return	false;
		}
		
		
		/**
		 * 바인딩 
		 * @param $key		바인딩 키
		 * @param $handler	바인딩 핸들러
		 * @param $args		바인딩 추가 인자
		 */				
		public static function add($key:String, $handler:Function, ...$args):void {
			var a:Array = bindingDic[$key], i:*, item:*;
			
			$args.unshift(get($key));
			
			if(a){
				for (i in a){
					item = a[i];
					if (item.handler == $handler){
						item.arg = $args;
						return;
					}
				}
				item = {handler:$handler, arg:$args};
				a.push(item);
			}
			else{
				item = {handler:$handler, arg:$args};
				bindingDic[$key] = a = [item];
			}
		}
		
		
		/**
		 * 바인딩 
		 * @param $key		바인딩 키
		 * @param $handler	바인딩 핸들러
		 * @param $args		바인딩 추가 인자
		 */				
		public static function addNPlay($key:String, $handler:Function, ...$args):void {
			var a:Array = bindingDic[$key], i:*, item:*;
			
			$args.unshift(get($key));
			
			if(a){
				for (i in a){
					item = a[i];
					if (item.handler == $handler){
						item.arg = $args;
						return;
					}
				}
				item = {handler:$handler, arg:$args};
				a.push(item);
			}
			else{
				item = {handler:$handler, arg:$args};
				bindingDic[$key] = a = [item];
			}
			
			$handler($args);
		}
		
		
		/**
		 * 바인딩 해제
		 * @param $key	바인딩 키
		 * @param $handler	바인딩 핸들러
		 * 
		 */			
		public static function del($key:String, $handler:Function):void {
			var a:Array, i:*;
			
			if($key){
				a = bindingDic[$key];
				for (i in a) {
					if (a[i].handler == $handler){
						a.splice(i, 1);
						if(!a.length)	delete	bindingDic[$key];
						return;
					}
				}
			}
			else	bindingDic = {};
		}
		
		
		/**
		 * 특정 바인딩 값을 가져온다 
		 * @param $key	바인딩키
		 * @return 바인딩 값
		 * 
		 */		
		public static function get($key:String):* {
			return	valueDic[$key];
		}
	}
}