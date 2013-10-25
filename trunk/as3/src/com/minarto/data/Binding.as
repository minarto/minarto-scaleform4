/**
 * 
 */
package com.minarto.data {
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.*;
	import scaleform.clik.controls.CoreList;
	import scaleform.clik.data.DataProvider;
	
	public class Binding {
		static private var _valueDic:* = {}, _handlerDic:* = {}, _itemDic:Dictionary = new Dictionary(true), _listDic:* = {};
		
		
		/**
		 * 초기화 및 위임
		 *  
		 * @param $delegateObj	위임 객체
		 *  
		 */		
		public static function init($delegateObj:*):void{
			if ($delegateObj){
				$delegateObj.setValue = Binding.set;
				$delegateObj.getValue = Binding.get;
			}
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
			var a:Array, i:*, item:*, arg:Array, dataProvider:DataProvider, index:int;
			
			if($value as Array){
				dataProvider = get($key) as DataProvider;
				
				for (i in dataProvider){
					item = dataProvider[i];
					a = _itemDic[item];
					a.splice(a.indexOf($key), 1);
					if(!a.length)	delete	_itemDic[item];
				}
				
				for (i in $value) {
					item = $value[i];
					a = _itemDic[item];
					if(a)	a.push($key);
					else	_itemDic[item] = [$key];
				}
				
				if(dataProvider){
					dataProvider.setSource($value);
					dataProvider.invalidate();
				}
				else	_valueDic[$key] = dataProvider = new DataProvider($value);
				
				$value = dataProvider;
			}
			else	_valueDic[$key] = $value;

			a = _handlerDic[$key];
			for (i in a) {
				item = a[i];
				arg = item.arg;
				arg[0] = $value;
				item.handler.apply(null, arg);
			}
			
			a = _listDic[$key];
			for (i in a) {
				item = a[i];
				item.dataProvider = dataProvider;
			}
		}
		
		
		static public function setListItem($key:String, $item:*, $index:int=-1):void{
			var dataProvider:* = get($key), a:Array, i:*, item:*, arg:Array;
			
			if(dataProvider){
				dataProvider = dataProvider as DataProvider;
				if(dataProvider){
					$index = ($index > - 1) ? $index : dataProvider.length;
					item = dataProvider[$index];
					if(item){
						a = _itemDic[item];
						a.splice(a.indexOf($key), 1);
						if(!a.length)	delete	_itemDic[item];
					}
					
					a = _itemDic[$item];
					if(a)	a.push($key);
					else	_itemDic[$item] = [$key];
					
					dataProvider[$index] = $item;
					dataProvider.invalidate();
					
					a = _handlerDic[$key];
					for (i in a) {
						item = a[i];
						arg = item.arg;
						arg[0] = dataProvider;
						item.handler.apply(null, arg);
					}
				}
				else	return;
			}
			else{
				dataProvider = [];
				dataProvider[($index > - 1) ? $index : 0] = $item;
				set($key, dataProvider);
			}
		}
		
		
		static public function setListItemP($item:*, $p:String, $value:*):void{
			var key:String = _itemDic[$item], dataProvider:DataProvider = get(key) as DataProvider, a:Array, arg:Array;
			
			if(!dataProvider)	return;
			$item[$p] = $value;
			
			dataProvider.invalidate();
			
			a = _handlerDic[key];
			for ($p in a) {
				$item = a[$p];
				arg = $item.arg;
				arg[0] = dataProvider;
				$item.handler.apply(null, arg);
			}
		}
		
		
		/**
		 * 바인딩 
		 * @param $key		바인딩 키
		 * @param $handlerOrList	바인딩 핸들러 또는 CoreList
		 * @param $args		바인딩 추가 인자
		 */				
		public static function add($key:String, $handlerOrList:*, ...$args):void {
			var a:Array, i:*, item:*, dataProvider:DataProvider;
			
			if($handlerOrList as Function){
				a = _handlerDic[$key];
				
				$args.unshift(i);
				
				if(a){
					for (i in a){
						item = a[i];
						if (item.handler == $handlerOrList){
							item.arg = $args;
							return;
						}
					}
					a.push({handler:$handlerOrList, arg:$args});
				}
				else	_handlerDic[$key] = a = [{handler:$handlerOrList, arg:$args}];
			}
			else if($handlerOrList as CoreList){
				item = get($key);
				dataProvider = get($key) as DataProvider;
				if(!dataProvider)	_valueDic[$key] = dataProvider = new DataProvider();

				a = _listDic[$key];
				if(a){
					for(i in a)	if(a[i] == $handlerOrList)	return;
					a.push($handlerOrList);
				}
				else	_listDic[$key] = a = [$handlerOrList];				
			}
			else	throw	new Error("Bonding.add Error - $handlerOrList is not Function, CoreList");
		}
		
		
		/**
		 * 바인딩 
		 * @param $key		바인딩 키
		 * @param $handlerOrList	바인딩 핸들러 또는 CoreList
		 * @param $args		바인딩 추가 인자
		 */				
		public static function addNPlay($key:String, $handlerOrList:*, ...$args):void {
			var dataProvider:DataProvider;
			
			$args.unshift($key, $handlerOrList);
			add.apply(Binding, $args);
			
			if($handlerOrList as Function){
				$args[0] = get($key);
				$handlerOrList.apply(null, $args);
			}
			else if($handlerOrList as CoreList){
				dataProvider = get($key);
				if(dataProvider == $handlerOrList.dataProvider)	$handlerOrList.invalidate();
				else	$handlerOrList.dataProvider = dataProvider;
			}
		}
		
		
		/**
		 * 바인딩 해제
		 * @param $key	바인딩 키
		 * @param $handlerOrList	바인딩 핸들러 또는 CoreList
		 * 
		 */			
		public static function del($key:String=null, $handlerOrList:*=null):void {
			var a:Array, i:*;
			
			if($key){
				if($handlerOrList){
					if($handlerOrList as Function){
						a = _handlerDic[$key];
						for (i in a) {
							if (a[i].handler == $handlerOrList){
								a.splice(i, 1);
								if(!a.length)	delete	_handlerDic[$key];
								return;
							}
						}
					}
					else if($handlerOrList as CoreList){
						a = _listDic[$key];
						for (i in a) {
							if (a[i] == $handlerOrList){
								a.splice(i, 1);
								if(!a.length)	delete	_listDic[$key];
								return;
							}
						}
					}
					else	throw	new Error("Bonding.del Error - $handlerOrList is not Function, CoreList");
				} else{
					delete	_handlerDic[$key];
					delete	_listDic[$key];
				}
			}
			else{
				_handlerDic = {};
				_listDic = {};
			}
		}
		
		
		/**
		 * 특정 바인딩 값을 가져온다 
		 * @param $key	바인딩키
		 * @return 바인딩 값
		 * 
		 */		
		public static function get($key:String):* {
			return	_valueDic[$key];
		}
	}
}