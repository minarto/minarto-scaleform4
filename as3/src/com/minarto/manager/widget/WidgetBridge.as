package com.minarto.manager.widget {
	import flash.display.*;
	import flash.events.*;
	import flash.external.ExternalInterface;
	
	import scaleform.gfx.Extensions;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class WidgetBridge extends EventDispatcher {
		private static var _instance:WidgetBridge = new WidgetBridge, _manager:IWidgetManager;
		
		
		public function WidgetBridge() {
			if(_instance)	throw new Error("don't create instance");
		}
		
		
		public static function init($manager:IWidgetManager):void{
			_manager = $manager;
			
			if(ExternalInterface.available && Extensions.isScaleform)	ExternalInterface.call("WidgetBridge", WidgetBridge);
			trace("WidgetBridge");
		}
		
		
		public static function setContainer($container:DisplayObjectContainer, $topArrange:uint=0):void{
			_manager.setContainer($container, $topArrange);
		}
		
		
		public static function loadWidget($widgetID:String, $src:String):void{
			_manager.loadWidget($widgetID, $src);
		}
		
		
		public static function setWidgetData($widgetID:String, $data:*):void{
			_manager.setWidgetData($widgetID, $data);
		}
		
		
		public function delWidgetByID($widgetID:String):void{
			_manager.delWidgetByID($widgetID);
		}
		
		
		public static function delWidget($widget:DisplayObject):void{
			_manager.delWidget($widget);
		}
		
		
		public static function delWidgetAll():void{
			_manager.delWidgetAll();
		}
		
		
		public static function action($e:Event):void{
			_instance.dispatchEvent($e);
		}
		
		
		public function open($widget:DisplayObject):DisplayObject {
			return	_manager.open($widget);
		}
		
		
		public function openByID($widgetID:String):DisplayObject {
			return	open(getWidget($widgetID));
		}
		
		
		public function close($widget:DisplayObject):DisplayObject {
			return	_manager.close($widget);
		}
		
		
		public function closeByID($widgetID:String):DisplayObject {
			return	_manager.close(getWidget($widgetID));
		}
		
		
		public function getTopWidget($containerIndex:int=0):DisplayObject {
			return	_manager.getTopWidget($containerIndex);
		}
		
		
		public function getFocusWidget($controllerIdx:uint=0):InteractiveObject{
			return	_manager.getFocusWidget($controllerIdx);
		} 
		
		
		public static function getWidget($widgetID:String):DisplayObject {
			return	_manager.getWidget($widgetID);
		}
	}
}