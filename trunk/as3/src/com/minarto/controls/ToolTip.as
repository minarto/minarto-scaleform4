package com.minarto.controls {
	import com.minarto.data.ListBinding;
	import com.minarto.manager.ImageManager;
	import com.minarto.utils.GPool;
	
	import de.polygonal.core.ObjectPool;
	
	import flash.display.*;
	
	import scaleform.clik.core.UIComponent;

	
	/**
	 * @author KIMMINHWAN
	 */
	public class ToolTip extends UIComponent {
		private var _autoSize:Boolean = true;
		
		protected var txtHeight:Number,
						paddingTop:int = 10, paddingLeft:int = 10, paddingRight:int = 10, paddingBottom:int = 10,
						minWidth:int = 300, leading:Number, spacing:int = 10,
						bMain:Bitmap, currentWidth:int, currentHeight:int, data:*;
		
		
		public function get autoSize():Boolean {
			return _autoSize;
		}
		public function set autoSize($v:Boolean):void {
			if (_autoSize == $v)	return;
			_autoSize = $v;
			invalidate();
		}
		
		
		override protected function configUI():void {
			super.configUI();
			
			bMain = GPool.getPool(Bitmap).object;
			bMain.x = paddingLeft;
			bMain.y = currentHeight + paddingTop;
			addChild(bMain);
		}
		
		
		public function setData($d:*) : void {
			delBind();
			data = $d;
			addBind();
			//removeChildren();
			//invalidate();
		}
		
		
		protected function delBind():void{
			//ListBinding.delBind(data, invalidate, HashKeyManager.url);
		}
		
		
		protected function addBind():void{
			//ListBinding.addBind(data, invalidate, HashKeyManager.url);
		}
		
		
		override protected function draw():void {
			if(!data)	return;
		}
	}
}
