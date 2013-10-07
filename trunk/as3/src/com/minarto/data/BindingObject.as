/**
 * 
 */
package com.minarto.data {
	import flash.external.ExternalInterface;

	public class BindingObject {
		static private var bDic:* = {};
		
		private var valueDic:* = {}, bindingDic:* = {};
		
		
		/**
		 * 바인딩 객체 반환
		 */		
		static public function AddObject($name:String):BindingObject{
			var b:BindingObject = GetObject($name);
			
			if(!b){
				bDic[$name] = b = new BindingObject;
				ExternalInterface.call("BindingObject", $name, b);
			}
			
			return	b;
		}
		
		
		/**
		 * 바인딩 객체 반환
		 */		
		static public function GetObject($name:String):BindingObject{
			return	bDic[$name];
		}
		
		
		/**
		 * 바인딩 객체 삭제
		 */	
		static public function DelObject($name:String):void{
			delete	bDic[$name];
		}
		
		
		/**
		 * 갑 설정
		 */	
		static public function SetObjectValue($name:String, $key:String, $value:*):BindingObject{
			var b:BindingObject = AddObject($name);
			
			b.set($key, $value);
			
			return	b;
		}
		
		
		/**
		 * 값 설정
		 */	
		static public function GetObjectValue($name:String, $key:String):*{
			return	AddObject($name).get($key, $value);
		}
		
		
		/**
		 * 값 설정 
		 * @param $key	바인딩 키
		 * @param $value	바인딩 값
		 */
		public function set($key:String, $value:*):void {
			var a:Array = bindingDic[$key], i:*, item:*, arg:Array;
			
			valueDic[$key] = $value;
			
			for (i in a) {
				item = a[i];
				arg = item.arg;
				arg[0] = $value;
				item.handler.apply(null, arg);
			}
		}
		
		
		/**
		 * 바인딩 
		 * @param $key		바인딩 키
		 * @param $handler	바인딩 핸들러
		 * @param $args		바인딩 추가 인자
		 */				
		public function add($key:String, $handler:Function, ...$args):void {
			var a:Array = bindingDic[$key], i:*, item:*;
			
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
			else	bindingDic[$key] = a = [{handler:$handler, arg:$args}];
		}
		
		
		/**
		 * 바인딩 
		 * @param $key		바인딩 키
		 * @param $handler	바인딩 핸들러
		 * @param $args		바인딩 추가 인자
		 */				
		public function addNPlay($key:String, $handler:Function, ...$args):void {
			var a:Array = bindingDic[$key], i:*, item:*;
			
			$args.unshift(get($key));
			
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
			else	bindingDic[$key] = a = [{handler:$handler, arg:$args}];
			
			$handler.apply(null, $args);
		}
		
		
		/**
		 * 바인딩 해제
		 * @param $key	바인딩 키
		 * @param $handler	바인딩 핸들러
		 * 
		 */			
		public function del($key:String=null, $handler:Function=null):void {
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
		public function get($key:String):* {
			return	valueDic[$key];
		}
	}
}