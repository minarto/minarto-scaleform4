import com.minarto.manager.widget.*;
import flash.external.ExternalInterface;
import gfx.events.EventTypes;


class com.minarto.manager.widget.WidgetArrangeManager {
	private static var objectDic = {}, widgetDic = {}, childDic = {}, widgetScale:Number = 1, minStageWidth:Number=1366, minStageHeight:Number=768, staticScale:Number = 1;
		
		
	public static function getWidgetScale():Number{
		return	widgetScale;new 
	}
	
	
	private function onReSize():Void {
		if(Stage.width < minStageWidth || Stage.height < minStageHeight){
			widgetScale = staticScale * Math.min(Stage.width / minStageWidth, Stage.height / minStageHeight);
		}
		else{
			widgetScale = staticScale;
		}
		arrange(null);
	}
	
	
	public static function init($root:MovieClip, $minStageWidth:Number=1366, $minStageHeight:Number=768):Void{
		minStageWidth = $minStageWidth;
		minStageHeight = $minStageHeight;
		$root.addEventListener(EventTypes.RESIZE, this, "onReSize");
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
			var o = objectDic[$widgetID];
			var d:MovieClip = widgetDic[$widgetID];
			if(!o || !d)	return;
			
			if(o.scaleEnable){
				d._xscale = widgetScale * 100;
				d._yscale = widgetScale * 100;
			}
			else{
				d._xscale = staticScale * 100;
				d._yscale = staticScale * 100;
			}
			
			var p:MovieClip = widgetDic[o.parentWidgetID];
			if(p){
				if(o.parentWidgetID == "stage"){
					var w:Number = Stage.width;
					var h:Number = Stage.height;
				}
				else{
					w = p._width;
					h = p._height;
				}
			}
			else{
				return;
			}
			
			var xr:Number = w * o.xrate;
			var yr:Number = h * o.yrate;
			
			var xp:Number = o.xpadding * staticScale;
			var yp:Number = o.ypadding * staticScale;
			
			var dw:Number = d._width;
			var dh:Number = d._height;
			
			switch(o.align){
				case "T":
					var tx:Number = xr + xp - dw * 0.5;
					var ty:Number = yr + yp;
					break;
				case "TL":
					tx = xr + xp;
					ty = yr + yp;
					break;
				case "TR":
					tx = xr + xp - dw;
					ty = yr + yp;
					break;
				
				case "L":
					tx = xr + xp;
					ty = yr + yp - dh * 0.5;
					break;
				
				case "R":
					tx = xr + xp - dw;
					ty = yr + yp - dh * 0.5;
					break;
				
				case "BL":
					tx = xr + xp;
					ty = yr + yp - dh;
					break;
				case "B":
					tx = xr + xp - dw * 0.5;
					ty = yr + yp - dh;
					break;
				case "BR":
					tx = xr + xp - dw;
					ty = yr + yp - dh;
					break;
				
				default :	//	"C"
					tx = xr + xp - dw * 0.5;
					ty = yr + yp - dh * 0.5;
			}
			
			d._x = tx;
			d._y = ty;
			
			var dic = childDic[$widgetID];
			for($widgetID in dic){
				arrange(dic[$widgetID]);
			}
			
			if(o.onComplete && o.onCompleteScope)	o.onCompleteScope[o.onComplete](d);
		}
		else{
			dic = childDic["stage"];
			for($widgetID in dic){
				arrange(dic[$widgetID]);
			}
		}
	}
	
	
	public static function addWidget($widgetID:String, $widget:MovieClip):Void{
		if(!$widgetID || !$widget)	return;
		widgetDic[$widgetID] = $widget;
		arrange($widgetID);
	}
	
	
	public static function delWidget($widgetID:String):void{
		if($widgetID){
			delete	widgetDic[$widgetID];
		}
		else{
			widgetDic = {};
		}
	}
	
	
	public static function addArrange($widgetID:String, $parentWidgetID:String, $xrate:Number, $yrate:Number, $align:String, $xpadding:Number, $ypadding:Number, $scaleEnable:Boolean, $onComplete:String, $onCompleteScope:Object):Void{
		if(!$widgetID)	return;
		
		delArrange($widgetID);
		
		$parentWidgetID = $parentWidgetID || "stage";
		
		var o = {};
		objectDic[$widgetID] = o;
		
		o.parentWidgetID = $parentWidgetID;
		o.xrate = $xrate || 0;
		o.yrate = $yrate || 0;
		o.align = $align;
		o.xpadding = isNaN($xpadding) ? 10 : $xpadding;
		o.ypadding = isNaN($ypadding) ? 10 : $ypadding;;
		o.scaleEnable = $scaleEnable;
		o.onComplete = $onComplete;
		o.onCompleteScope = $onCompleteScope;
		
		o = childDic[$parentWidgetID];
		if(!o){
			o = {$widgetID:$widgetID};
			childDic[$parentWidgetID] = o;
		}
		
		arrange($widgetID);
	}
	
	
	public static function delArrange($widgetID:String):Void{
		if($widgetID){
			var o = objectDic[$widgetID];
			if(o){
				var id:String = o.parentWidgetID;
				arrange(id);
			}
			
			delete objectDic[$widgetID];
			delete childDic[$widgetID];
			
			for(id in childDic){
				o = objectDic[id];
				delete	o[$widgetID];
			}
		}
		else{
			objectDic = {};
			childDic = {};
		}
	}
}