package com.minarto.manager.widget {
	import com.minarto.controls.widget.Widget;

	public class WidgetParamObject {
		protected var arranges:* = {};	//	정렬 정보
		
		
		public var src:String, //	경로
		widgetID:String, //	위젯 아이디
		widget:Widget, //	위젯 객체
		containerIndex:int;	//	컨테이너 인덱스
		
		
		/**
		 * 현재 해상도의 정렬 정보 가져오기 
		 * @return 
		 * 
		 */		
		public function getArrange():WidgetArrangeObject{
			return	arranges[WidgetArrangeManager.getResolution()] || arranges[WidgetArrangeObject.DEFAULT];
		}
		
		
		/**
		 * 해상도별 정렬 정보 저장하기 
		 * @param $o
		 * @param $resolution
		 * 
		 */		
		public function setArrange($o:WidgetArrangeObject, $resolution:String=WidgetArrangeObject.DEFAULT):void{
			arranges[$resolution] = $o;
		}
	}
}