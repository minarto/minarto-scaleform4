package com.minarto.manager {
	import flash.display.*;
	import flash.utils.getDefinitionByName;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class WidgetManager {
		private static var container:DisplayObjectContainer, dic:* = {};
		
		
		public function WidgetManager() {
			throw new Error("don't create instance");
		}
		
		
		public static function init($container:DisplayObjectContainer):void{
			var id:*;
			
			if(container == $container || !$container)	return;
			
			if(!container)	for(id in dic)	$container.addChild(dic[id]);
			
			container = $container;
		}
		
		
		public static function add($id:*, $widget:*, $onComplete:Function=null):DisplayObject{
			var c:Class = getDefinitionByName($widget) as Class, w:DisplayObject, f:Function;
			
			if($widget as String){
				f = function($content:DisplayObject):void{
					if(container)	container.addChild($content);
					$onComplete($content);
					dic[$widget] = $content;
				}
				LoadManager.load($widget, f, f);
			}
			else if(c){
				dic[$id] = w = new c;
				if(container)	container.addChild(w);
			}
			else if($widget as DisplayObject){
				dic[$id] = w = $widget;
				if(container)	container.addChild(w);
			}
			
			return	w;
		}
		
		
		public static function del($id:* = null):void{
			var w:DisplayObject;
			
			if($id){
				if($id as DisplayObject){
					w = $id;
					for($id in dic){
						if(dic[$id] == w){
							delete	dic[$id];
						}
					}
				}
				else{
					w = dic[$id];
					if(w)	delete	dic[$id];
				}
			}
			else{
				for($id in dic){
					delete	dic[$id];
				}
				
				dic = {};
			}			
		}
		
		
		public static function get($id:*):DisplayObject{
			return	dic[$id];
		}
	}
}