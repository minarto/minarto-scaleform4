import com.minarto.controls.widget.Widget;
import com.minarto.manager.widget.*;


class com.minarto.manager.widget.LoadWidgetObject {
	public var src:String; //	경로
	public var widgetID:String; //	위젯 아이디
	public var widget:Widget; //	위젯 객체
	public var topArrange:Number;	//	컨테이너 인덱스
		
	public var parentWidgetID:String = "stage";	//	정렬시의 기준 위젯 아이디 
	public var xrate:Number = 0, yrate:Number = 0, align:String = "C"; //	기준 위젯으로부터의 정렬 위치
	public var xpadding:Number = 10, ypadding:Number = 10; //	정렬 위치로부터의 간격
	public var scaleEnable:Boolean = true;	//	스케일 적용을 받을지에 대한 여부 
}