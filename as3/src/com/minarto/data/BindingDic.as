/**
 * 
 */
package com.minarto.data 
{
	public class BindingDic
	{
		static private const _dic:* = {};
		
		
		/**
		 * 클라와 바인딩 매핑
		 */		
		static public function same($uid0:*, $uid1:*):Binding
		{
			var b:Binding = _dic[$uid0] || _dic[$uid1] || new Binding;
			
			_dic[$uid0] = b;
			_dic[$uid1] = b;
			
			return	b;
		}
		
		
		/**
		 * 바인딩 객체 반환
		 */		
		static public function get($uid:*):Binding
		{
			return	_dic[$uid] || (_dic[$uid] = new Binding);
		}
		
		
		/**
		 * 값 설정
		 */	
		static public function setValues($uid:*, $key:*, ...$values):void
		{
			var b:Binding = get($uid);
			
			$values.unshift($key);
			b.set.apply(null, $values);
		}
		
		
		/**
		 * 이벤트 발생
		 */	
		static public function event($uid:*, $key:*, ...$values):void
		{
			var b:Binding = get($uid);
			
			$values.unshift($key);
			b.event.apply(null, $values);
		}
	}
}