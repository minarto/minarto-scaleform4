package com.minarto.manager
{
	import com.minarto.data.Binding;
	
	import flash.display.*;
	import flash.external.ExternalInterface;
	import flash.system.System;
	import flash.utils.Dictionary;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class ContentManager 
	{
		static private const _CONTENT_DIC:* = {}, _UID_DIC:Dictionary = new Dictionary(true), _RESERVATIONS:Array = []
			, _SOURCE_DIC:* = {};
		
		
		static private var _CONTENT_UID:Number = 0, _CURRENT_LOAD_UID:Number;
		
		
		/**
		 * 소스 등록
		 */		
		static public function RESIST($contentID:String, $src:String, $gc:Boolean=true, $multi:Boolean=false):void
		{
			var sourceData:* = {src : $src, gc : $gc, multi : $multi};
			
			if(!$gc)	sourceData["pool"] = [];
			
			_SOURCE_DIC[$contentID] = sourceData;
		}
		
		
		/**
		 * 소스 삭제
		 */		
		static public function UNRESIST($contentID:String):void
		{
			delete	_SOURCE_DIC[$contentID];
		}
		
		
		/**
		 * 개별 리소스 로드 완료  
		 * @param $d
		 * 
		 */		
		static private function _OnComplete($d:DisplayObject, $uid:Number):void
		{
			var contentData:* = _CONTENT_DIC[$uid], contentID:String = contentData["contentID"], 
				handler:Function = contentData["handler"];
			
			contentData["content"] = $d;
			if($d)	_UID_DIC[$d] = $uid;
			
			if(handler)
			{
				arguments.push.apply(null, contentData["args"]);
				handler.apply(null, arguments);
				
				delete	contentData["handler"];
			}
			
			delete	contentData["loadID"];
			delete	contentData["args"];
			
			_ADD();
		}
		
		
		/**
		 * 컨텐츠 추가
		 */		
		static public function ADD($contentID:String, $handler:Function=null, ...$args):Number
		{
			var sourceData:* = _SOURCE_DIC[$contentID], uid:Number;
			
			if(!sourceData)	return	uid;
			
			uid = ++ _CONTENT_UID;
			
			_CONTENT_DIC[uid] = {
				contentID : $contentID
				, handler : $handler
				, args : $args
			};
			
			_RESERVATIONS.push(uid);
			
			if(isNaN(_CURRENT_LOAD_UID))	_ADD();
			
			return	uid;
		}
		
		
		/**
		 * 핸들러 삭제
		 */		
		static public function DEL_HANDLER($handler:Function):void
		{
			var index:int = _RESERVATIONS.length, obj:*;
			
			while(index --)
			{
				obj = _RESERVATIONS[index];
				if(isNaN(obj))
				{
					if(obj["handler"] == $handler)
					{
						_RESERVATIONS.splice(index, 1);
						break;
					}
				}
			}
			if(isNaN(_CURRENT_LOAD_UID))	_ADD();
		}
		
		
		/**
		 * 핸들러 추가
		 */		
		static public function ADD_HANDLER($handler:Function, ...$args):void
		{
			_RESERVATIONS.push({handler:$handler, args:$args});
			if(isNaN(_CURRENT_LOAD_UID))	_ADD();
		}
		
		
		/**
		 * 예약 명령 실행
		 */		
		static private function _ADD():void
		{
			var uid:*, contentData:*, sourceData:*, d:DisplayObject;
			
			if(uid = _RESERVATIONS.shift())
			{
				if(uid as Number)
				{
					_CURRENT_LOAD_UID = uid;
					
					contentData = _CONTENT_DIC[uid];
					sourceData = _SOURCE_DIC[contentData["contentID"]];
					
					arguments = sourceData["pool"];
					if(arguments && (d = arguments.pop()))	_OnComplete(d, uid);
					else	contentData["loadID"] = LoadManager.ADD("swf", sourceData["src"], _OnComplete, _OnComplete, uid);
				}
				else	//	로드완료 핸들러
				{
					_CURRENT_LOAD_UID = NaN;
					uid["handler"].apply(null, uid["args"]);
					_ADD();
				}
			}
			else	_CURRENT_LOAD_UID = NaN;
		}
		
		
		/**
		 * 컨텐츠 가져오기 
		 * @param $uid
		 * @return 
		 * 
		 */		
		static public function GET($uid:Number):DisplayObject
		{
			var contentData:* = _CONTENT_DIC[$uid];
			
			return	contentData ? contentData["content"] : contentData;
		}
		
		
		/**
		 * 컨텐츠의 id 값 가져오기 
		 * @param $uid
		 * @return 
		 * 
		 */		
		static public function GET_CONTENT_ID($uid:Number):String
		{
			var contentData:* = _CONTENT_DIC[$uid];
			
			return	contentData ? contentData["contentID"] : contentData;
		}
		
		
		/**
		 * 컨텐츠id로 컨텐츠 가져오기 
		 * @param $contentID
		 * @return 
		 * 
		 */		
		static public function GET_CONTENT_BY_ID($contentID:String):Vector.<DisplayObject>
		{
			var v:Vector.<DisplayObject> = new Vector.<DisplayObject>([]), uid:*, contentData:*, d:DisplayObject;
			
			for(uid in _CONTENT_DIC)
			{
				contentData = _CONTENT_DIC[uid];
				if(contentData["contentID"] == $contentID)
				{
					if(d = contentData["content"])	v.push(d);
				}
			}
			
			return	v;
		}
		
		
		/**
		 * 컨텐츠의 uid 가져오기 
		 * @param $d
		 * @return 
		 * 
		 */		
		static public function GET_CONTENT_UID($d:DisplayObject):Number
		{
			return	_UID_DIC[$d];
		}
		
		
		/**
		 * 리소스 pool 로 보내거나 삭제
		 * @param $d
		 * 
		 */		
		static public function DEL($d:DisplayObject):void
		{
			DEL_UID(_UID_DIC[$d]);
		}
		
		
		/**
		 * 리소스 pool 로 보내거나 삭제
		 * @param $uid
		 * 
		 */		
		static public function DEL_UID($uid:Number):void
		{
			var i:Number = _RESERVATIONS.length, contentData:*, d:DisplayObject, sourceData:*;
			
			//	예약 명령어 중 삭제
			while(i --)
			{
				if(_RESERVATIONS[i] == $uid)
				{
					delete	_CONTENT_DIC[$uid];
					_RESERVATIONS.splice(i, 1);
					return;
				}
			}
			
			//	로드 됐거나 진행중인 것 중 삭제
			if(contentData = _CONTENT_DIC[$uid])
			{
				delete	_CONTENT_DIC[$uid];
				
				if(d = contentData["content"])
				{
					delete	_UID_DIC[d];
					
					sourceData = _SOURCE_DIC[contentData["contentID"]];
					if(arguments = sourceData["pool"])	arguments.push(d);
				}
					//	로드 중인 것은 삭제하고 다음 예약 명령 실행
				else if(i = contentData["loadID"])
				{
					LoadManager.DEL(i);
					_ADD();
				}
			}
		}
	}
}