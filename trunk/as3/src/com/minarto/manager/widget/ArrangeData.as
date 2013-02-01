package com.minarto.manager.widget {
	public class ArrangeData {
		public var width:uint, height:uint,	//	정렬 기준 해상도
		parentWidgetID:String="stage",	//	정렬시의 기준 위젯 아이디 
			xrate:Number=0, yrate:Number=0, align:String="C", //	기준 위젯으로부터의 정렬 위치
			xpadding:int=10, ypadding:int=10, //	정렬 위치로부터의 간격
			scale:Number = 1;	//	스케일 
	}
}