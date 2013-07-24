package com.minarto.controls.tooltip {
	import com.minarto.manager.IToolTipContainer;
	
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.utils.*;
	
	import scaleform.gfx.InteractiveObjectEx;
	
	/**
	 * @author KIMMINHWAN
	 */
	public class SampleToolTipContainerBase extends Sprite implements IToolTipContainer {
		private var target:InteractiveObject, dic:Dictionary = new Dictionary(true), delay:uint = 300, delayID:uint;
		
		public var toolTip:ToolTipBase, toolTip1:ToolTipBase;
		
		
		public function SampleToolTipContainerBase() {
			InteractiveObjectEx.setHitTestDisable(this, true);
			
			visible = false;
			toolTip.visible = false;
			toolTip1.visible = false;
		}
		
		
		public function add(...$btns):void{
			var p:*, b:InteractiveObject;
			
			for(p in $btns){
				b = $btns[p];
				b.addEventListener(MouseEvent.ROLL_OVER, hnRollOver);
				b.addEventListener(MouseEvent.ROLL_OUT, hnRollOut);
				
				dic[b] = b;
			}
		}
		
		
		public function del(...$btns) : void {
			if($btns.length){
				for(var p:* in $btns){
					var b:InteractiveObject = $btns[p];
					b.removeEventListener(MouseEvent.ROLL_OVER, hnRollOver);
					b.removeEventListener(MouseEvent.ROLL_OUT, hnRollOut);
					
					delete	dic[b];
				}
			}
			else{
				for(p in dic){
					b = dic[p];
					b.removeEventListener(MouseEvent.ROLL_OVER, hnRollOver);
					b.removeEventListener(MouseEvent.ROLL_OUT, hnRollOut);
				}
				
				dic = new Dictionary(true);
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
