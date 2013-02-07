package com.minarto.manager.widget {
	import flash.display.*;

	public interface IWidgetManager {
		function setContainer($container:DisplayObjectContainer, $topArrange:uint=0):void;
		
		
		function loadWidget($src:String):void;
		
		
		function setWidgetData($widgetID:String, $data:WidgetData):void;
		
		
		function delWidget($widget:DisplayObject):void;
		function delWidgetByID($widgetID:String):void;
		function delWidgetAll():void;
			
			
		function open($widget:DisplayObject):DisplayObject;
		function openByID($widgetID:String):DisplayObject;
		
		
		function close($widget:DisplayObject):DisplayObject;
		function closeByID($widgetID:String):DisplayObject;
		
		
		function getTopWidget($containerIndex:uint=0):DisplayObject;

		
		function getFocusWidget($controllerIdx:uint=0):InteractiveObject;
		
		
		function getWidget($widgetID:String):DisplayObject;
	}
}