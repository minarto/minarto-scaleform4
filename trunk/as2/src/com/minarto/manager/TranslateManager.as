import com.minarto.manager.*;
import flash.external.ExternalInterface;

class com.minarto.manager.TranslateManager {
	private static var	_dic:* = { };
		
		
	public static function translate($msg:String):String{
		var r:String = _dic[$msg];
		if(!r){
			r = ExternalInterface.call("translate", $msg);
			
			if(!r){
				DebugManager.error("translate", $msg);
			}				
			
			_dic[$msg] = r;
		}
		return	r;	
	}
}