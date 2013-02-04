import com.minarto.manager.tooltip.*;
import flash.external.ExternalInterface;
import gfx.core.UIComponent;


class com.minarto.manager.tooltip.ToolTipBinding {
	private static var _manager:IToolTipManager, _reservations:Array = [];
		
		
	public static function init($manager:IToolTipManager):Void{
		_manager = $manager;
		if($manager)	$manager.regist.apply(null, _reservations);
		
		if(ExternalInterface.available)	ExternalInterface.call("ToolTipBinding", ToolTipBinding);
		trace("ToolTipBinding.init");
	}
	
	
	public function ToolTipBinding(){
		throw new Error("don't create instance");
	}
	
	
	public static function regist($button:UIComponent):Void{
		if(_manager){
			_manager.regist.apply(null, arguments);
		}
		else{
			_reservations.push.apply(null, arguments);
		}
	}
	
	
	public static function unRegist($button:UIComponent) : Void {
		if(_manager){
			_manager.unRegist.apply(null, arguments);
		}
		else{
			_reservations.length = 0;
		}
	}
	
	
	public static function addToolTip($d):Void{
		_manager.addToolTip($d);
	}
	
	
	public static function delToolTip():Void{
		_manager.delToolTip();
	}
}