package com.minarto.manager.widget {
	import com.minarto.controls.widget.Widget;

	public class LoadWidgetObject {
		public var src:String, //	경로
					widgetID:String, //	위젯 아이디
					widget:Widget, //	위젯 객체
					topArrange:int,	//	컨테이너 인덱스
		
					parentWidgetID:String="stage",	//	정렬시의 기준 위젯 아이디 
					xrate:Number=0, yrate:Number=0, align:String="C", //	기준 위젯으로부터의 정렬 위치
					xpadding:Number=10, ypadding:Number=10, //	정렬 위치로부터의 간격
					scaleEnable:Boolean = true;	//	스케일 적용을 받을지에 대한 여부 
	}
}