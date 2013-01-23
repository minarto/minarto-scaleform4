package com.minarto.data {
	import com.minarto.manager.list.ListParam;
	
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	
	import scaleform.gfx.Extensions;
	
	
	public class ListBridge extends EventDispatcher {
		private static var _instance:ListBridge;
		
		
		protected var keyParams:* = {}, config:String;
		
		
		public function ListBridge(){
			if(_instance)	throw	new Error("don't create instance");
			_instance = this;
			
			if(ExternalInterface.available && Extensions.isScaleform)	ExternalInterface.call("ListBridge", this);
			trace("ListBridge init");
		}
		
		
		/**
		 * 리스트 데이터 설정
		 *  
		 * @param $key
		 * @param $a
		 * 
		 */		
		public function setList($key:String, $a:Array):void {
			ListBinding.setList($key, $a);
		}
		
		
		public function getList($key:String):Array {
			return	ListBinding.getList($key);
		}
		
		
		/**
		 * 리스트 옵션 설정 
		 * @param $key
		 * @param $param
		 * 
		 */		
		public function setParam($key:String, $param:ListParam):void {
			keyParams[$key] = $param;
		}
		
		
		/**
		 * 데이터 속성 설정 
		 * @param $data
		 * @param $p
		 * @param $value
		 * 
		 */		
		public function setDataProperty($data:*, $p:String, $value:*):void {
			ListBinding.setDataProperty($data, $p, $value);
		}
		
		
		/**
		 * 데이터 설정 
		 * @param $target
		 * @param $data
		 * @param $index
		 * 
		 */		
		public function setData($target:*, $data:*, $index:uint=0):void {
			ListBinding.setData($target, $data, $index);
		}
		
		
		/**
		 * 리스트 설정을 받음 
		 * @param $config
		 * 
		 */		
		public function setConfig($config:String):void{
			config = $config;
		}
		
		
		/**
		 * 리스트 옵션 삭제 
		 * @param $key
		 * 
		 */		
		public function delParam($key:String):void{
			if($key){
				delete	keyParams[$key];
			}
			else{
				keyParams = {};
			}
		}
	}
}