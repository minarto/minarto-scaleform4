package com.minarto.manager {
	import flash.display.*;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class WidgetManager {
		private static var container:DisplayObjectContainer, dic:* = {};
		
		
		public function WidgetManager() {
			throw new Error("don't create instance");
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