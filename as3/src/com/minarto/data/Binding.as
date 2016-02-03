/**
 * 
 */
package com.minarto.data 
{
	import flash.utils.Dictionary;
	
	
	public class Binding 
	{
		private const _valueDic:* = {}, _reservations:* = {};
		
		
		private var _handlerDic:* = {}, _getHandlerDic:* = {}, _gcHandlerDic:* = {};
		
		
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
			for(f in _gcHandlerDic[$key])
			{
				i = 1;
				break;
			}
			
			if(i)
			{
				if(a)
				{
					for(i=0, l=a.push($values); i<l; ++i)
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
		private function _set($key:*, $values:Array):void 
		{
			var dic:Dictionary = _handlerDic[$key], f:*;
			
			for(f in dic)
			{
				f.apply(null, $values.concat(dic[f]));
			}
			
			dic = _gcHandlerDic[$key];
			for(f in dic)
			{
				f.apply(null, $values.concat(dic[f]));
			}
			
			delete	_gcHandlerDic[$key];
		}
		
		
		/**
		 * 이벤트 발생
		 * @param $key	이벤트 키
		 * @param $value	이벤트 값
		 */
		public function event($key:*, ...$values):void 
		{
			_set($key, $values);
		}
		
		
		/**
		 * 바인딩 
		 * @param $key		바인딩 키
		 * @param $handler	바인딩 핸들러
		 */				
		public function add($key:*, $handler:Function, ...$args):void 
		{
			var dic:Dictionary = _handlerDic[$key] || (_handlerDic[$key] = new Dictionary(true));
			
			dic[$handler] = $args;
		}
		
		
		/**
		 * 바인딩 
		 * @param $key		바인딩 키
		 * @param $handler	바인딩 핸들러
		 */				
		public function addGetFn($key:*, $handler:Function):void 
		{
			var dic:Dictionary = _getHandlerDic[$key] || (_getHandlerDic[$key] = new Dictionary(true));
			
			dic[$handler] = true;
		}
		
		
		/**
		 * 바인딩 
		 * @param $key		바인딩 키
		 * @param $handler	바인딩 핸들러
		 * @param $args		바인딩 추가 인자
		 */				
		public function addPlay($key:*, $handler:Function, ...$args):void 
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
		 * 바인딩 후 바로 삭제
		 * @param $key		바인딩 키
		 * @param $handler	바인딩 핸들러
		 * @param $args		바인딩 추가 인자
		 */				
		public function addPlayGC($key:*, $handler:Function, ...$args):void 
		{
			var values:Array, dic:Dictionary;
			
			if(values = _valueDic[$key])
			{
				$args.unshift.apply(null, values);
				$handler.apply(null, $args);
			}
			else
			{
				dic = _gcHandlerDic[$key] || (_gcHandlerDic[$key] = new Dictionary(true));
				dic[$handler] = $args;
			}
		}
		
		
		/**
		 * 바인딩 해제
		 * @param $key	바인딩 키
		 * @param $handler	바인딩 핸들러
		 * 
		 */			
		public function del($key:*=null, $handler:*=null):void 
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
						if(!$handler)
						{
							delete	_handlerDic[$key];
						}
					}
					if(dic = _gcHandlerDic[$key])
					{
						delete	dic[$handler];
						
						$handler = null;
						for(f in dic)
						{
							$handler = f;
							break;
						}
						if(!$handler)
						{
							delete	_gcHandlerDic[$key];
						}
					}
				}
				else
				{
					delete	_handlerDic[$key];
					delete	_gcHandlerDic[$key];
				}
			}
			else if($handler)
			{
				for($key in _handlerDic)
				{
					dic = _handlerDic[$key];
					delete	dic[$handler];
				}
				
				for($key in _gcHandlerDic)
				{
					dic = _gcHandlerDic[$key];
					delete	dic[$handler];
				}
			}
			else
			{
				_handlerDic = {};
				_gcHandlerDic = {};
			}
		}
		
		
		/**
		 * 값을 가져온다 
		 * @param $key	바인딩키
		 * @return 바인딩 값
		 * 
		 */
		public function get($key:*):Array 
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
		public function getAt($key:*, $index:uint=0):* 
		{
			arguments = _valueDic[$key];
			
			return	arguments ? arguments[$index] : undefined;
		}
		
		
		/**
		 * 값을 가져온다 
		 * @param $key	바인딩키
		 * @return 바인딩 값
		 * 
		 */
		public function getFnResult($key:*, ...$args):* 
		{
			var dic:Dictionary = _getHandlerDic[$key], fn:*;
			
			for(fn in dic)
			{
				return	fn.apply(null, $args);
			}
			
			return	undefined;
		}
	}
}
