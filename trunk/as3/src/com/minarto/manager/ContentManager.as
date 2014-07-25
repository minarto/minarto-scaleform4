package com.minarto.manager {
	import com.minarto.data.Binding;
	
	import flash.display.*;
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class ContentManager {
		static private const _CONTENT_DIC:* = {}, _UID_DIC:Dictionary = new Dictionary, _PAGES:Array = [], 
							_RECYCLE_DIC:* = {}, _RESERVATIONS:Array = [], _POOL:* = {}, _RESISTRATION:* = {};
		
		
		static private var _CONTENT_UID:Number = 0, _PAGE:*, _SOURCE:*, _PAGE_ID:String, _CURRENT_LOAD_UID:Number;
		
		
		/**
		 * 해당 컨텐츠 가져오기 
		 * @param $contentID
		 * @return 
		 * 
		 */			
		static public function INIT($widgetSource:*, $source:*, $page:*, $menuDic:*):void{
			_SOURCE = $source;
			_PAGE = $page;
		}
		
		
		/**
		 * uid 얻기
		 * @return 
		 * 
		 */			
		static private function _GET_NEW_UID():Number{
			return ++ _CONTENT_UID;
		}
		
		
		/**
		 * 컨텐츠 가져오기 
		 * @return 
		 * 
		 */			
		static public function GET_PAGE():Array{
			return _PAGES;
		}
		
		
		/**
		 * 개별 리소스 로드 완료  
		 * @param $d
		 * 
		 */		
		static private function _OnContentComplete($d:DisplayObject, $uid:Number):void{
			var contentData:* = _CONTENT_DIC[$uid], contentID:String = contentData["contentID"], handler:Function;
			
			contentData["content"] = $d;
			_UID_DIC[$d] = $uid;
			
			if(handler = contentData["handler"]){
				arguments.push.apply(null, contentData["args"]);
				handler.apply(null, arguments);
				
				delete	contentData["handler"];
			}
			
			delete	contentData["loadID"];
			delete	contentData["args"];
			
			_ADD();
		}
		
		
		/**
		 * 페이지 셋
		 */		
		static public function SET_PAGE($pageID:String, $onComplete:Function, ...$args):void{
			var i:uint, uid:Number, contentData:*, d:DisplayObject, contentID:String, a:Array, l:uint, layOutData:*;
			
			if(_PAGE_ID == $pageID)	return;
			
			_PAGE_ID = $pageID;
			
			//	기존 예약된 페이지 명령 삭제
			i = _RESERVATIONS.length;
			while(i --){
				contentData = _RESERVATIONS[i];
				if(contentData["type"] == "page"){
					_RESERVATIONS.splice(i, 1);
				}
			}
			
			
			//	현재 로드중인 페이지 컨텐츠 삭제
			if(contentData = _CONTENT_DIC[_CONTENT_UID]){
				if(contentData["type"] == "page")	LoadManager.DEL(contentData["loadID"]);
			}
			
			//	컨텐츠 추가
			if(a = _PAGE[$pageID]){
				for(i=0, l = a.length; i<l; ++ i){
					uid = _GET_NEW_UID();
					
					layOutData = a[i];
					
					contentData = {type:"page"};
					contentData["contentID"] = layOutData["id"];
					contentData["layOut"] = layOutData;
					
					_CONTENT_DIC[uid] = contentData;
					
					
					_PAGES.push(uid);
				}
			}
			
			_RESERVATIONS.push({handler:$onComplete, args:$args});
			
			if(isNaN(_CURRENT_LOAD_UID))	_ADD();
		}
		
		
		/**
		 * 예약 명령 실행
		 */		
		static private function _ADD():void{
			var uid:*, contentData:*, layOutData:*, contentID:String, d:DisplayObject, source:*, handler:Function;
			
			if(uid = _RESERVATIONS.shift()){
				if(uid as Number){
					_CURRENT_LOAD_UID = uid;
					
					contentData = _CONTENT_DIC[uid];
					contentID = contentData["contentID"];
					
					if(contentData["type"] == "page"){	//	페이지 컨텐츠 추가
						arguments = _RECYCLE_DIC[contentID] || (_RECYCLE_DIC[contentID] = []);
						if(d = arguments.pop())	_OnContentComplete(d, uid);
						else if(source = _SOURCE[contentID])	contentData["loadID"] = LoadManager.ADD("swf", source["src"], _OnContentComplete, _OnContentComplete, uid);
						else	_ADD();
					}
					else{	//	시스템 컨텐츠 추가
						if(source = _SOURCE[contentID]){
							arguments = _POOL[contentID] || (_POOL[contentID] = []);
							if(d = arguments.pop())	_OnContentComplete(d, uid);
							else if(source = _SOURCE[contentID])	contentData["loadID"] = LoadManager.ADD("swf", source["src"], _OnContentComplete, _OnContentComplete, uid);
							else	_ADD();
						}
						else{
							if(contentData = _RESISTRATION[contentID]){
								_OnContentComplete(contentData["content"], uid);
							}
							else	_ADD();
						}
					}
				}
				else{
					_CURRENT_LOAD_UID = NaN;
					
					handler = uid["handler"];
					handler.apply(null, uid["args"]);
				}
			}
			else	_CURRENT_LOAD_UID = NaN;
		}
		
		
		static public function GET($uid:Number):DisplayObject{
			var contentData:* = _CONTENT_DIC[$uid];
			
			return	contentData ? contentData["content"] : contentData;
		}
		
		
		static public function GET_CONTENT_ID($d:DisplayObject):String{
			var uid:Number = _UID_DIC[$d], contentData:* = _CONTENT_DIC[uid];
			
			return	contentData ? contentData["contentID"] : contentData;
		}
		
		
		static public function GET_CONTENT_UID($d:DisplayObject):Number{
			return	_UID_DIC[$d];
		}
		
		
		static public function GET_TYPE($uid:Number):String{
			var contentData:* = _CONTENT_DIC[$uid];
			
			return	contentData ? contentData["type"] : contentData;
		}
		
		
		static public function GET_LAYOUT($uid:Number):*{
			var contentData:* = _CONTENT_DIC[$uid];
			
			return	contentData ? contentData["layOut"] : contentData;
		}
		
		
		/**
		 * 기존 불러진 페이지 요소 pool 로 보냄 
		 * 
		 */		
		static public function DEL_PAGE():void{
			var uid:*, contentData:*, d:DisplayObject, contentID:String;
			
			for(uid in _CONTENT_DIC){
				contentData = _CONTENT_DIC[uid];
				
				if(contentData["type"] == "page"){
					delete	_CONTENT_DIC[uid];
					if(d = contentData["content"])	delete	_UID_DIC[d];
					
					if(arguments = _RECYCLE_DIC[contentData["contentID"]])	arguments.push(d);
				}
			}
			
			for(contentID in _RESISTRATION){
				contentData = _RESISTRATION[contentID];
				DEL(contentData["content"]);
				delete	_RESISTRATION[contentID];
			}
			
			_PAGES.length = 0;
		}
		
		
		/**
		 * 사용되는 리소스 pool 로 보냄
		 * @param $d
		 * 
		 */		
		static public function DEL($d:DisplayObject):void{
			var uid:Number = _UID_DIC[$d], contentData:* = _CONTENT_DIC[uid], contentID:String;
			
			if(contentData){
				contentID = contentData["contentID"];
				
				delete	_UID_DIC[$d];
				delete	_CONTENT_DIC[uid];
				
				if(arguments = (contentData["type"] == "page") ? _RECYCLE_DIC[contentID] : _POOL[contentID])	arguments.push($d);
				
				for(contentData in _PAGES){
					if(_PAGES[contentData] == uid){
						_PAGES.splice(contentData, 1);
						return;
					}
				}
			}
		}
		
		
		/**
		 * 사용되는 리소스 pool 로 보냄 
		 * @param $uid
		 * 
		 */		
		static public function DEL_UID($uid:Number):void{
			var contentData:* = _CONTENT_DIC[$uid], contentID:String, d:DisplayObject;
			
			if(contentData){
				contentID = contentData["contentID"];
				
				if(d = contentData["content"]){
					delete	_UID_DIC[d];
					
					if(arguments = (contentData["type"] == "page") ? _RECYCLE_DIC[contentID] : _POOL[contentID])	arguments.push(d);
				}
				
				delete	_CONTENT_DIC[$uid];
				
				for(contentData in _PAGES){
					if(_PAGES[contentData] == $uid){
						_PAGES.splice(contentData, 1);
						return;
					}
				}
			}
		}
		
		
		/**
		 * 사용하지 않는 컨텐츠 가져오기
		 */
		static public function GET_RECYCLE():Array{
			var r:Array = [];
			
			for each(arguments in _RECYCLE_DIC){
				r.push.apply(null, arguments);
			}
			
			return	r;
		}
		
		
		/**
		 * 컨텐츠 완전 삭제
		 */
		static public function DESTROY():void{
			var contentID:String, d:DisplayObject, p:DisplayObjectContainer;
			
			for(contentID in _RECYCLE_DIC){
				arguments = _RECYCLE_DIC[contentID];
				for each(d in arguments){
					if(p = d.parent)	p.removeChild(d);
				}
				arguments.length = 0;
				
				delete	_RECYCLE_DIC[contentID];
			}
		}
		
		
		/**
		 * 시스템 컨텐츠 추가
		 */		
		static public function ADD_SHOW($contentID:String, $handler:Function, ...$args):Number{
			var contentData:* = _SOURCE[$contentID], uid:Number;
			
			if(contentData){
				contentData = {};
				contentData["type"] = "system";
				contentData["contentID"] = $contentID;
				contentData["layOut"] = _SOURCE[$contentID];
			}
			else	contentData = _RESISTRATION[$contentID];
			
			if(contentData){
				uid = _GET_NEW_UID();
				
				contentData["handler"] = $handler;
				contentData["args"] = $args;
				
				_CONTENT_DIC[uid] = contentData;
				
				_RESERVATIONS.push(uid);
			}
			
			if(isNaN(_CURRENT_LOAD_UID))	_ADD();
			
			return	uid;
		}
		
		
		/**
		 * 시스템 컨텐츠 삭제
		 */		
		static public function DEL_SHOW($contentID:String):void{
			var uid:* = _CONTENT_UID, contentData:*;
			
			while(uid --){
				contentData = _CONTENT_DIC[uid];
				if(contentData && contentData["contentID"] == $contentID && contentData["type"] == "system"){
					DEL_UID(uid);
				}
			}
		}
		
		
		/**
		 * 임시 시스템 컨텐츠 등록
		 */		
		static public function RESIST_SHOW($contentID:String, $d:DisplayObject, $layOutData:*=null):void{
			var p:DisplayObjectContainer = $d.parent, contentData:* = {};
			
			if(p)	p.removeChild($d);
			
			contentData["type"] = "system";
			contentData["contentID"] = $contentID;
			contentData["layOut"] = $layOutData;
			contentData["content"] = $d;
			
			_RESISTRATION[$contentID] = contentData;
		}
	}
}