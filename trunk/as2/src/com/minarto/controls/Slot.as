import com.minarto.data.ListBinding;
import gfx.controls.*;


class com.minarto.controls.Slot extends ListItemRenderer {
	public var content:MovieClip, isDrag:Boolean = true, isUse:Boolean = true;
	
	
	private var tooltipEvt = { target:this };
	
	
	private function configUI():Void {
		super.configUI();
		
		content._x = 3;
		content._y = 3;
		
		textField.hitTestDisable = true;
		content.hitTestDisable = true;
			
		constraints.removeElement(textField);
		
		watch("data", onChangeData);
	}
	
	
	public function destroy():Void {
		delBind(data);
		unwatch("data");
	}
		
		
	private function onChangeData($p, $old, $new):Void {
		delBind($old);
		setBind($old);
	}
		
		
	private function delBind($data):Void {
		//ListBinding.delBind($data, this, "invalidate", "url");
	}
	
	
	private function setBind($p, $old, $new, $binds):Void {
		//ListBinding.addBind($data, this, "invalidate", "url");
	}
		
		
	public function toString() : String {
		return "com.minarto.controls.Slot";
	}
	
	private function draw():void {
		super.draw();
		
		if (data) {
			tooltipEvt.type = "tooltipRegister";
		}
		else {
			tooltipEvt.type = "tooltipUnregister";
		}
		
		_root.dispatchEvent(tooltipEvt);
	}
		
		
	private function onImageLoadComplete():Void {
		content.width = 64;
		content.height = 64;
	}
}