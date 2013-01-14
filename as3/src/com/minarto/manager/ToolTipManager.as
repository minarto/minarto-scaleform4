package com.minarto.manager {
	import com.minarto.controls.ToolTip;
	
	import flash.display.*;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.utils.*;
	
	import scaleform.clik.controls.Button;
	import scaleform.clik.core.UIComponent;
	import scaleform.gfx.*;
	
	/**
	 * @author KIMMINHWAN
	 */
	public class ToolTipManager extends Sprite {
		protected static var _instance:ToolTipManager;
		public static function getInstance():ToolTipManager{
			return	_instance;
		}
		
		
		protected var currentTarget:InteractiveObject, btnDic:Dictionary = new Dictionary(true), toolTipDelay:uint = 300, toolTipDelayID:uint, toolTipDataDic:Dictionary = new Dictionary(true);
		
		public var toolTip:ToolTip, toolTip1:ToolTip;
		
		
		public function ToolTipManager() {
			if(_instance)	throw 	new Error("don't create instance");
			
			_instance = this;
			
			InteractiveObjectEx.setHitTestDisable(this, true);
			
			toolTip.visible = false;
			toolTip1.visible = false;
			
			if(ExternalInterface.available && Extensions.isScaleform)	ExternalInterface.call("ToolTipManager", this);
			trace("ToolTipManager init");
		}		
		
		override public function toString() : String {
			return "com.minarto.manager.tooltip.ToolTipManager";
		}
		
		
		public function regist($button:InteractiveObject):void{
			if($button.hasOwnProperty("data")){
				var d:* = $button["data"];
				if($button == currentTarget && $button.visible && d){
					toolTip.visible = false;
					toolTip.setData(d);
					toolTip.visible = true;
				}
				
				$button.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
				$button.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
				btnDic[$button] = $button;
			}
		}
		
		
		public function unRegist($button:InteractiveObject) : void {
			if($button){
				$button.removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
				$button.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
				delete btnDic[$button];
			}
			else{
				for(var p:* in btnDic){
					$button = btnDic[p];
					$button.removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
					$button.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
				}
				
				btnDic = new Dictionary(true);
			}
		}


		protected function onRollOver($e:MouseEvent) : void {
			delToolTip();
			currentTarget = $e.target as Button;
			if(currentTarget["data"])	toolTipDelayID = setTimeout(delayToolTip, toolTipDelay);
		}
		
		
		protected function delayToolTip():void {
			if(currentTarget)	toolTip.setData(currentTarget["data"]);
		}
		

		protected function onRollOut($e:MouseEvent) : void {
			delToolTip();
		}
		
		
		public function createToolTip($d:*):DisplayObject{
			clearTimeout(toolTipDelayID);
			toolTip.setData($d);
			return	toolTip;
		}
		
		
		public function delToolTip():void{
			clearTimeout(toolTipDelayID);
			currentTarget = null;
			toolTip.visible = false;
			toolTip1.visible = false;
			toolTip.setData(null);
			toolTip1.setData(null);
		}
	}
}
