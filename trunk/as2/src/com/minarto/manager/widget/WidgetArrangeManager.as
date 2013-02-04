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
	
	
	public static function arrange($widget:MovieClip):Void{
		if ($widget) {
			for (var i:Number in objectDic) {
				var o:LoadWidgetObject = objectDic[i];
				if (o.widget == $widget) {
					break;
				}
			}
			if (!o)	return;
			
			if(o.scaleEnable){
				$widget._xscale = widgetScale * 100;
				$widget._yscale = widgetScale * 100;
			}
			else{
				$widget._xscale = staticScale * 100;
				$widget._yscale = staticScale * 100;
			}
			
			if (o.parentWidgetID == "stage") {
				var w:Number = Stage.width;
				var h:Number = Stage.height;
			}
			else {
				var p:MovieClip = widgetDic[o.parentWidgetID];
				if(p){
					w = p._width;
					h = p._height;
				}
				else{
					return;
				}
			}
			
			
			var xr:Number = w * o.xrate;
			var yr:Number = h * o.yrate;
			
			var xp:Number = o.xpadding * staticScale;
			var yp:Number = o.ypadding * staticScale;
			
			var dw:Number = $widget._width;
			var dh:Number = $widget._height;
			
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
			
			$widget._x = tx;
			$widget._y = ty;
			
			var dic = childDic[$widgetID];
			for($widgetID in dic){
				arrange(dic[$widgetID]);
			}
		}
		else{
			dic = childDic["stage"];
			for (i in dic) {
				$widget = dic[i];
				arrange($widget);
			}
		}
	}
	
	
	public static function addArrange($o:LoadWidgetObject):Void{
		if(!$o)	return;
		
		var w:MovieClip = $o.widget;
		objectDic[w] = $o;
		widgetDic[$o.widgetID] = w;
		
		var dic:Array = childDic[$o.parentWidgetID] || (childDic[$o.parentWidgetID] = []);
		dic.push(w);
		
		arrange(w);
	}
	
	
	public static function delArrange():Void{
		objectDic = {};
		childDic = {};
	}
}