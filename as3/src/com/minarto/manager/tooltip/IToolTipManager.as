package com.minarto.manager.tooltip {
	public interface IToolTipManager {
		function regist(...$button):void;
		function unRegist(...$button):void;
		
		function addToolTip(...$d):void;
		function delToolTip():void;
	}
}