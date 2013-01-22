package com.minarto.manager.list {
	import com.minarto.data.ListBinding;
	
	import flash.events.EventDispatcher;
	import flash.utils.*;
	
	
	public class ListBridge extends EventDispatcher {
		private static var _instance:ListBridge;
		
		
		protected var listDic:* = {}, keyParams:* = {}, coolTimeDataDic:Dictionary = new Dictionary(true), countSourceDic:* = {}, 
						keyCooltimeRate:String, keyCooltimeTotal:String, coolTimeDic:* = {}, coolTimeIDDic:* = {};
		
		
		public var keyTableID:String;
		
		
		public function ListBridge(){
			if(_instance)	throw	new Error("don't create instance");
			_instance = this;
		}
		
		
		public function setList($key:String, $a:Array):void {
			setListParam($key, $a, keyParams[$key]);
			listDic[$key] = $a;
			ListBinding.setList($key, $a);
		}
		
		
		public function setParam($key:String, $param:*):void{
			keyParams[$key] = $param;
			setListParam($key, listDic[$key], $param);
		}
		
		
		protected function setListParam($key:String, $a:Array, $param:*):void{
			if(!$a || !$param)	return;
			
			for(var i:* in $a){
				_setData(null, $a[i], $param);
			}
		}
		
		
		public function setDataProperty($data:*, $p:String, $value:*):void {
			ListBinding.setDataProperty($data, $p, $value);
		}
		
		
		public function setData($target:*, $data:*, $index:uint=0):void {
			ListBinding.setData($target, $data, $index);
		}
		
		
		protected function _setData($oData:*, $nData:*, $param:*):void{
			if($oData){
				var id:String = $oData[keyTableID];
				var dic:Dictionary = countSourceDic[id];
				if(dic)	delete	dic[$oData];
			}
			
			if($nData){
				if($param){
					id = $oData[keyTableID];
					dic = countSourceDic[id] || (countSourceDic[id] = new Dictionary(true));
					dic[$nData] = $nData;
				}
			}
			
			coolTimeDataDic[$nData] = {};
		}
		
		
		public function coolTimeKeyInit($keyCooltimeRate:String, $keyCooltimeTotal:String, $coolTimeInterval:uint, ...$keyCooltime):void{
			keyCooltimeRate = $keyCooltimeRate;
			keyCooltimeTotal = $keyCooltimeTotal;
			
			for(var i:* in $keyCooltime){
				coolTimeIDDic[$keyCooltime[i]] = {};
			}
			
			var f:Function = ListBinding.setDataProperty;
			
			setInterval(function ():void {
				var date:Date = new Date;
				var time:Number = date.getTime();
				
				for(var key:String in coolTimeDic){
					var typeObj:* = coolTimeDic[key];
					
					for(var keyValue:String in typeObj){
						var timeObj:* = typeObj[keyValue];
						
						var rate:Number = (typeObj.currentTime + (time - typeObj.startTime)) * typeObj.rate;
						var totalTime:Number = typeObj.totalTime;
						
						if(rate >= 1){
							rate = 1;
							for(i in coolTimeDataDic){
								var o:* = coolTimeDataDic[i];
								if(o.timeObj == timeObj){
									var d:* = o.data;
									f(d, $keyCooltimeRate, rate);
									f(d, $keyCooltimeTotal, totalTime);
									
									delete	o.timeObj;
								}
							}
							
							delete typeObj[keyValue];
						}
						else{
							for(i in coolTimeDataDic){
								o = coolTimeDataDic[i];
								if(o.timeObj == timeObj){
									d = o.data;
									f(d, keyCooltimeRate, rate);
									f(d, keyCooltimeTotal, totalTime);
								}
							}
						}
					}
				}
			}, $coolTimeInterval);
		}
		
		
		/**
		 * 
		 * @param $key
		 * @param $keyValue
		 * @param $currentTime
		 * @param $totalTime
		 * 
		 */
		public function setCoolTime($key:String, $keyValue:String, $currentTime:uint, $totalTime:uint):void {
			var date:Date = new Date;
			
			var typeObj:* = coolTimeDic[$key] || (coolTimeDic[$key] = {});
			var timeObj:* = typeObj[$keyValue] || (typeObj[$keyValue] = {});
			
			timeObj.startTime = date.getTime();
			timeObj.currentTime = $currentTime;
			timeObj.totalTime = $totalTime;
			timeObj.rate = 1 / $totalTime;
			
			for(var p:* in coolTimeDataDic){
				var o:* = coolTimeDataDic[p];
				var d:* = o.data;
				if(d[$key] == $keyValue){
					var timeObj2:* = o.timeObj;
					if(!timeObj2 || (timeObj.totalTime * timeObj.rate < timeObj2.totalTime * timeObj2.rate)){
						o.timeObj = timeObj;	//	남은 시간이 많은 쪽 쿨타임 객체를 적용
					}
				}
			}
		}
		
		
		public function addList($key:String, $param:*):void{
			keyParams[$key] = $param;
		}
		
		
		public function delList($key:String):void{
			if($key){
				delete	keyParams[$key];
			}
			else{
				keyParams = {};
			}
		}
	}
}