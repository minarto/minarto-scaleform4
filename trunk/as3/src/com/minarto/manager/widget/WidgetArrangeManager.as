package com.minarto.manager.widget {
	import de.polygonal.core.ObjectPool;
	
	import flash.display.*;
	import flash.events.Event;


	public class WidgetArrangeManager {
		protected static var objectDic:* = {}, widgetDic:* = {}, childDic:* = {}, widgetScale:Number = 1, minStageWidth:Number=1366, minStageHeight:Number=768, staticScale:Number = 1, pool:ObjectPool;
		
		
		public static function getWidgetScale():Number{
			return	widgetScale;
		}
		
		
		public static function init($stage:Stage, $minStageWidth:Number=1366, $minStageHeight:Number=768):void{
			minStageWidth = $minStageWidth;
			minStageHeight = $minStageHeight;
			widgetDic["stage"] = $stage;
			$stage.addEventListener(Event.RESIZE, function ($e:Event):void {
				if($stage.stageWidth < minStageWidth || $stage.stageHeight < minStageHeight){
					widgetScale = staticScale * Math.min($stage.stageWidth / minStageWidth, $stage.stageHeight / minStageHeight);
				}
				else{
					widgetScale = staticScale;
				}
				arrange(null);
			});
			
			pool = new ObjectPool(true);
			pool.allocate(10, ArrangeObject);
		}
		
		
		public static function setStaticScale($scale:Number):void{
			staticScale = $scale || 1;
			arrange(null);
		}
		public static function getStaticScale():Number{
			return	staticScale;
		}
		
		
		public static function arrange($widgetID:String):void{
			if($widgetID == "stage")	$widgetID = null;
			
			if($widgetID){
				var o:ArrangeObject = objectDic[$widgetID];
				var d:DisplayObject = widgetDic[$widgetID];
				if(!o || !d)	return;
				
				if(o.scaleEnable){
					d.scaleX = widgetScale;
					d.scaleY = widgetScale;
				}
				else{
					d.scaleX = staticScale;
					d.scaleY = staticScale;
				}
				
				var p:DisplayObject = widgetDic[o.parentWidgetID];
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
				
				var xr:Number = w * o.xrate;
				var yr:Number = h * o.yrate;
				
				var xp:Number = o.xpadding * staticScale;
				var yp:Number = o.ypadding * staticScale;
				
				var dw:Number = d.width;
				var dh:Number = d.height;
				
				switch(o.align){
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
				
				d.x = tx;
				d.y = ty;
				
				var dic:* = childDic[$widgetID];
				if(dic){
					for($widgetID in dic){
						arrange(dic[$widgetID]);
					}
				}
				
				var f:Function = o.onComplete;
				if(Boolean(f))	f(d);
			}
			else{
				dic = childDic["stage"];
				if(dic){
					for($widgetID in dic){
						arrange(dic[$widgetID]);
					}
				}
			}
		}
		
		
		public static function addWidget($widgetID:String, $widget:DisplayObject):void{
			if(!$widgetID || !$widget)	return;
			widgetDic[$widgetID] = $widget;
			arrange($widgetID);
		}
		
		
		public static function delWidget($widgetID:String=null):void{
			if($widgetID){
				delete	widgetDic[$widgetID];
			}
			else{
				widgetDic = {};
			}
		}
		
		
		public static function addArrange($widgetID:String, $parentWidgetID:String="stage", $xrate:Number=0, $yrate:Number=0, $align:String="CENTER", $xpadding:Number=10, $ypadding:Number=10, $scaleEnable:Boolean=true, $onComplete:Function=null):void{
			if(!$widgetID)	return;
			
			if(!pool){
				pool = new ObjectPool(true);
				pool.allocate(10, ArrangeObject);
			}
			
			delArrange($widgetID);
			
			var o:ArrangeObject = pool.object;
			objectDic[$widgetID] = o;
			
			var dic:* = childDic[$parentWidgetID];
			if(!dic){
				dic = {$widgetID:$widgetID};
				childDic[$parentWidgetID] = dic;
			}
			o.parentWidgetID = $parentWidgetID;
			o.xrate = $xrate;
			o.yrate = $yrate;
			o.align = $align;
			o.xpadding = $xpadding;
			o.ypadding = $ypadding;
			o.scaleEnable = $scaleEnable;
			o.onComplete = $onComplete;
			
			arrange($widgetID);
		}
		
		
		public static function delArrange($widgetID:String):void{
			if(!pool){
				pool = new ObjectPool(true);
				pool.allocate(10, ArrangeObject);
			}
			
			if($widgetID){
				var o:ArrangeObject = objectDic[$widgetID];
				if(o){
					var id:String = o.parentWidgetID;
					arrange(id);
					pool.object = o;
				}
				
				delete objectDic[$widgetID];
				delete childDic[$widgetID];
				
				for(id in childDic){
					var dic:* = objectDic[id];
					delete	dic[$widgetID];
				}
			}
			else{
				for(id in objectDic){
					o = objectDic[id];
					pool.object = o;
				}
				
				objectDic = {};
				childDic = {};
			}
		}
	}
}

internal class ArrangeObject {
	public var parentWidgetID:String, widgetID:String, xrate:Number = 0, yrate:Number = 0, align:String, xpadding:Number=10, ypadding:Number=10, scaleEnable:Boolean = true, onComplete:Function;
}