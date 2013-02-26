package com.minarto.controls {
	import scaleform.clik.constants.*;
	import scaleform.clik.controls.CoreList;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.interfaces.*;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.utils.Padding;
	
	
	public class TreeList extends CoreList {
		[Inspectable(defaultValue="normal", enumeration="normal,wrap,stick")]
		public var wrapping:String = WrappingMode.NORMAL;
		
		[Inspectable(defaultValue="0")]
		public var externalColumnCount:Number = 0;
		
		protected var _scrollPosition:uint = 0;
		protected var _autoScrollBar:Boolean = false;
		protected var _scrollBarValue:Object;
		protected var _margin:Number = 0;
		protected var _scrollBar:IScrollBar;
		protected var _totalColumns:uint = 0;
		
		
		override public function set selectedIndex($v:int):void {
			if ($v == _selectedIndex || $v == _newSelectedIndex) return;
			_newSelectedIndex = $v;
			invalidateSelectedIndex();
		}
		
		
		public function get scrollPosition():Number { return _scrollPosition; }
		public function set scrollPosition($v:Number):void {
			var c:uint = _renderers.length;
			
			var maxScrollPosition:int = Math.ceil((_dataProvider.length - c) / c); // @TODO: Seems like this can be cached on invalidate.
			$v = Math.max(0, Math.min(maxScrollPosition, Math.round($v)));
			if (_scrollPosition == $v) return;
			_scrollPosition = $v;
			invalidateData();
		}
		
		
		override public function getRendererAt(index:uint, offset:int=0):IListItemRenderer {
			var r:IListItemRenderer;
			
			if (_renderers == null) return r;
			
			var c:uint = _renderers.length;
			
			var rendererIndex:uint = index - offset * c;
			if (rendererIndex >= c) return r;
			
			r = _renderers[rendererIndex] as IListItemRenderer;
			return r;
		}
		
		
		override public function scrollToIndex(index:uint):void {
			if (_totalRenderers == 0) return;
			
			var c:uint = _renderers ? _renderers.length : 0;
			if (c == 0) return;
			
			var startIndex:Number = _scrollPosition * c;
			
			if (index >= startIndex && index < startIndex + c) {
				return;
			} else if (index < startIndex) {
				scrollPosition = (index / c >> 0);
			} else {
				scrollPosition = Math.floor(index / c) - c + 1;
			}
		}
		
		
		override public function handleInput($e:InputEvent):void {
			if ($e.handled) return;
			
			// Pass on to selected renderer first
			var renderer:IListItemRenderer = getRendererAt(_selectedIndex, _scrollPosition);
			if (renderer != null) {
				renderer.handleInput($e); // Since we are just passing on the event, it won't bubble, and should properly stopPropagation.
				if ($e.handled) { return; }
			}
			
			// Only allow actions on key down, but still set handled=true when it would otherwise be handled.
			var details:InputDetails = $e.details;
			var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			var nextIndex:int = NaN;
			var nav:String = details.navEquivalent;
			
			var rc:uint = _renderers.length;
			var dc:uint = _dataProvider.length - 1;
			
			// Directional navigation commands differ depending on layout direction.
			switch (nav) {
				case NavigationCode.RIGHT:
					nextIndex = _selectedIndex + rc;
					break;
				case NavigationCode.LEFT:
					nextIndex = _selectedIndex - rc;
					break;
				case NavigationCode.UP:
					nextIndex = _selectedIndex - 1;
					break;
				case NavigationCode.DOWN:
					nextIndex = _selectedIndex + 1;
					break;
			}
			
			if (isNaN(nextIndex)) {
				// These navigation commands don't change depending on direction.
				switch (nav) {
					case NavigationCode.HOME:
						nextIndex = 0;
						break;
					case NavigationCode.END:
						nextIndex = dc;
						break;
					case NavigationCode.PAGE_DOWN:
						nextIndex = Math.min(dc, _selectedIndex + rc);
						break;
					case NavigationCode.PAGE_UP:
						nextIndex = Math.max(0, _selectedIndex - rc);
						break;
				}
			}
			
			if (!isNaN(nextIndex)) {
				if (!keyPress) { 
					$e.handled = true;
					return;
				}
				if (nextIndex >= 0 && nextIndex < dc + 1) {
					selectedIndex = Math.max(0, Math.min(dc, nextIndex));
					$e.handled = true;
				}
				else if (wrapping == WrappingMode.STICK) {
					nextIndex = Math.max(0, Math.min(dc, nextIndex));
					if (selectedIndex != nextIndex) { 
						selectedIndex = nextIndex; 
					}
					$e.handled = true;
				} 
				else if (wrapping == WrappingMode.WRAP) {
					selectedIndex = (nextIndex < 0) ? dc : (selectedIndex < dc) ? dc : 0;
					$e.handled = true;
				}
			}
		}
	}
}