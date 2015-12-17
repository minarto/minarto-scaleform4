import com.minarto.data.Binding;
import flash.external.ExternalInterface;


class com.minarto.data.BindingDic
{
	static private var _dic = { };
	
	
	static public function get($id):Binding
	{
		var b:Binding = _dic[$id] || (_dic[$id] = new Binding );
		
		//ExternalInterface.call("Binding", $id, b);
		
		return	b;
	}
	
	
	static public function mapping($id0, $id1):Void
	{
		var b:Binding = _dic[$id0] || get($id1);
		
		_dic[$id0] = b;
		_dic[$id1] = b;
	}
	
		
	static public function set($id, $key:String, $value):Void
	{
		var b:Binding = get($id);
		
		b.set.apply(null, arguments.slice(1));
	}
		
	
	static public function del($id):Void
	{
		var b:Binding = _dic[$id];
		
		if (b)
		{
			b.del();
			
			delete	_dic[$id];
		}
	}
		
	
	static public function getID($b:Binding):Array
	{
		var a:Array = [], id;

		for (id in _dic)
		{
			if (_dic[id] == $b)
			{
				a.push(id);
			}
		}
		
		return	a;
	}
}
