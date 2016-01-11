import com.minarto.loader.*;


class com.minarto.loader.SLoader
{
  	public function SLoader()
	{
		trace("don't create instance")
	}
	
	
	static private function _init():Void
	{
		var dic:Array = [], loadItems, _add:Function, onLoadInit:Function, onLoadError:Function;
		
		onLoadInit = function ($mc:MovieClip):Void
		{
			var onComplete:Function = loadItems[2], args:Array;
		
			if (onComplete)
			{
				args = loadItems.slice(3);
				args[0] = $mc;
				
				onComplete.apply(null, args);
			}
			
			_add();
		}
		
		onLoadError = function ($mc:MovieClip, $errorCode:String, $httpStatus:Number):Void
		{
			var onError:Function = loadItems[3], args:Array;
		
			if (onError)
			{
				args = loadItems.slice(1);
				args[0] = $mc;
				args[1] = $errorCode;
				args[2] = $httpStatus;
				
				onError.apply(null, args);
			}
			
			_add();
		}
	
		add = function():Void
		{
			dic.push(arguments);
			if (loadItems)	return;
			_add();
		}
	
		_add = function():Void
		{
			loadItems = dic.shift();
		
			if (loadItems)
			{
				arguments = loadItems.concat();
				arguments.splice(2, 0, onLoadInit, onLoadError);
				MLoader.load.apply(MLoader, arguments);
			}
		}
		
		del = function($target:MovieClip):Void
		{
			var i:Number;
		
			if ($target)
			{
				i = dic.length;
				while (i --)
				{
					arguments = dic[i];
					if (arguments[0] == $target)
					{
						dic.splice(i, 1);
						break;
					}
				}
				
				if (loadItems && (loadItems[0] == $target))
				{
					MLoader.unLoad($target);
					_add();
				}
			}
			else
			{
				dic.length = 0;
				
				if (loadItems)
				{
					MLoader.unLoad(loadItems[0]);
					_add();
				}
			}
		}
		
		delete	_init;
	}
	
	
	static public function add($target:MovieClip, $src:String, $onComplete:Function, $onError:Function):Void
	{
		_init();
		add.apply(SLoader, arguments);
	}
	
	
	static public function del($target:MovieClip):Void
	{
		_init();
		del($target);
	}
}
