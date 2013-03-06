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
		
		
	public function setData($d) : Void {
		if(data == $d)	return;
		delBind();
		data = $d;
		addBind();
	}
	
	
	private function delBind():Void{
		if(data && !(data as String)){
			//ListBinding.delDataBind(data, invalidate, HashKeyManager.url);
		}
	}
	
	
	private function addBind():Void{
		if(data as String){
			invalidate();
		}
		else if(data){
			//ListBinding.addDataBind(data, invalidate, HashKeyManager.url);
		}
	}
}