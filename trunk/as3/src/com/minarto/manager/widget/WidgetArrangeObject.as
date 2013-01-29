package com.minarto.manager.widget {
	public class WidgetArrangeObject {
		public static const DEFAULT:String = "default";
		
		
		public var parentWidgetID:String="stage",	//	정렬시의 기준 위젯 아이디 
					xrate:Number=0, yrate:Number=0, align:String="C", //	기준 위젯으로부터의 정렬 위치
					xpadding:int=10, ypadding:int=10, //	정렬 위치로부터의 간격
					scaleEnable:Boolean = true;	//	스케일 적용을 받을지에 대한 여부 
	}
}