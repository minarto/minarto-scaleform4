/**
 * 
 */
package com.minarto.data 
{
	import flash.utils.Dictionary;
	
	
	public class Binding 
	{
		private const _valueDic:* = {}, _reservations:* = {};
		
		
		private var _handlerDic:* = {}, _registerDic:* = {};
		
		
		/**
		 * 값 설정 
		 * @param $key	바인딩 키
		 * @param $value	바인딩 값
		 */
		public function set($key:String, ...$values):void
		{
			var a:Array = _reservations[$key], f:*, i:uint, l:uint;
			
			_valueDic[$key] = $values;
			
			for(f in _handlerDic[$key])
			{
				i = 1;
				break;
			}
			
			if(i)
			{
				if(a)
				{
					for(i=0, l=a.push($values); i<l; ++i)	_set($key, a[i]);
					delete	_reservations[$key];
				}
				else	_set($key, $values);
				
				return;
			}
			
			if(!a)	_reservations[$key] = a = [];
			a.push($values);
		}
		
		
		/**
		 * 값 설정 
		 * @param $key	바인딩 키
		 * @param $value	바인딩 값
		 */
		private function _set($key:String, $values:Array):void 
		{
			var dic:Dictionary = _handlerDic[$key], f:*;
			
			for(f in dic)	f.apply(null, $values.concat(dic[f]));
		}
		
		
		/**
		 * 이벤트 발생
		 * @param $key	이벤트 키
		 * @param $value	이벤트 값
		 */
		public function event($key:String, ...$values):void 
		{
			_set($key, $values);
		}
		
		
		/**
		 * 바인딩 
		 * @param $key		바인딩 키
		 * @param $handler	바인딩 핸들러
		 */				
		public function add($key:String, $handler:Function, ...$args):void 
		{
			var dic:Dictionary = _handlerDic[$key] || (_handlerDic[$key] = new Dictionary(true));
			
			dic[$handler] = $args;
		}
		
		
		/**
		 * 바인딩 
		 * @param $key		바인딩 키
		 * @param $handler	바인딩 핸들러
		 * @param $args		바인딩 추가 인자
		 */				
		public function addPlay($key:String, $handler:Function, ...$args):void 
		{
			var dic:Dictionary = _handlerDic[$key] || (_handlerDic[$key] = new Dictionary(true)), values:Array;
			
			dic[$handler] = $args;
			
			if(values = _valueDic[$key])
			{
				$args = $args.concat();
				$args.unshift.apply(null, values);
				$handler.apply(null, $args);
			}
		}
		
		
		/**
		 * 바인딩 해제
		 * @param $key	바인딩 키
		 * @param $handler	바인딩 핸들러
		 * 
		 */			
		public function del($key:String=null, $handler:*=null):void 
		{
			var dic:Dictionary, f:*;
			
			if($key)
			{
				if($handler)
				{
					if(dic = _handlerDic[$key])
					{
						delete	dic[$handler];
						
						$handler = null;
						for(f in dic)
						{
							$handler = f;
							break;
						}
						if(!$handler)	delete	_handlerDic[$key];
					}
				}
				else	delete	_handlerDic[$key];
			}
			else if($handler)
			{
				for($key in _handlerDic)
				{
					dic = _handlerDic[$key];
					delete	dic[$handler];
				}
			}
			else	_handlerDic = {};
		}
		
		
		/**
		 * 값을 가져온다 
		 * @param $key	바인딩키
		 * @return 바인딩 값
		 * 
		 */
		public function get($key:String):Array 
		{
			return	_valueDic[$key];
		}
		
		
		/**
		 * 값을 가져온다 
		 * @param $key		바인딩키
		 * @param $index	값 인덱스
		 * @return 바인딩 값
		 * 
		 */
		public function getAt($key:String, $index:uint=0):* 
		{
			arguments = _valueDic[$key];
			
			return	arguments ? arguments[$index] : undefined;
		}
	}
}
