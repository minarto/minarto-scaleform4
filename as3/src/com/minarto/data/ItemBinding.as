/**
 * 
 */
package com.minarto.data {
	import flash.external.ExternalInterface;
	
	
	public class ItemBinding {
		private static var itemDic:* = {}, bindingDic:* = {};
		
		
		/**
		 * 초기화
		 */		
		public static function init():void{
			ExternalInterface.call("ItemBinding", ItemBinding);
		}
		
		
		/**
		 * 값 설정 
		 * @param $key	아이템 id
		 * @param $value	아이템 데이터
		 */
		public static function set($id:*, $value:*):void {
			var a:Array = bindingDic[$id], i:*, item:*, arg:Array;
			
			itemDic[$id] = $value;
			
			for (i in a) {
				item = a[i];
				arg = item.arg;
				arg[0] = $value;
				item.handler.apply(null, arg);
			}
		}
		
		
		/**
		 * 속성 값 설정 
		 * @param $key	아이템 id
		 * @param $prop	아이템 속성명
		 * @param $value	속성 값
		 */
		public static function setProps($id:*, $prop:String, $value:*):void {
			var a:Array = bindingDic[$id], i:*, item:*, arg:Array, value:*;
			
			value = get($id);
			if(value)	value[$prop] = $value;
			
			for (i in a) {
				item = a[i];
				arg = item.arg;
				arg[0] = value;
				item.handler.apply(null, arg);
			}
		}
		
		
		/**
		 * 바인딩 
		 * @param $id		아이템 id
		 * @param $handler	바인딩 핸들러
		 * @param $args		바인딩 추가 인자
		 */				
		public static function add($id:*, $handler:Function, ...$args):void {
			var a:Array = bindingDic[$id], i:*, item:*;
			
			$args.unshift(i);
			
			if(a){
				for (i in a){
					item = a[i];
					if (item.handler == $handler){
						item.arg = $args;
						return;
					}
				}
				a.push({handler:$handler, arg:$args});
			}
			else	bindingDic[$id] = a = [{handler:$handler, arg:$args}];
		}
		
		
		/**
		 * 바인딩 
		 * @param $id		아이템 id
		 * @param $handler	바인딩 핸들러
		 * @param $args		바인딩 추가 인자
		 */				
		public static function addNPlay($id:*, $handler:Function, ...$args):void {
			var a:Array = bindingDic[$id], i:*, item:*;
			
			$args.unshift(get($id));
			
			if(a){
				for (i in a){
					item = a[i];
					if (item.handler == $handler){
						item.arg = $args;
						$handler.apply(null, $args);
						return;
					}
				}
				a.push({handler:$handler, arg:$args});
			}
			else	bindingDic[$id] = a = [{handler:$handler, arg:$args}];
			
			$handler.apply(null, $args);
		}
		
		
		/**
		 * 바인딩 해제
		 * @param $id		아이템 id
		 * @param $handler	바인딩 핸들러
		 * 
		 */			
		public static function del($id:*=null, $handler:Function=null):void {
			var a:Array, i:*;
			
			if($id){
				a = bindingDic[$id];
				if(Boolean($handler)){
					for (i in a) {
						if (a[i].handler == $handler){
							a.splice(i, 1);
							if(!a.length)	delete	bindingDic[$id];
							return;
						}
					}
				}
				else	delete	bindingDic[$id];
			}
			else	bindingDic = {};
		}
		
		
		/**
		 * 특정 바인딩 값을 가져온다 
		 * @param $id		아이템 id
		 * @return 아이템 데이터
		 * 
		 */		
		public static function get($id:*):* {
			return	itemDic[$id];
		}
	}
}