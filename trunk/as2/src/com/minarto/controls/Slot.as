import com.minarto.manager.LoadManager;
import gfx.controls.ListItemRenderer;


class com.minarto.controls.Slot extends ListItemRenderer {
	/**
	 * stage resource
	 */
	public var content:MovieClip;
	
	
	private function configUI():Void {
		super.configUI();
		
		trackAsMenu = true;
		
		addEventListener("dragOver", this, "hnDragOver");
		addEventListener("dragOut", this, "hnDragOut");
	}
	
	
	public function setData($d):Void {
		//super.setData($d);
		
		data = $d;
		if ($d)	LoadManager.load(content, $d.src, hnComplete, this);
		else	LoadManager.clear(content);
	}
		
		
	private static function hnDragOver($e):Void {
	}
		
		
	private static function hnDragOut($e):Void {
	}
	
		
	private static function hnComplete($content:MovieClip):Void {
		$content._width = 64;
		$content._height = 64;
	}
}