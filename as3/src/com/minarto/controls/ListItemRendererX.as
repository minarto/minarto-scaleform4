package com.minarto.controls
{
	import flash.events.*;
	import flash.utils.Timer;
	
	import scaleform.clik.controls.ListItemRenderer;
	import scaleform.clik.data.ListData;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.gfx.MouseEventEx;
	
	
	public class ListItemRendererX extends ListItemRenderer
	{
		override public function toString():String 
		{
			return "[com.minarto.controls.ListItemRendererX " + name + "]";
		}
		
		
		/**
		 * 기본 클래스는 우클릭이 막혀있어서 수정 
		 * @param $e
		 * 
		 */	
		override protected function handleMousePress($e:MouseEvent):void
		{
			var sfEvent:MouseEventEx = $e as MouseEventEx;
			var mouseIdx:uint = sfEvent ? sfEvent.mouseIdx : 0;
			var btnIdx:uint = sfEvent ? sfEvent.buttonIdx : 0;
			
			//if (btnIdx != 0) { return; }
			
			_mouseDown |= 1 << mouseIdx;
			
			if (enabled)
			{ 
				setState("down");
				
				// Uses single controller like AS2.
				if (autoRepeat && _repeatTimer == null)
				{
					_autoRepeatEvent = new ButtonEvent(ButtonEvent.CLICK, true, false, mouseIdx, btnIdx, false, true);
					_repeatTimer = new Timer(repeatDelay, 1);
					_repeatTimer.addEventListener(TimerEvent.TIMER_COMPLETE, beginRepeat, false, 0, true);
					_repeatTimer.start();
				}
				
				var sfButtonEvent:ButtonEvent = new ButtonEvent(ButtonEvent.PRESS, true, false, mouseIdx, btnIdx, false, false);
				dispatchEventAndSound(sfButtonEvent);
			}
		}
		
		
		/**
		 * 기본 클래스는 우클릭이 막혀있어서 수정 
		 * @param $e
		 * 
		 */		
		override protected function handleMouseRelease($e:MouseEvent):void
		{
			//super.handleMouseRelease($e);
			
			_autoRepeatEvent = null;
			if (!enabled)	return;
			
			var sfEvent:MouseEventEx = $e as MouseEventEx;
			var mouseIdx:uint = sfEvent ? sfEvent.mouseIdx : 0;
			var btnIdx:uint = sfEvent ? sfEvent.buttonIdx : 0;
			
			//	우클릭이 막혀있어서 수정 
			//if (btnIdx)	return;	
			
			_mouseDown ^= 1 << mouseIdx;
			
			// Always remove timer, in case autoRepeat was turned off during press.
			if (!_mouseDown && _repeatTimer)
			{
				_repeatTimer.stop(); _repeatTimer.reset();
				_repeatTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, beginRepeat);
				_repeatTimer.removeEventListener(TimerEvent.TIMER, handleRepeat);
				_repeatTimer = null;
			}
			
			setState("release");
			handleClick(mouseIdx);
			
			if (!_isRepeating)
			{
				dispatchEventAndSound(new ButtonEvent(ButtonEvent.CLICK, true, false, mouseIdx, btnIdx, false, false));
			}
			
			_isRepeating = false;
		}
	}
}