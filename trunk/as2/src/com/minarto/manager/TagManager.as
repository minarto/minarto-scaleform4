class com.minarto.manager.TagManager {
	public static function init():Void {
		var dic = { };
		
		add = function($tag:String, $convert) {
			if (isNaN($convert)) {	//	is text
				if ($tag.indexOf("STR_ICON=", 0) > - 1) {
					arguments[0] = "img";
					arguments[3] = "<img src='" + $convert + "' align='baseline' vspace='-1'>";
				}
				else {
					arguments[0] = "txt";
				}
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
							
						case "txt":
							endIndex = startIndex + tag.length;
							label = arg[1];
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
		
		add("loadImgTag", 0xFFFFFF, "barunson.manager.TagManager.showLoadImgTag");
		add("AM", 0xFFFFFF, "barunson.manager.TagManager.showWayFindingTag");
		add("item", 0xFF0000);
		
		add("STR_ICON=SHIFT", "TAG_SHIFT");
		add("STR_ICON=ALT", "TAG_ALT");
		add("STR_ICON=CTRL", "TAG_CTRL");
		add("STR_ICON=MOUSE_LB", "TAG_MOUSE_LB");
		add("STR_ICON=MOUSE_RB", "TAG_MOUSE_RB");
		add("STR_ICON=GOLD", "TAG_GOLD");
		
		add("ROMAN_LEVEL=1", "Ⅰ");
		add("ROMAN_LEVEL=2", "Ⅱ");
		add("ROMAN_LEVEL=3", "Ⅲ");
		add("ROMAN_LEVEL=4", "Ⅳ");
		add("ROMAN_LEVEL=5", "Ⅴ");
		add("ROMAN_LEVEL=6", "Ⅵ");
		add("ROMAN_LEVEL=7", "Ⅶ");
		add("ROMAN_LEVEL=8", "Ⅷ");
		add("ROMAN_LEVEL=9", "Ⅸ");
		add("ROMAN_LEVEL=10", "Ⅹ");
		
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
	
	
	
	/**
	 * 태그정보를 클라로 디스패치
	 * 
	 * @param	tagName
	 */
	public static function showLoadImgTag(tagId:String):Void {
		ExternalInterface.call("showLoadImgTag", tagId);
	}
	public static function showWayFindingTag(tagId:String):Void {
		ExternalInterface.call("showWayFindingTag", tagId);
	}
}