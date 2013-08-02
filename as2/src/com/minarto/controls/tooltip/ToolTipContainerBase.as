import com.minarto.controls.tooltip.*;
import com.minarto.manager.tooltip.IToolTipManager;
import gfx.core.UIComponent;
import gfx.events.EventTypes;


/**
 * ...
 * @author minarto
 */
class com.minarto.controls.tooltip.ToolTipContainerBase extends UIComponent implements IToolTipManager {
	private var target:MovieClip, btnDic = {}, delay:Number = 300, delayID:Number;
	
	public var toolTip:ToolTipBase, toolTip1:ToolTipBase;
		
		
	public function ToolTipContainerBase() {
		this.hitTestDisable = true;
		
		this._visible = false;
		toolTip._visible = false;
		toolTip1._visible = false;
	}
	
	
	public function regist($button:MovieClip):Void{
		for(var i in arguments){
			$button = arguments[i];
			$button.addEventListener(EventTypes.ROLL_OVER, this, "hnRollOver");
			$button.addEventListener(EventTypes.ROLL_OUT, this, "hnRollOut");
			btnDic[targetPath($button)] = $button;
		}
	}
	
	
	public function unRegist($button:MovieClip) : Void {
		if($button){
			for(var i in arguments){
				$button = arguments[i];
				$button.removeEventListener(EventTypes.ROLL_OVER, this, "hnRollOver");
				$button.removeEventListener(EventTypes.ROLL_OUT, this, "hnRollOut");
				
				delete	btnDic[targetPath($button)];
			}
		}
		else{
			for(i in btnDic){
				$button = btnDic[i];
				$button.removeEventListener(EventTypes.ROLL_OVER, this, "hnRollOver");
				$button.removeEventListener(EventTypes.ROLL_OUT, this, "hnRollOut");
			}
			
			btnDic = {};
		}
	}
	
	
	private function hnRollOver($e) : Void {
		delToolTip();
		target = $e.target;
		if(target && target["data"])	delayID = setTimeout(delayToolTip, delay);
	}
	
	
	private function hnRollOut($e) : Void {
		delToolTip();
	}
	
	
	private function delayToolTip():Void {
		if(target)	addToolTip(target["data"]);
	}
	
	
	public function addToolTip($d):Void{
		delToolTip();
		
		if ($d) {
			var c:Number = arguments.length;
			for(var i:Number = 0; i<c; ++ i){
				switch(i){
					case 1 :
						var t:ToolTipBase = toolTip1;
						break;
					default :
						t = toolTip;
				}
				
				t.setData(arguments[i]);
				t._visible = true;
			}
			_visible = true;
		}
		else{
			toolTip._visible = false;
			toolTip1._visible = false;
		}
	}
	
	
	public function delToolTip():Void{
		_visible = false;
		clearTimeout(delayID);
	}
}