import com.minarto.controls.widget.*;
import gfx.controls.Button;
import gfx.core.UIComponent;
import gfx.events.EventTypes;
import gfx.utils.Constraints;


/**
 * ...
 * @author minarto
 */
class com.minarto.controls.widget.WidgetFrame extends UIComponent {
	public var	background:MovieClip, textField:TextField, closeBtn:Button;
				
				
	private var _title:String;		
		
		
	[Inspectable(defaultValue = "Title")]
	public function set title($v : String) : Void {
		if(_title == $v)	return;
		_title = $v;
		invalidate();
	}
	
	
	private function configUI():Void {
		constraints = new Constraints(this);
		
		if (background) {
			constraints.addElement(background, Constraints.ALL);
			
			var de = {type:EventTypes.DRAG_BEGIN, target:_parent};
			
			background.onPress = function():Void {
				_parent._parent.dispatchEvent(de);
			}
		}
		
		if (textField) {
			textField.hitTestDisable = true;
			textField._visible = false;
			
			constraints.addElement(textField, Constraints.LEFT | Constraints.RIGHT);
		}
		
		if (closeBtn) {
			var ce = {type:"closeWidget", target:_parent};
			
			hnClose = function():Void {
				_parent.dispatchEvent(ce);
			}
			closeBtn.addEventListener(EventTypes.CLICK, this, "hnClose");
			
			constraints.addElement(closeBtn, Constraints.RIGHT);
		}
		
	    constraints.update(__width, __height);
	}
	
	
	private var hnClose:Function;
}