package com.minarto.manager.tooltip {
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.utils.*;
	
	import scaleform.gfx.InteractiveObjectEx;
	import com.minarto.controls.ToolTipBase;
	
	/**
	 * @author KIMMINHWAN
	 */
	public class ToolTipContainerBase extends Sprite implements IToolTipManager {
		private var target:InteractiveObject, btnDic:Dictionary = new Dictionary(true), toolTipDelay:uint = 300, delayID:uint;
		
		public var toolTip:ToolTipBase, toolTip1:ToolTipBase;
		
		
		public function ToolTipContainerBase() {
			InteractiveObjectEx.setHitTestDisable(this, true);
			
			visible = false;
			toolTip.visible = false;
			toolTip1.visible = false;
		}
		
		
		public function regist(...$button):void{
			for(var p:* in $button){
				var b:InteractiveObject = $button[p];
				b.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
				b.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
				
				btnDic[$button] = $button;
			}
		}
		
		
		public function unRegist(...$button) : void {
			if($button.length){
				for(var p:* in $button){
					var b:InteractiveObject = $button[p];
					b.removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
					b.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
					
					delete	btnDic[b];
				}
			}
			else{
				for(p in btnDic){
					b = btnDic[p];
					b.removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
					b.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
				}
				
				btnDic = new Dictionary(true);
			}
		}
		
		
		protected function onRollOver($e:MouseEvent) : void {
			delToolTip();
			target = $e.target as InteractiveObject;
			if(target.hasOwnProperty("data") && target["data"])	delayID = setTimeout(delayToolTip, toolTipDelay);
		}
		
		
		protected function onRollOut($e:MouseEvent) : void {
			delToolTip();
		}
		
		
		protected function delayToolTip():void {
			if(target)	addToolTip(target["data"]);
		}
		
		
		public function addToolTip(...$d):void{
			delToolTip();
			
			var c:uint = $d.length;
			if(c){
				for(var i:uint = 0; i<c; ++ i){
					switch(i){
						case 1 :
							var t:ToolTipBase = toolTip1;
							break;
						default :
							t = toolTip;
					}
					
					t.setData($d);
					t.visible = true;
				}
				visible = true;
			}
			else{
				toolTip.visible = false;
				toolTip1.visible = false;
			}
		}
		
		
		public function delToolTip():void{
			visible = false;
			clearTimeout(delayID);
		}
		
		
		override public function toString() : String {
			return "barunson.libs.manager.tooltip.ToolTipContainerBase";
		}
	}
}
