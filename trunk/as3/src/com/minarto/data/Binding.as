/**
 * 
 */
package com.minarto.data 
{
	import flash.utils.Dictionary;
	
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.core.UIComponent;
	
	
	public class Binding
	{
		static private const _BINDING_DIC:* = {};
		
		
		/**
		 * 바인딩 객체 반환 
		 * @param $id
		 * @return 
		 * 
		 */			
		static public function GET($id:*):Binding
		{
			var b:Binding = _BINDING_DIC[$id] || (_BINDING_DIC[$id] = new Binding);
			
			b.setID($id);
			
			return	b;
		}
		
		
		/**
		 * 바인딩 객체 삭제
		 */		
		static public function DEL($id:*):void
		{
			var b:Binding = _BINDING_DIC[$id];
			
			if(b)	b.del();
			
			delete	_BINDING_DIC[$id];
		}
		
		
		/**
		 * 값 설정
		 */	
		static public function SET_Values($id:*, $key:String, ...$values):void
		{
			var b:Binding = _BINDING_DIC[$id] || (_BINDING_DIC[$id] = new Binding);
			
			b.setID($id);
			
			$values.unshift($key);
			b.set.apply(null, $values);
		}
		
		
		static public function SET_ListItem($id:*, $key:String, $item:*, $index:int=-1, $valueIndex:uint=0):void
		{
			var b:Binding = _BINDING_DIC[$id] || (_BINDING_DIC[$id] = new Binding);
			
			b.setID($id);
			b.setListItem($key, $item, $index, $valueIndex);
		}
		
		
		static public function SET_ItemP($item:*, $p:String, $value:*):void
		{
			for each(var b:Binding in _BINDING_DIC)	b.setListItemProp($item, $p, $value);
		}
		
		
		private const _valueDic:* = {}, _itemDic:Dictionary = new Dictionary(true), _reservations:* = {};
		
		
		private var _handlerDic:* = {}, _compDic:* = {}, _id:*;
		
		
		/**
		 * 값 설정 
		 * @param $key		바인딩 키
		 * @param $value	바인딩 값 리스트
		 */
		public function set($key:String, ...$values):void
		{
			var a:Array = _reservations[$key], d:*, i:uint = $values.length, l:uint, v:*;
			
			while(i --)
			{
				v = $values[i];
				switch(typeof v)
				{
					case "string" :
					case "number" :
					case "boolean" :
						break;
					
					default :
						if(v as Array)
						{
							l = v.length;
							while(l--)	_itemDic[v[l]] = $key;
						}
						else	_itemDic[v] = $key;
				}
				
			}
			_valueDic[$key] = $values;
			
			for(d in _handlerDic[$key])
			{
				if(a)
				{
					for(l=a.push($values); i<l; ++i)
					{
						_set($key, a[i]);
					}
					delete	_reservations[$key];
				}
				else
				{
					_set($key, $values);
				}
				
				return;
			}
			
			if(!a)
			{
				_reservations[$key] = a = [];
			}
			a.push($values);
		}
		
		
		/**
		 * 값 설정 
		 * @param $key	바인딩 키
		 * @param $value	바인딩 값
		 */
		private function _set($key:String, $values:Array):void
		{
			var d:Dictionary = _handlerDic[$key], f:*;
			
			for(f in d)
			{
				f.apply(null, $values.concat(d[f]));
			}
			
			d = _compDic[$key];
			for(f in d)
			{
				f.invalidate(d[f]);
			}
		}
		
		
		/**
		 * 특정배열 값의 원소를 변경할 때
		 * @param $key
		 * @param $item
		 * @param $index
		 * @param $valueIndex
		 * 
		 */		
		public function setListItem($key:String, $item:*, $index:int=-1, $valueIndex:uint=0):void
		{
			var values:Array = _valueDic[$key] || [], arguments:Array = values[$valueIndex] as Array || (values[$valueIndex] = []);
			
			switch(typeof $item)
			{
				case "string" :
				case "number" :
				case "boolean" :
					break;
				default :
					_itemDic[$item] = $key;
			}
			
			arguments[($index < 0) ? arguments.length : $index] = $item;
			
			set.apply(null, values);
		}
		
		
		/**
		 * 값 객체의 속성만을 변경할 때
		 *  
		 * @param $item
		 * @param $p
		 * @param $value
		 * 
		 */		
		public function setListItemProp($item:*, $p:String, $value:*):void
		{
			var key:String;
			
			switch(typeof $item)
			{
				case "string" :
				case "number" :
				case "boolean" :
					return;
				default :
					if(key = _itemDic[$item])
					{
						arguments = _valueDic[key].concat();
						arguments.unshift(key);
						$item[$p] = $value;
						set.apply(null, arguments);
					}
			}
		}
		
		
		/**
		 * 바인딩 
		 * @param $key		바인딩 키
		 * @param $handler	바인딩 핸들러
		 */				
		public function add($key:String, $handler:Function, ...$args):void
		{
			var d:Dictionary = _handlerDic[$key] || (_handlerDic[$key] = new Dictionary(true));
			
			d[$handler] = $args;
		}
		
		
		/**
		 * 컴포넌트 바인딩 
		 * @param $key				바인딩 키
		 * @param $comp				바인딩 컴포넌트
		 * @param $invalidationType	UIComponent invalidationType
		 * 
		 */				
		public function addComp($key:String, $comp:UIComponent, $invalidationType:String=null):void
		{
			var d:Dictionary = _compDic[$key] || (_compDic[$key] = new Dictionary(true));
			
			d[$comp] = $invalidationType ? $invalidationType : "default";
		}
		
		
		/**
		 * 함수 바인딩 (값이 존재하면 바로 실행)
		 * @param $key		바인딩 키
		 * @param $handler	바인딩 핸들러 또는 CoreList
		 * @param $args		바인딩 추가 인자
		 */				
		public function addValuePlay($key:String, $handler:Function, ...$args):void
		{
			var dic:Dictionary = _handlerDic[$key] || (_handlerDic[$key] = new Dictionary(true)), values:Array;
			
			dic[$handler] = $args;
			
			if(values = _valueDic[$key])
			{
				values = values.concat($args);
				$handler.apply(null, values);
			}
		}
		
		
		/**
		 * 컴포넌트 바인딩  (값이 존재하면 바로 실행)
		 * @param $key				바인딩 키
		 * @param $comp				바인딩 컴포넌트
		 * @param $invalidationType	UIComponent invalidationType
		 * 
		 */					
		public function addCompValuePlay($key:String, $comp:UIComponent, $invalidationType:String=null):void
		{
			var dic:Dictionary = _compDic[$key] || (_compDic[$key] = new Dictionary(true));
			
			dic[$comp] = $invalidationType ? $invalidationType : "default";
			
			if(_valueDic[$key])	$comp.invalidate($invalidationType);
		}
		
		
		/**
		 * 바인딩 해제
		 * @param $key	바인딩 키
		 * @param $handler	바인딩 핸들러 또는 컴포넌트
		 * 
		 */			
		public function del($key:String=null, $handler:*=null):void 
		{
			var d:Dictionary, f:*;
			
			if($key)
			{
				if($handler)
				{
					d = _handlerDic[$key];
					if(d)
					{
						delete	d[$handler];
						
						$handler = null;
						for(f in d)
						{
							$handler = f;
							break;
						}
						if(!$handler)
						{
							delete	_handlerDic[$key];
						}
					}
					
					d = _compDic[$key];
					if(d)
					{
						delete	d[$handler];
						
						$handler = null;
						for(f in d)
						{
							$handler = f;
							break;
						}
						if(!$handler)
						{
							delete	_compDic[$key];
						}
					}
				}
				else
				{
					delete	_handlerDic[$key];
					delete	_compDic[$key];
				}
			}
			else
			{
				_handlerDic = {};
				_compDic = {};
			}
		}
		
		
		/**
		 * 바인딩의 id
		 */
		public function setID($id:*):void
		{
			if($id)	return;
			_id = $id;
		}
		public function getID():*
		{
			return	_id;
		}
		
		
		/**
		 * 값 리스트를 가져온다 
		 * @param $key	바인딩키
		 * @return 바인딩 값
		 * 
		 */
		public function getList($key:String):Array
		{
			return	_valueDic[$key];
		}
		
		
		/**
		 * 값 리스트의 첫번째 값을 가져온다 
		 * @param $key	바인딩키
		 * @return 바인딩 값
		 * 
		 */
		public function get($key:String):*
		{
			arguments = _valueDic[$key];
			
			return	arguments ? arguments[0] : arguments;
		}
	}
}