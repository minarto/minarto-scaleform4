/**
 * 
 */
package com.minarto.data {
	import flash.utils.Dictionary;
	
	import scaleform.clik.core.UIComponent;
	
	
	public class Binding {
		static private const _BINDING_DIC:* = {}, _ID_DIC:* = {};
		
		
		/**
		 * 클라와 바인딩 매핑
		 */		
		static public function SET($enum:Number, $classID:String):Binding{
			var b:Binding = _BINDING_DIC[$enum] || _BINDING_DIC[$classID] || new Binding;
			
			_ID_DIC[$enum] = $classID;
			_ID_DIC[$classID] = $enum;
			
			b.setEnum($enum);
			b.setClassID($classID);
			_BINDING_DIC[$enum] = b;
			_BINDING_DIC[$classID] = b;
			
			return	b;
		}
		
		
		/**
		 * 바인딩 객체 반환
		 */		
		static public function GET($id:*):Binding{
			var b:Binding = _BINDING_DIC[$id] || (_BINDING_DIC[$id] = new Binding);
			
			if(isNaN($id))	b.setClassID($id);
			else			b.setEnum($id);
			
			return	b;
		}
		
		
		/**
		 * 바인딩 객체 삭제
		 */		
		static public function DEL($id:*):void{
			var b:Binding = _BINDING_DIC[$id];
			
			if(b)	b.del();
			
			delete	_BINDING_DIC[$id];
		}
		
		
		/**
		 * $classID 에 연결된 enum 반환
		 */		
		static public function GET_Enum($classID:String):Number{
			return	_ID_DIC[$classID];
		}
		
		
		/**
		 * $enum 에 연결된 class id 반환
		 */		
		static public function GET_ClassID($enum:Number):String{
			return	_ID_DIC[$enum];
		}
		
		
		/**
		 * 값 설정
		 */	
		static public function SET_Values($enum:Number, $key:String, ...$values):void{
			var b:Binding = _BINDING_DIC[$enum] || (_BINDING_DIC[$enum] = new Binding);
			
			b.setEnum($enum);
			
			$values.unshift($key);
			b.set.apply(null, $values);
		}
		
		
		static public function SET_ListItem($enum:Number, $key:String, $item:*, $index:int=-1, $valueIndex:uint=0):void{
			var b:Binding = _BINDING_DIC[$enum] || (_BINDING_DIC[$enum] = new Binding);
			
			b.setEnum($enum);
			b.setListItem($key, $item, $index, $valueIndex);
		}
		
		
		static public function SET_ItemP($item:*, $p:String, $value:*):void{
			for each(var b:Binding in _BINDING_DIC)	b.setListItemProp($item, $p, $value);
		}
		
		
		private const _valueDic:* = {}, _itemDic:Dictionary = new Dictionary(true), _reservations:* = {};
		
		
		private var _handlerDic:* = {}, _enum:Number, _classID:String;
		
		
		/**
		 * 값 설정 
		 * @param $key	바인딩 키
		 * @param $value	바인딩 값
		 */
		public function set($key:String, ...$values):void {
			var a:Array = _reservations[$key], c:*, i:uint = $values.length, l:uint, v:*;
			
			while(i --){
				v = $values[i];
				switch(typeof v){
					case "string" :
					case "number" :
					case "boolean" :
						break;
					
					default :
						if(v as Array){
							l = v.length;
							while(l--)	_itemDic[v[l]] = $key;
						}
						else	_itemDic[v] = $key;
				}
				
			}
			_valueDic[$key] = $values;
			
			$values = $values.concat();
			$values.unshift($key);
			
			for(c in _handlerDic[$key]){
				if(a){
					for(l=a.push($values); i<l; ++i)	_set.apply(null, a[i]);
					delete	_reservations[$key];
				}
				else	_set.apply(null, $values);
				
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
		private function _set($key:String, ...$values):void {
			var d:Dictionary = _handlerDic[$key], c:*, v:*, u:UIComponent;
			
			for(c in d){
				v = d[c];
				if(u = c as UIComponent)	u.invalidate(v);
				else	c.apply(null, $values.concat(v));
			}
		}
		
		
		public function setListItem($key:String, $item:*, $index:int=-1, $valueIndex:uint=0):void{
			var values:Array = _valueDic[$key] || [], arguments:Array = values[$valueIndex] as Array || (values[$valueIndex] = []);
			
			switch(typeof $item){
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
		
		
		public function setListItemProp($item:*, $p:String, $value:*):void{
			var key:String;
			
			switch(typeof $item){
				case "string" :
				case "number" :
				case "boolean" :
					return;
				default :
					if(key = _itemDic[$item]){
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
		public function add($key:String, $handler:Function, ...$args):void {
			var d:Dictionary = _handlerDic[$key] || (_handlerDic[$key] = new Dictionary(true));
			
			d[$handler] = $args;
		}
		
		
		/**
		 * 바인딩 
		 * @param $key		바인딩 키
		 * @param $handler	바인딩 핸들러
		 */				
		public function addValuePlayUI($key:String, $uicomponent:UIComponent, $invalidationType:String):void {
			var d:Dictionary = _handlerDic[$key] || (_handlerDic[$key] = new Dictionary(true));
			
			d[$uicomponent] = $invalidationType;
		}
		
		
		/**
		 * 바인딩 
		 * @param $key		바인딩 키
		 * @param $handler	바인딩 핸들러 또는 CoreList
		 * @param $args		바인딩 추가 인자
		 */				
		public function addValuePlay($key:String, $handler:Function, ...$args):void {
			var d:Dictionary = _handlerDic[$key] || (_handlerDic[$key] = new Dictionary(true)), values:Array;
			
			d[$handler] = $args;
			
			if(values = _valueDic[$key]){
				$args = $args.concat();
				$args.unshift.apply(null, values);
				$handler.apply(null, $args);
			}
		}
		
		
		/**
		 * 바인딩 해제
		 * @param $key	바인딩 키
		 * @param $handler	바인딩 핸들러 또는 CoreList
		 * 
		 */			
		public function del($key:String=null, $handler:Function=null):void {
			var d:Dictionary, f:*;
			
			if($key){
				if($handler){
					d = _handlerDic[$key];
					if(d){
						delete	d[$handler];
						
						$handler = null;
						for(f in d){
							$handler = f;
							break;
						}
						if(!$handler)	delete	_handlerDic[$key];
					}
				}
				else	delete	_handlerDic[$key];
			}
			else	_handlerDic = {};
		}
		
		
		/**
		 * enum
		 */
		public function setEnum($enum:Number):void {
			if(_enum)	return;
			_enum = $enum;
		}
		public function getEnum():Number {
			return	_enum;
		}
		
		
		/**
		 * classID
		 */
		public function setClassID($classID:String):void {
			if(_classID)	return;
			_classID = $classID;
		}
		public function getClassID():String {
			return _classID;
		}
		
		
		/**
		 * 값을 가져온다 
		 * @param $key	바인딩키
		 * @return 바인딩 값
		 * 
		 */
		public function get($key:String):Array {
			return	_valueDic[$key];
		}
	}
}