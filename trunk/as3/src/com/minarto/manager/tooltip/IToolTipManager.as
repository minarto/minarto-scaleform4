package com.minarto.manager.tooltip {
	public interface IToolTipManager {
		function regist(...$buttons):void;
		function unRegist(...$buttons):void;
		
		function addToolTip(...$datas):void;
		function delToolTip():void;
	}
}