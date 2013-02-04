import com.minarto.controls.tooltip.*;
import gfx.core.UIComponent;


/**
 * ...
 * @author minarto
 */
class com.minarto.controls.tooltip.ToolTipBase extends UIComponent {
	private var data;
		
		
	private function setTitle($s:String):Void {
		if (background)	background.title = $s;
	}
		
		
	public function setData($d:*) : Void {
		delBind();
		data = $d;
		addBind();
	}
	
	
	private function delBind():Void{
		if(data as String){
			dataConvert();
		}
		else if(data){
			//ListBinding.delDataBind(data, dataConvert, HashKeyManager.url);
		}
	}
	
	
	private function addBind():Void{
		if(data as String){
			dataConvert();
		}
		else if(data){
			//ListBinding.addDataBind(data, dataConvert, HashKeyManager.url);
		}
	}
		
		
	private function dataConvert():Void{
	}
	
	
	public function toString() : String {
		return "com.minarto.tooltip.ToolTipBase";
	}
}