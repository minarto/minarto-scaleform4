package com.minarto.controls
{
	import com.minarto.data.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.Timer;
	
	import scaleform.clik.controls.Button;
	import scaleform.clik.core.UIComponent;
	import scaleform.gfx.InteractiveObjectEx;
	
	
	public class ToolTipContainerBase extends Sprite
	{
		override public function toString():String
		{
			return "[com.minarto.tooltip.ToolTipContainerBase " + name + "]";
		}
		
		
		public var toolTip:UIComponent;
		
		
		protected const binding:Bind = BindDic.get("__ToolTip__"), _timer:Timer = new Timer(300, 1);
		
		
		protected var currentToolTip:DisplayObject, _targetBtn:Button;
		
		
		public function ToolTipContainerBase()
		{
			visible = false;
			InteractiveObjectEx.setHitTestDisable(this, true);
			addEventListener(Event.ADDED_TO_STAGE, _addToStage);
			
			binding.addPlay("__disable__", _onDisableToolTip);
			
			if(toolTip)	removeChild(toolTip as DisplayObject);
		}
		
		
		protected function _onDisableToolTip($on:Boolean):void
		{
			onMouseOut(null);
			
			if($on)
			{
				stage.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				stage.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			}
			else
			{
				stage.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				stage.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			}
		}		
		
		
		protected function _addToStage($e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _addToStage);
			
			_onDisableToolTip(binding.getAt("__toolTipDisable__"));
		}
		
		
		protected function onMouseOver($e:MouseEvent):void
		{
			onMouseOut(null);
			
			_targetBtn = $e.target as Button;
			if(_targetBtn)
			{
				if(!_targetBtn.data && !_targetBtn.label)	return;
				
				_timer.addEventListener(TimerEvent.TIMER_COMPLETE, setToolTip);
				_timer.reset();
				_timer.start();
			}
		}
		
		
		
		
		protected function setToolTip($e:TimerEvent):void
		{
			var data:Object;
			
			if(!_targetBtn)	return;

			data = _targetBtn.data;
			if(!data)	return;

			if(data.hasOwnProperty("__isToolTip__") && data["__isToolTip__"])
			{
				currentToolTip = data["__toolTipComponent__"];
				
				if(currentToolTip && currentToolTip.hasOwnProperty("setData"))
				{
					currentToolTip["setData"](data);
				}
			}
			
			if(currentToolTip)
			{
				onMouseMove(null);
				
				addChild(currentToolTip);
				visible = true;
			}
		}
		
		
		protected function onMouseMove($e:Event):void
		{
			var tx:Number = mouseX - currentToolTip.width, ty:Number = mouseY - currentToolTip.height;
			
			if(0 > tx)	tx = 0;
			if(0 > ty)	ty = 0;
			
			currentToolTip.x = tx;
			currentToolTip.y = ty;
		}
		
		
		protected function onMouseOut($e:MouseEvent):void
		{
			visible = false;
			
			currentToolTip = null;
			
			while(numChildren)
			{
				removeChildAt(0);
			}
		}
	}
}