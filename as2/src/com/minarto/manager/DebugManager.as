import flash.external.ExternalInterface;


class com.minarto.manager.DebugManager {
	public static function error($type:String, $message:String):Void{
		if(ExternalInterface.available)	ExternalInterface.call("error", $type, $message);
		trace("error : " + $type + " : " + $message);
	}
}