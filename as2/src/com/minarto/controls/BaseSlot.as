import com.minarto.data.ListBinding;
import com.minarto.manager.tooltip.ToolTipBinding;
import gfx.controls.*;
import com.minarto.controls.*;


class com.minarto.controls.BaseSlot extends ListItemRenderer {
	public var content:MovieClip;
	
	
	private function configUI():Void {
		super.configUI();
		
		content._x = 3;
		content._y = 3;
		
		textField.hitTestDisable = true;
		content.hitTestDisable = true;
			
		constraints.removeElement(textField);
		
		watch("data", onChangeData);
		
		ToolTipBinding.regist(this);
	}
	
	
	public function destroy():Void {
		delBind(data);
		unwatch("data");
	}
		
		
	private function onChangeData($p, $old, $new):Void {
		delBind($old);
		addBind($new);
	}
		
		
	private function delBind($data):Void {
		//ListBinding.delBind($data, this, "invalidate", "url");
	}
	
	
	private function addBind($data):Void {
		//ListBinding.addBind($data, this, "invalidate", "url");
	}
		
		
	private function onImageLoadComplete():Void {
		content._width = 64;
		content._height = 64;
	}
}