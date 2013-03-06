import com.minarto.controls.tooltip.*;
import com.minarto.manager.tooltip.IToolTipManager;
import gfx.core.UIComponent;
import gfx.events.EventTypes;


/**
 * ...
 * @author minarto
 */
class com.minarto.controls.tooltip.ToolTipContainerBase extends UIComponent implements IToolTipManager {
	private var target:MovieClip, btnDic:Array = [], delay:Number = 300, delayID:Number;
	
	public var toolTip:ToolTipBase, toolTip1:ToolTipBase;
		
		
	public function ToolTipContainerBase() {
		this.hitTestDisable = true;
		
		this._visible = false;
		toolTip._visible = false;
		toolTip1._visible = false;
	}
	
	
	public function regist($button:UIComponent):Void{
		for(var i in arguments){
			var b:UIComponent = arguments[i];
			b.addEventListener(EventTypes.ROLL_OVER, this, "hnRollOver");
			b.addEventListener(EventTypes.ROLL_OUT, this, "hnRollOut");
		}
		
		btnDic.push.apply(btnDic, arguments);
	}
	
	
	public function unRegist($button:UIComponent) : Void {
		if($button){
			for(var i in arguments){
				var b:UIComponent = arguments[i];
				b.removeEventListener(EventTypes.ROLL_OVER, this, "hnRollOver");
				b.removeEventListener(EventTypes.ROLL_OUT, this, "hnRollOut");
				
				btnDic.splice(i, 1);
			}
		}
		else{
			for(i in btnDic){
				b = btnDic[i];
				b.removeEventListener(EventTypes.ROLL_OVER, this, "hnRollOver");
				b.removeEventListener(EventTypes.ROLL_OUT, this, "hnRollOut");
			}
			
			btnDic.length = 0;
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
				
				t.setData($d);
				t._visible = true;
			}
			this._visible = true;
		}
		else{
			toolTip._visible = false;
			toolTip1._visible = false;
		}
	}
	
	
	public function delToolTip():Void{
		this._visible = false;
		clearTimeout(delayID);
	}
}