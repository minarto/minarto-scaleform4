class com.minarto.loader.MLoader
{
	public function MLoader()
	{
		trace("don't create instance")
	}
	
	
	static private function _init():Void
	{
		var loader:MovieClipLoader = new MovieClipLoader, dic = {}, f = arguments.callee;
		
		loader.addListener(f);
		
		f.onLoadInit = function ($mc:MovieClip):Void
		{
			var path:String = targetPath($mc), loadItems:Array = dic[path], onComplete:Function = loadItems[2], args:Array;
			
			delete	dic[path];
			
			if (onComplete)
			{
				args = loadItems.slice(3);
				args[0] = $mc;
				
				onComplete.apply(null, args);
			}
		}
		
		f.onLoadError = function ($mc:MovieClip, $errorCode:String, $httpStatus:Number):Void
		{
			var path:String = targetPath($mc), loadItems:Array = dic[path], onError:Function = loadItems[3], args:Array;
			
			delete	dic[path];
			
			if (onError)
			{
				args = loadItems.slice(1);
				args[0] = $mc;
				args[1] = $errorCode;
				args[2] = $httpStatus;
				
				onError.apply(null, args);
			}
		}
	
		load = function($target:MovieClip, $src:String, $onComplete:Function, $onError:Function):Void
		{
			dic[targetPath($target)] = arguments;
			loader.loadClip($src, $target);
		}
		
		unLoad = function($target:MovieClip):Void
		{
			loader.unloadClip($target);
			
			delete	dic[targetPath($target)];
		}
		
		delete	_init;
	}
	
	
	static public function load($target:MovieClip, $src:String, $onComplete:Function, $onError:Function):Void
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
