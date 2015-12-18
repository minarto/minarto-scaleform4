import com.minarto.loader.*;
import it.sephiroth.XML2Object;


class com.minarto.loader.XMLLoader
{
	public function XMLLoader()
	{
		trace("don't create instance")
	}
	
	
	static private function _init():Void
	{
		var xml:XML = new XML, onLoad:Function, onLoadError:Function, reservation:Array = [], loadItems;
		
		onLoad = function( $success:Boolean )
		{
			var onFunc:Function = $success ? loadItems[1] : loadItems[2], args:Array;
			
			if (onFunc)
			{
				args = loadItems.slice(2);
				args[0] = XML2Object.deserialize( this );
				onFunc.apply(null, args);
			}
		}
	
		add = function($src:String):Void
		{
			reservation.push(arguments);
			if (loadItems)	return;
			_add();
		}
	
		_add = function():Void
		{
			loadItems = dic.shift();
		
			if (loadItems)
			{
				xml.ignoreWhite = true;
				xml.onLoad = onLoad;
				xml.load( loadItems[0] );
			}
			else
			{
				xml.load( "" );
			}
		}
		
		del = function($src:String):Void
		{
			var i:Number;
		
			if ($target)
			{
				i = reservation.length;
				while (i --)
				{
					arguments = reservation[i];
					if (arguments[0] == $src)
					{
						dic.splice(i, 1);
						break;
					}
				}
				
				if (loadItems && (loadItems[0] == $src))	_add();
			}
			else
			{
				reservation.length = 0;
				
				if (loadItems)	_add();
			}
		}
		
		delete	_init;
	}
	
	
	static public function add($src:String, $onComplete:Function, $onError:Function):Void
	{
		_init();
		add.apply(XMLLoader, arguments);
	}
	
	
	static public function del($src:String):Void
	{
		_init();
		del($src);
	}
}
