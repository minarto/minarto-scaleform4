/**
 * 
 */
package com.minarto.data 
{
	public class BindDic
	{
		static private const _dic:* = {};
		
		
		static public function link($uid0:*, $uid1:*):Bind
		{
			var b:Bind = _dic[$uid0] || _dic[$uid1] || new Bind;
			
			_dic[$uid0] = b;
			_dic[$uid1] = b;
			
			return	b;
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
		static public function set($uid:*, ...$values):void
		{
			get($uid).set.apply(null, $values);
		}
		
		
		/**
		 * 이벤트 발생
		 */	
		static public function evt($uid:*, ...$values):void
		{
			get($uid).evt.apply(null, $values);
		}
	}
}
