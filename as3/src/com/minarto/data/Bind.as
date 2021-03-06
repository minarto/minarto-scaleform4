/**
 * 
 */
package com.minarto.data 
{
	import flash.utils.Dictionary;
	
	
	public class Bind 
	{
		protected const valueDic:* = {}, reservations:* = {};
		
		
		protected var handlerDic:* = {};
		
		
		/**
		 * 값 설정 
		 * @param $key	바인딩 키
		 * @param $values	바인딩 값
		 */
		public function set($key:String, ...$values):void
		{
			var dic:Dictionary = handlerDic[$key], fn:*, a:Array;
			
			valueDic[$key] = $values;
			
			for(fn in dic)
			{
				_set($key, $values);
				return;
			}
			
			a = reservations[$key] || (reservations[$key] = []);
			a.push($values);
		}
		
		
		/**
		 * 이벤트 발생
		 * @param $key	이벤트 키
		 * @param $value	이벤트 값
		 */
		public function evt($key:String, ...$values):void 
		{
			var dic:Dictionary = handlerDic[$key], fn:*, a:Array;
			
			for(fn in dic)
			{
				_set($key, $values);
				return;
			}
			
			a = reservations[$key] || (reservations[$key] = []);
			a.push($values);
		}
		
		
		/**
		 * 값 설정 
		 * @param $key	바인딩 키
		 * @param $value	바인딩 값
		 */
		protected function _set($key:String, $values:Array):void 
		{
			var dic:Dictionary = handlerDic[$key], fn:*;
			
			for(fn in dic)
			{
				fn.apply(null, $values.concat(dic[fn]));
			}
		}
		
		
		/**
		 * 바인딩 
		 * @param $key		바인딩 키
		 * @param $handler	바인딩 핸들러
		 */				
		public function add($key:String, $handler:Function, ...$args):void 
		{
			var dic:Dictionary = handlerDic[$key] || (handlerDic[$key] = new Dictionary(true));
			
			dic[$handler] = $args;
			
			delete	reservations[$key];
		}
		
		
		/**
		 * 바인딩 
		 * @param $key		바인딩 키
		 * @param $handler	바인딩 핸들러
		 * @param $args		바인딩 추가 인자
		 */				
		public function addPlay($key:String, $handler:Function, ...$args):void 
		{
			var values:Array = [$key, $handler];
			
			values.concat($args);
			add.apply(this, values);
			
			values = valueDic[$key];
			if(values)
			{
				$handler.apply(null, values.concat($args));
			}
		}
		
		
		/**
		 * 바인딩 해제
		 * @param $key	바인딩 키
		 * @param $handler	바인딩 핸들러
		 * 
		 */			
		public function del($key:String=null, $handler:Function=null):void 
		{
			var dic:Dictionary, fn:*;
			
			if($key)
			{
				if($handler)
				{
					if(dic = handlerDic[$key])
					{
						delete	dic[$handler];
						
						$handler = null;
						for(fn in dic)
						{
							$handler = fn;
							break;
						}
						if(!$handler)	delete	handlerDic[$key];
					}
				}
				else	delete	handlerDic[$key];
			}
			else if($handler)
			{
				for($key in handlerDic)
				{
					dic = handlerDic[$key];
					delete	dic[$handler];
				}
			}
			else	handlerDic = {};
		}
		
		
		/**
		 * 값을 가져온다 
		 * @param $key	바인딩키
		 * @return 바인딩 값
		 * 
		 */
		public function get($key:String):Array 
		{
			return	valueDic[$key];
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
			arguments = valueDic[$key];
			
			return	arguments ? arguments[$index] : undefined;
		}
	}
}
