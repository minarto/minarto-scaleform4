package com.minarto.manager.widget {
	import flash.display.DisplayObject;
	
	
	public class WidgetData {
		protected var arranges:* = {};	//	정렬 정보
		
		
		public var src:String, //	경로
		widgetID:String, //	위젯 아이디
		widget:DisplayObject, //	위젯 객체
		containerIndex:int;	//	컨테이너 인덱스
		
		
		/**
		 * 현재 해상도의 정렬 정보 가져오기 
		 * @return 
		 * 
		 */		
		public function getArrange($resolutionID:String):ArrangeData{
			return	arranges[$resolutionID];
		}
		
		
		/**
		 * 해상도별 정렬 정보 저장하기 
		 * @param $o
		 * @param $resolution
		 * 
		 */		
		public function setArrange($resolutionID:String, $o:ArrangeData):void{
			arranges[$resolutionID] = $o;
		}
	}
}