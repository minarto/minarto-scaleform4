class com.minarto.loader.MLoader
{
	static private var _dic = {};
	
	
	public function MLoader()
	{
		throw	new Error("don't create instance")
	}
	
	
	static private function _init():Void
	{
		var loader:MovieClipLoader = new MovieClipLoader;
		
		loader.addListener(MLoader);
		
		load = function($target:MovieClip, $src:String, $onScope, $onComplete:Function, $onError:Function):Void
		{
			_dic[targetPath($target)] = arguments;
			loader.loadClip($src, $target);
		}
		
		unLoad = function($target:MovieClip):Void
		{
			loader.unloadClip($target);
			
			delete	_dic[targetPath($target)];
		}
		
		delete	_init;
	}
	
	
	static private function onLoadInit($mc:MovieClip):Void
	{
		var path:String = targetPath($mc), loadItems:Array = _dic[path], onComplete:Function = loadItems[3], args:Array;
		
		delete	_dic[path];
		
		if (onComplete)
		{
			args = loadItems.slice(4);
			args[0] = $mc;
			
			onComplete.apply(loadItems[2], args);
		}
	}
	
	
	static private function onLoadError($mc:MovieClip, $errorCode:String, $httpStatus:Number):Void
	{
		var path:String = targetPath($mc), loadItems:Array = _dic[path], onError:Function = loadItems[4], onScope, args:Array;
		
		delete	_dic[path];
		
		if (onError)
		{
			onScope = loadItems[2];
			args = loadItems.slice(2);
			args[0] = $mc;
			args[1] = $errorCode;
			args[2] = $httpStatus;
			
			onError.apply(onScope, args);
		}
	}
	
	
	static public function load($target:MovieClip, $src:String, $onScope, $onComplete:Function, $onError:Function):Void
	{
		_init();
		load.apply(MLoader, arguments);
	}
	
	
	static public function unLoad($target:MovieClip):Void
	{
		_init();
		unLoad.apply(MLoader, arguments);
	}
}
