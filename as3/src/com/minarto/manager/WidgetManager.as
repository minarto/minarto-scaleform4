package com.minarto.manager {
	import flash.display.*;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class WidgetManager {
		private static var container:DisplayObjectContainer, dic:* = {}, modeSrcs:* = {};
		
		
		public function WidgetManager() {
			throw new Error("don't create instance");
		}
		
		
		public static function setMode($mode:String, $id:String, $src:String, ...$args):void{
			var source:Array = modeSrcs[$mode], i:uint, l:uint = source ? source.length - 1 : 0;
			
			if(!source)	modeSrcs[$mode] = source = [];
			
			source.length = 0;
			source.push($id, $src);
			
			for(i = 0; i<l;)	source.push($args[i ++], $args[i ++]);
		}
		
		
		public static function getMode($mode:String):Array{
			return	modeSrcs[$mode];
		}
		
		
		public static function loadMode($mode:String, onComplete:Function):void{
			var source:Array = modeSrcs[$mode], i:uint, l:uint = source ? source.length - 1 : 0;
			
			if(l < 1){
				onComplete();
				return;
			}
			
			for(i = 0, l = source ? source.length - 1 : 0; i<l;)	add(source[i ++], source[i ++]);
			
			add(source[i ++], source[i], onComplete, onComplete);
		}
		
		
		public static function init($container:DisplayObjectContainer = null):DisplayObjectContainer{
			var id:*;
			
			if($container){
				if(container == $container)	return	container;
				for(id in dic)	$container.addChild(dic[id]);
				container = $container;
			}
			
			return	container;
		}
		
		
		public static function add($id:String, $widget:*, $onComplete:Function=null, $onError:Function=null):DisplayObject{
			var w:DisplayObject = $widget as DisplayObject;
			
			del($id);
			
			if(w){
				dic[$id] = w;
				if(container)	container.addChild(w);
				
			}
			else if($widget as String){
				LoadManager.load($widget, function($content:DisplayObject):void{
						dic[$id] = $content;
						if(container)	container.addChild($content);
						if(Boolean($onComplete))	$onComplete($content);
					}, $onError);
			}
			
			return	w;
		}
		
		
		public static function del($id:* = null):void{
			var w:DisplayObject;
			
			if($id){
				if($id as DisplayObject){
					w = $id;
					for($id in dic){
						if(dic[$id] == w)	delete	dic[$id];
					}
				}
				else	delete	dic[$id];
			}
			else{
				for($id in dic)	delete	dic[$id];
				
				dic = {};
			}			
		}
		
		
		public static function get($id:*):DisplayObject{
			return	dic[$id];
		}
	}
}