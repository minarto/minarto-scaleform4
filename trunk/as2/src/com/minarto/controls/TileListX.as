import com.minarto.controls.*;
import gfx.controls.*;


class com.minarto.controls.TileListX extends TileList {
	private static function __onScrollWheel(delta:Number) {
		this.owner.scrollWheel(delta);
	}
	
	
	public function set rendererInstanceName(value:String):Void {
		if (!value) return;
		
		var i:Number = 0;
		var newRenderers:Array = [];
		var r:MovieClip = _parent[value + i];
		
		while (r) {
			setUpRenderer(r);
			Mouse.addListener(r);
			r.scrollWheel = __onScrollWheel;
			newRenderers.push(r);
			
			r = _parent[value + (++ i)];
		}
		
		if (newRenderers.length == 0) { newRenderers = null; }
		setRendererList(newRenderers);
	}
}