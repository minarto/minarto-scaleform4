package com.minarto.manager.widget {
	import com.minarto.controls.widget.Widget;
	
	import de.polygonal.core.ObjectPool;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.utils.Dictionary;


	public class WidgetArrangeManager {
		protected static var objectDic:Dictionary = new Dictionary(true), idDic:* = {}, childDic:* = {}, widgetScale:Number = 1, staticScale:Number = 1, resolution:String = "1366x768";
		
		
		public static function getResolution():String{
			return	resolution;
		}
		
		
		public static function getWidgetScale():Number{
			return	widgetScale;
		}
		
		
		public static function init($stage:Stage, $minStageWidth:uint=1366, $minStageHeight:uint=768):void{
			idDic["stage"] = $stage;
			$stage.addEventListener(Event.RESIZE, function ($e:Event):void {
				var sw:uint = $stage.stageWidth;
				var sh:uint = $stage.stageHeight;
				
				resolution = "" + sw + "x" + sh;
				
				childDic = {};
				
				for(var i:* in objectDic){
					var o:WidgetParamObject = objectDic[i];
					var a:WidgetArrangeObject = o.getArrange();
					
					var id:String = a.parentWidgetID;
					var dic:Dictionary = childDic[id] || (childDic[id] = new Dictionary(true));
					dic[o.widget] = o;
				}
				
				if(sw < $minStageWidth || sh < $minStageHeight){
					widgetScale = staticScale * Math.min(sw / $minStageWidth, sh / $minStageHeight);
				}
				else{
					widgetScale = staticScale;
				}
				arrange(null);
			});
			
			trace("WidgetArrangeManager init");
		}
		
		
		public static function setStaticScale($scale:Number):void{
			staticScale = $scale || 1;
			arrange(null);
		}
		public static function getStaticScale():Number{
			return	staticScale;
		}
		
		
		public static function arrange($widget:DisplayObject):void{
			if($widget && (!$widget as Stage)){
				var o:WidgetParamObject = objectDic[$widget];
				if(!o)	return;
				
				var a:WidgetArrangeObject = o.getArrange();
				if(!a)	return;
				
				if(a.scaleEnable){
					$widget.scaleX = widgetScale;
					$widget.scaleY = widgetScale;
				}
				else{
					$widget.scaleX = staticScale;
					$widget.scaleY = staticScale;
				}
				
				var po:WidgetParamObject = idDic[a.parentWidgetID];
				var p:DisplayObject = po.widget;
				if(p){
					var stage:Stage = p as Stage;
					if(stage){
						var w:int = stage.stageWidth;
						var h:int = stage.stageHeight;
					}
					else{
						w = p.width;
						h = p.height;
					}
				}
				else{
					return;
				}
				
				var xr:Number = w * a.xrate;
				var yr:Number = h * a.yrate;
				
				var xp:Number = a.xpadding * staticScale;
				var yp:Number = a.ypadding * staticScale;
				
				var dw:Number = $widget.width;
				var dh:Number = $widget.height;
				
				switch(a.align){
					case StageAlign.TOP:
						var tx:Number = xr + xp - dw * 0.5;
						var ty:Number = yr + yp;
						break;
					case StageAlign.TOP_LEFT:
						tx = xr + xp;
						ty = yr + yp;
						break;
					case StageAlign.TOP_RIGHT:
						tx = xr + xp - dw;
						ty = yr + yp;
						break;
					
					case StageAlign.LEFT:
						tx = xr + xp;
						ty = yr + yp - dh * 0.5;
						break;
					
					case StageAlign.RIGHT:
						tx = xr + xp - dw;
						ty = yr + yp - dh * 0.5;
						break;
					
					case StageAlign.BOTTOM_LEFT:
						tx = xr + xp;
						ty = yr + yp - dh;
						break;
					case StageAlign.BOTTOM:
						tx = xr + xp - dw * 0.5;
						ty = yr + yp - dh;
						break;
					case StageAlign.BOTTOM_RIGHT:
						tx = xr + xp - dw;
						ty = yr + yp - dh;
						break;
					
					default :	//	center
						tx = xr + xp - dw * 0.5;
						ty = yr + yp - dh * 0.5;
				}
				
				$widget.x = tx;
				$widget.y = ty;
				
				dic = childDic[o.widgetID];
				for(i in dic){
					arrange(dic[i]);
				}
			}
			else{
				var dic:Dictionary = childDic["stage"];
				for(var i:* in dic){
					o = dic[i];
					arrange(o.widget);
				}
			}
		}
		
		
		public static function addWidget($o:WidgetParamObject):void{
			if(!$o)	return;
			
			var w:Widget = $o.widget;
			objectDic[w] = $o;
			
			var id:String = $o.widgetID;
			idDic[id] = $o;
			
			var a:WidgetArrangeObject = $o.getArrange();
			if(a){
				id = a.parentWidgetID;
				var dic:Dictionary = childDic[id] || (childDic[id] = new Dictionary(true));
				dic[w] = $o;
			}
			
			arrange(w);
		}
		
		
		public static function delWidget($o:WidgetParamObject=null):void{
			if($o){
				var w:Widget = $o.widget;
				delete	objectDic[w];
				
				var id:String = $o.widgetID;
				delete	childDic[id];
				delete	idDic[id];
				
				for(id in childDic){
					var dic:Dictionary = childDic[id];
					for(var i:* in dic){
						if(w == dic[i].widget){
							delete	dic[i];
							break;
						}
					}
				}
			}
			else{
				objectDic = new Dictionary(true);
				childDic = {};
				idDic = {};
			}
		}
	}
}