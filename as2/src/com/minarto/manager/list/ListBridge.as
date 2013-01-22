﻿import com.minarto.data.ListBinding;
import com.minarto.manager.list.*;
import gfx.events.EventDispatcher;


class com.minarto.manager.list.ListBridge extends EventDispatcher {
	private static var _instance:ListBridge;
		
		
	private var keyParams = {}, config:String;
	
	
	public function ListBridge(){
		if(_instance)	throw	new Error("don't create instance");
		_instance = this;
	}
	
	
	public function setList($key:String, $a:Array):Void {
		ListBinding.setList($key, $a);
	}
		
		
	public function setParam($key:String, $param:ListParam):Void {
		keyParams[$key] = $param;
	}
	
	
	public function setDataProperty($data, $p:String, $value):Void {
		ListBinding.setDataProperty($data, $p, $value);
	}
	
	
	public function setData($target, $data, $index:Number):Void {
		ListBinding.setData($target, $data, $index);
	}
		
		
	public function setConfig($config:String):Void{
		config = $config;
	}
	
	
	public function delParam($key:String):Void{
		if($key){
			delete	keyParams[$key];
		}
		else{
			keyParams = {};
		}
	}
}