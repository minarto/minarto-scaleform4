package com.minarto.manager.widget {
	import flash.display.*;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import scaleform.clik.core.CLIK;


	public class ArrangeManager {
		protected static var objectDic:Dictionary = new Dictionary(true), idDic:* = {}, resolutionDic:* = {}, resolutionID:String;
		
		
		public function ArrangeManager(){
			throw new Error("don't create instance");
		}
		
		
		public static function setResolutionID($id:String, $minWidth:int, $maxWidth:int, $minHeight:int, $maxHeight:int):void{
			resolutionDic[$id] = {minWidth:$minWidth, maxWidth:$maxWidth, minHeight:$minHeight, maxHeight:$maxHeight};
		}
		
		
		public static function init($stage:Stage):void{
			idDic["stage"] = $stage;
			$stage.addEventListener(Event.RESIZE, function ($e:Event):void {
				var sw:int = $stage.stageWidth;
				var sh:int = $stage.stageHeight;
				
				resolutionID = "default";
				for(var id:String in resolutionDic){
					var o:* = resolutionDic[id];
					if(o.minWidth <= sw && sw < o.maxWidth && o.minHeight <= sh && sh < o.maxHeight){
						resolutionID = id;
						break;
					}
				}
				
				arrange($stage);
			});
			
			trace("ArrangeManager.init");
		}
		
		
		public static function arrange($widget:DisplayObject):void{
			if($widget && (!$widget as Stage)){
				var o:WidgetData = objectDic[$widget];
				if(!o)	return;
				
				var a:ArrangeData = o.getArrange(resolutionID);
				if(!a)	return;
				
				var s:Number = a.scale || 1;
				$widget.scaleX = s;
				$widget.scaleY = s;
				
				var po:WidgetData = idDic[a.parentWidgetID];
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
				
				var xp:Number = a.xpadding;
				var yp:Number = a.ypadding;
				
				var dw:Number = $widget.width * s;
				var dh:Number = $widget.height * s;
				
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
				
				var id:String = o.widgetID;
			}
			else{
				id = "stage";
				$widget = CLIK.stage;
			}
			
			for(var i:* in objectDic){
				o = objectDic[i];
				a = o.getArrange(resolutionID);
				if($widget != o.widget && id == a.parentWidgetID){
					arrange(o.widget);
				}
			}
		}
		
		
		public static function addWidget($o:WidgetData):void{
			if(!$o)	return;
			
			var w:DisplayObject = $o.widget;
			objectDic[w] = $o;
			
			var id:String = $o.widgetID;
			idDic[id] = $o;
			
			arrange(w);
		}
		
		
		public static function delWidget($o:WidgetData):void{
			if($o){
				delete	objectDic[$o.widget];
				delete	idDic[$o.widgetID];
			}
			else{
				objectDic = new Dictionary(true);
				idDic = {};
			}
		}
	}
}