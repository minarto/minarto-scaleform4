package com.minarto.manager {
	import com.minarto.utils.Utils;
	
	import flash.display.*;
	
	import scaleform.clik.controls.CoreList;
	import scaleform.clik.data.DataProvider;
	import scaleform.gfx.Extensions;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class ListManager {
		private static var valueDic:* = {}, bindingDic:* = {}, dateKey:* = {};
		
		
		public static function set($key:String, $datas:Array):void{
			var dataProvider:DataProvider = valueDic[$key], a:Array = bindingDic[$key], i:Number, l:Number = a ? a.length : 0, item:*;
			
			if(!dataProvider)	valueDic[$key] = dataProvider = new DataProvider();
			dataProvider.setSource($datas);
			
			for (i = 0; i < l; ++ i) {
				item = a[i];
				item.handler(dataProvider);
			}
		}
		
		public static function get($key:String):DataProvider{
			return	valueDic[$key];
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
		public static function addList($key:String, $list:CoreList):void {
			var a:Array = bindingDic[$key], i:*, item:*;
			
			if(a){
				for (i in a){
					item = a[i];
					if (item.target == $list)	return;
				}
				item = {target:$list};
				a.push(item);
			}
			else{
				item = {target:$list};
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
						$handler.apply(null, $args);
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
			
			$handler.apply(null, $args);
		}
		
		
		/**
		 * 바인딩 해제
		 * @param $key	바인딩 키
		 * @param $handler	바인딩 핸들러
		 * 
		 */			
		public static function del($key:String=null, $handler:Function=null):void {
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
	}
}