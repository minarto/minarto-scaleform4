package com.minarto.manager {
	import flash.display.*;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class WidgetManager {
		static private var dic:* = {}, sourceDic:* = {};
		
		
		static public function init():void{
		}
		
		
		static public function load($src:String, $onComplete:Function=null, $onError:Function=null):void{
			var w:DisplayObject = getSrc($src);
			
			if(w)	unLoad($src);
			sourceDic[$src] = arguments;
			LoadManager.load($src, _onComplete, _onError);
		}
		
		
		static public function unLoad($src:String):void{
			var w:DisplayObject = getSrc($src), p:DisplayObjectContainer;
			
			if(w){
				p = w.parent;
				if(p){
					p.removeChild(w);
				}
			}
			else{
				LoadManager.unLoad($src, _onComplete);
				delete	sourceDic[$src];
			}
		}
		
		
		static private function _onComplete($src:String, $widget:DisplayObject):void{
			var f:Function = dic[$src][1];
			
			sourceDic[$src] = $widget;
			if(Boolean(f))	f($src, $widget);
		}
		
		
		static private function _onError($src:String):void{
			var f:Function = dic[$src][2];
			
			if(Boolean(f))	f($src);
		}
		
		
		static public function getSrc($src:String):DisplayObject{
			return	sourceDic[$src] as DisplayObject;
		}
		
		
		static public function add($id:*, $widget:DisplayObject):DisplayObject{
			dic[$id] = $widget;
			return	$widget;
		}
		
		
		static public function del($widget:* = null):DisplayObject{
			var w:DisplayObject, id:*;
			
			if($widget){
				w = $widget as DisplayObject;
				if(w){
					for(id in dic){
						if(dic[id] == w){
							delete	dic[id];
							return	w;
						}
					}
				}
				else{
					w = dic[id];
					delete	dic[id];
					return	w;
				}
			}
			else{
				for(id in dic)	delete	dic[id];
				dic = {};
			}
		}
		
		
		static public function get($id:*):DisplayObject{
			return	dic[$id];
		}
	}
}