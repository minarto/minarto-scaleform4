class com.minarto.manager.TagManager {
	public static function init():Void {
		var dic = { };
		
		add = function($tag:String, $convert) {
			if (isNaN($convert)) {	//	is text
				arguments[0] = "img";
				arguments[3] = "<img src='" + $convert + "' align='baseline' vspace='-1'>";
				dic["{" + $tag + "}"] = arguments;
			}
			else {	//	is color
				arguments[0] = arguments[2] ? "callback" : "color";
				arguments[3] = "<font color='#" + $convert.toString(16) + "'><b><u>";
				dic["{" + $tag] = arguments;
			}
		}
		
		del = function($tag:String) {
			delete	dic["{" + $tag];
		}
		
		parse = function($msg:String):String {
			var startIndex:Number = 0, endIndex:Number = 0, tag:String, arg:Array, callback, colorPrefix:String, param:String, label:String;
			
			for (tag in dic) {
				startIndex = $msg.indexOf(tag, 0);
				if (startIndex > - 1) {
					arg = dic[tag];
					
					switch(arg[0]) {
						case "img":
							endIndex = startIndex + tag.length;
							label = arg[3];
							$msg = $msg.substring(0, startIndex) + label + $msg.substring(endIndex + 1);
							break;
							
						case "color":
							endIndex = $msg.indexOf("=", startIndex) + 1;
							colorPrefix = arg[3];
							label = "[ " + $msg.substring(endIndex, $msg.indexOf("}", startIndex)) + " ]";
							endIndex = $msg.indexOf("}", startIndex);
							$msg = $msg.substring(0, startIndex) + colorPrefix + label + "</u></b></font>" + $msg.substring(endIndex + 1);
							break;
							
						case "callback":
							endIndex = $msg.indexOf("=", startIndex) + 1;
							colorPrefix = arg[3];
							callback = arg[2];
							param = $msg.substring(endIndex, $msg.indexOf(",", endIndex));
							endIndex = $msg.indexOf("}", startIndex);
							label = "[ " + $msg.substring($msg.indexOf(",", startIndex) + 1, endIndex) + " ]";
							$msg = $msg.substring(0, startIndex) + "<a href=\"asfunction:" + callback + "," + param + "\">" + colorPrefix + label + "</u></b></font></a>" + $msg.substring(endIndex + 1);
							break;
					}
					
					
					return	parse($msg);
				}
			}		
			
			return	$msg;
		}
		
		delete	init;
	}
	
	
	public static function add($tag:String, $convert, $callback:String):Void {
		init();
		add($tag, $convert, $callback);
	}
	
	
	public static function del($tag:String):Void {
		init();
		del($tag);
	}
	
	
	public static function parse($msg:String):String {
		init();
		return	parse($msg);
	}
}