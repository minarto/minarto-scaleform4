package com.minarto.controls
{
	import com.minarto.data.*;
	import com.minarto.manager.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import scaleform.clik.controls.*;
	import scaleform.clik.core.CLIK;
	import scaleform.clik.managers.PopUpManager;
	import scaleform.gfx.*;
	

	/**
	 * @author minarto
	 */
	public class AbsMain extends Sprite
	{
		/**
		 * Binding
		 */
		public var setValue:Function = BindingDic.setValue, event:Function = BindingDic.event;
					
					
		public function setVisible($b:Boolean):void{
			stage.visible = $b;
		}
		
		
		public function AbsMain()
		{
			Extensions.enabled = true;
			PopUpManager.init(stage);
			CLIK.initialize(stage, null);
		}
		
		
		/**
		 * 현재 마우스 위치가 UI인지 아닌지
		 */
		public function getIsUI():Boolean{
			return	Extensions.getMouseTopMostEntity();
		}
		
		
		/**
		 * 현재 포커스가 입력창인지 아닌지
		 */
		public function getIsInpput():Boolean{
			var f:InteractiveObject = stage.focus;
			
			return	f as TextField || f as TextInput || f as TextArea;
		}
		
		
		/**
		 * 
		 */
		protected function configUI($e:Event=null):void{
			stage.doubleClickEnabled = false;
		}
		
		
		/**
		 * 
		 */
		public function add($src:String, $vars:*):void{
			
		}
	}
}