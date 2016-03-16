/**
 * 
 */
package com.minarto.data 
{
	public class BindDic
	{
		static private const _dic:* = {};
		
		
		static public function link($uid0:*, $uid1:*):void
		{
			var b:Bind = _dic[$uid0] || get($uid1);
			
			_dic[$uid0] = b;
			_dic[$uid1] = b;
		}
		
		
		/**
		 * 바인딩 객체 반환
		 */		
		static public function get($uid:*):Bind
		{
			return	_dic[$uid] || (_dic[$uid] = new Bind);
		}
		
		
		/**
		 * 값 설정
		 */	
		static public function set($uid:*, $key:String, ...$values):void
		{
			$values.unshift($key);
			get($uid).set.apply(null, $values);
		}
		
		
		/**
		 * 이벤트 발생
		 */	
		static public function evt($uid:*, $key:String, ...$values):void
		{
			$values.unshift($key);
			get($uid).evt.apply(null, $values);
		}
	}
}
