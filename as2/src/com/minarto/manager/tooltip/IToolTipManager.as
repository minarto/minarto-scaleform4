import com.minarto.manager.tooltip.*;
import gfx.core.UIComponent;


interface com.minarto.manager.tooltip.IToolTipManager {
	function regist($button:UIComponent):Void;
	function unRegist($button:UIComponent):Void;
	
	function addToolTip($d):Void;
	function delToolTip():Void;
}