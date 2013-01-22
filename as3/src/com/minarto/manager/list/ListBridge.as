package com.minarto.manager.list {
	import com.minarto.data.ListBinding;
	
	import flash.events.EventDispatcher;
	
	
	public class ListBridge extends EventDispatcher {
		private static var _instance:ListBridge;
		
		
		protected var listDic:* = {}, keyParams:* = {};
		
		
		public function ListBridge(){
			if(_instance)	throw	new Error("don't create instance");
			_instance = this;
		}
		
		
		public function setList($key:String, $a:Array):void {
			ListBinding.setList($key, $a);
		}
		
		
		public function setParam($key:String, $param:ListParam):void {
			keyParams[$key] = $param;
		}
		
		
		public function setDataProperty($data:*, $p:String, $value:*):void {
			ListBinding.setDataProperty($data, $p, $value);
		}
		
		
		public function setData($target:*, $data:*, $index:uint=0):void {
			ListBinding.setData($target, $data, $index);
		}
		
		public function addList($key:String, $param:*):void{
			keyParams[$key] = $param;
		}
		
		
		public function delParam($key:String):void{
			delete	keyParams[$key];
		}
	}
}