package com.minarto.controls.tooltip {
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.utils.*;
	
	import scaleform.gfx.InteractiveObjectEx;
	import com.minarto.manager.tooltip.IToolTipManager;
	
	/**
	 * @author KIMMINHWAN
	 */
	public class ToolTipContainerBase extends Sprite implements IToolTipManager {
		private var target:InteractiveObject, btnDic:Dictionary = new Dictionary(true), delay:uint = 300, delayID:uint;
		
		public var toolTip:ToolTipBase, toolTip1:ToolTipBase;
		
		
		public function ToolTipContainerBase() {
			InteractiveObjectEx.setHitTestDisable(this, true);
			
			visible = false;
			toolTip.visible = false;
			toolTip1.visible = false;
		}
		
		
		public function regist(...$buttons):void{
			for(var p:* in $buttons){
				var b:InteractiveObject = $buttons[p];
				b.addEventListener(MouseEvent.ROLL_OVER, hnRollOver);
				b.addEventListener(MouseEvent.ROLL_OUT, hnRollOut);
				
				btnDic[b] = b;
			}
		}
		
		
		public function unRegist(...$buttons) : void {
			if($buttons.length){
				for(var p:* in $buttons){
					var b:InteractiveObject = $buttons[p];
					b.removeEventListener(MouseEvent.ROLL_OVER, hnRollOver);
					b.removeEventListener(MouseEvent.ROLL_OUT, hnRollOut);
					
					delete	btnDic[b];
				}
			}
			else{
				for(p in btnDic){
					b = btnDic[p];
					b.removeEventListener(MouseEvent.ROLL_OVER, hnRollOver);
					b.removeEventListener(MouseEvent.ROLL_OUT, hnRollOut);
				}
				
				btnDic = new Dictionary(true);
			}
		}
		
		
		protected function hnRollOver($e:MouseEvent) : void {
			delToolTip();
			target = $e.target as InteractiveObject;
			if(target.hasOwnProperty("data") && target["data"])	delayID = setTimeout(delayToolTip, delay);
		}
		
		
		protected function hnRollOut($e:MouseEvent) : void {
			delToolTip();
		}
		
		
		protected function delayToolTip():void {
			if(target)	addToolTip(target["data"]);
		}
		
		
		public function addToolTip(...$datas):void{
			delToolTip();
			
			if($datas.length){
				for(var i:* in $datas){
					switch(i){
						case 1 :
							var t:ToolTipBase = toolTip1;
							break;
						default :
							t = toolTip;
					}
					
					t.setData($datas[i]);
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
	}
}
