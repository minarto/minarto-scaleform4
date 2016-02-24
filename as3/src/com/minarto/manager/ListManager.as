package com.minarto.manager 
{
	import com.minarto.data.Bind;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.Dictionary;
	
	import scaleform.clik.controls.*;
	import scaleform.clik.core.CLIK;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.managers.PopUpManager;
	import scaleform.gfx.*;

	
	/**
	 * @author minarto
	 */
	public class ListManager
	{
		static private const _listDic:Dictionary = new Dictionary(true), _bDrag:Bind = new Bind, _bOver:Bind = new Bind
			, _bOut:Bind = new Bind, _bCancel:Bind = new Bind, _bMove:Bind = new Bind, _bDrop:Bind = new Bind;
		
		
		static private var _fromListEvt:ListEvent, _dragContainer:DisplayObjectContainer, _offsetX:Number, _offsetY:Number
		, _dragTarget:DisplayObject, _fromListEvtData:*, _fromX:Number, _fromY:Number, _isDrag:Boolean;
		
		
		/**
		 * 리스트 매니저 초기화 
		 * @param $stage
		 * @param $container
		 * 
		 */		
		static public function init():void
		{
			var container:DisplayObjectContainer, stage:Stage = CLIK.stage;
			
			PopUpManager.init(stage);
			
			container = stage.getChildAt(stage.numChildren - 1) as DisplayObjectContainer;
			
			InteractiveObjectEx.setHitTestDisable(container, true);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, _startDown);
			stage.addEventListener(MouseEvent.CLICK, _startUp);
		}
		
		
		/**
		 * 리스트 매니저 초기화 
		 * @param $stage
		 * @param $container
		 * 
		 */		
		static public function setDragtarget($d:DisplayObject):void
		{
			if(_dragTarget == $d)	return;
			
			if(_dragContainer)
			{
				while(_dragContainer.numChildren)
				{
					_dragContainer.removeChildAt(0);
				}
			}

			_dragTarget = $d;
			
			if(_dragContainer && $d)
			{
				_dragContainer.addChild($d);
			}
		}
		
		
		/**
		 * 리스트 등록
		 * 
		 * @param $list
		 * @param $drag
		 * @param $drop
		 * 
		 */			
		static public function addList($dragID:*, $list:CoreList, $drag:Boolean=true, $drop:Boolean=true, $dragType:String="down&down"):void
		{
			var listData:*, obj:*;
			
			if(!$drag && !$drop)	return;
			
			listData = _listDic[$list] || (_listDic[$list] = {});
			
			obj = listData[$dragID] || (listData[$dragID] = {});
			obj["__dragType__"]	= $dragType;
			obj["__drag__"] = $drag;
			obj["__drop__"] = $drop;
		}
		
		
		/**
		 * 드래그 핸들러 등록 
		 * @param $dragID
		 * @param $handler
		 * @param $args
		 * 
		 */		
		static public function addDrag($dragID:String, $handler:Function, ...$args):void
		{
			$args.unshift($dragID, $handler);
			_bDrag.add.apply(null, $args);
		}
		
		
		/**
		 * 드래그 오버 핸들러 등록 
		 * @param $dragID
		 * @param $handler
		 * @param $args
		 * 
		 */		
		static public function addOver($dragID:String, $handler:Function, ...$args):void
		{
			$args.unshift($dragID, $handler);
			_bOver.add.apply(null, $args);
		}
		
		
		/**
		 * 드래그 오버 핸들러 등록 
		 * @param $dragID
		 * @param $handler
		 * @param $args
		 * 
		 */		
		static public function addOut($dragID:String, $handler:Function, ...$args):void
		{
			$args.unshift($dragID, $handler);
			_bOut.add.apply(null, $args);
		}
		
		
		/**
		 * 무브 핸들러 등록 
		 * @param $dragID
		 * @param $handler
		 * @param $args
		 * 
		 */		
		static public function addMove($dragID:*, $handler:Function, ...$args):void
		{
			$args.unshift($dragID, $handler);
			_bMove.add.apply(null, $args);
		}
		
		
		/**
		 * 드롭 핸들러 등록 
		 * @param $dragID
		 * @param $handler
		 * @param $args
		 * 
		 */		
		static public function addDrop($dragID:*, $handler:Function, ...$args):void
		{
			$args.unshift($dragID, $handler);
			_bDrop.add.apply(null, $args);
		}
		
		
		/**
		 * 캔슬 핸들러 등록 
		 * @param $dragID
		 * @param $handler
		 * @param $args
		 * 
		 */		
		static public function addCancel($dragID:*, $handler:Function, ...$args):void
		{
			$args.unshift($dragID, $handler);
			_bCancel.add.apply(null, $args);
		}
		
		
		/**
		 * 핸들러 삭제 
		 * @param $handler
		 * @param $dragID
		 * 
		 */			
		static public function del($dragID:*=null, $handler:Function = null):void
		{
			_bDrag.del($dragID, $handler);
			_bMove.del($dragID, $handler);
			_bOver.del($dragID, $handler);
			_bOut.del($dragID, $handler);			
			_bDrop.del($dragID, $handler);
			_bCancel.del($dragID, $handler);
		}
		
		
		/**
		 * 리스트 아이디 삭제
		 * 
		 * @param $dragID
		 * 
		 */			
		static private function _hasListenerCheckList($list:CoreList):void
		{
			var listData:* = _listDic[$list], dragID:String, obj:*, isOk:Boolean;
			
			for(dragID in listData)
			{
				obj = listData[dragID];
				if(obj["__drag__"] || obj["__drop__"])
				{
					isOk = true;
					break;
				}
			}
			
			if(!isOk)	delete	_listDic[$list];
		}
		
		
		/**
		 * 리스트 해제  
		 * @param $list
		 * @param $dragID
		 * 
		 */			
		static public function delList($dragID:*=null, $list:CoreList=null):void
		{
			var listData:*, list:*, i:int;
			
			listData = _listDic[$list];
			
			if($list)
			{
				if($dragID)
				{
					if(listData)
					{
						delete	listData[$dragID];
					}
					
					_hasListenerCheckList($list);
				}
				else
				{
					delete	_listDic[$list];
				}
			}
			else if($dragID)
			{
				arguments.length = 0;
				
				for(list in _listDic)
				{
					listData = _listDic[list];
					delete	listData[$dragID];
					
					i = arguments.push(list);
				}
				
				while(i --)
				{
					_hasListenerCheckList(arguments[i]);
				}
			}
		}
		
		
		/**
		 * 리스트 다운 핸들러 
		 * @param $e
		 * 
		 */		
		static private function _startDown($e:MouseEventEx):void
		{
			var fromR:ListItemRenderer = $e.target as ListItemRenderer, list:CoreList, dragID:String, obj:*, stage:Stage;
			
			if(!fromR || !fromR.data)	return;
			
			list = fromR.owner as CoreList;
			_fromListEvtData = _listDic[fromR.owner as CoreList];
			if(!_fromListEvtData)	return;
			
			_fromListEvt = new ListEvent(ListEvent.ITEM_PRESS, false, true, fromR.index, - 1, - 1, fromR, fromR.data, $e.mouseIdx, $e.buttonIdx);
			
			//	드래그 실행 여부
			for(dragID in _fromListEvtData)
			{
				obj = _fromListEvtData[dragID];
				if(obj["__drag__"])
				{
					stage = CLIK.stage;
					
					_fromX = stage.mouseX;
					_fromY = stage.mouseY;
					
					stage.addEventListener(Event.ENTER_FRAME, _move);
					stage.addEventListener(MouseEvent.MOUSE_UP, _drop);
					
					return;
				}
			}
		}
		
		
		/**
		 * 리스트 클릭 핸들러 
		 * @param $e
		 * 
		 */		
		static private function _startUp($e:MouseEventEx):void
		{
			var fromR:ListItemRenderer = $e.target as ListItemRenderer, list:CoreList, dragID:String, obj:*, stage:Stage;
			
			cancel();
			if(!fromR || !fromR.data)	return;
			
			list = fromR.owner as CoreList;
			_fromListEvtData = _listDic[fromR.owner as CoreList];
			if(!_fromListEvtData)	return;
			
			_fromListEvt = new ListEvent(ListEvent.ITEM_PRESS, false, true, fromR.index, - 1, - 1, fromR, fromR.data, $e.mouseIdx, $e.buttonIdx);
			
			//	드래그 실행 여부
			for(dragID in _fromListEvtData)
			{
				obj = _fromListEvtData[dragID];
				if(obj["__drag__"])
				{
					stage = CLIK.stage;
					
					_fromX = stage.mouseX;
					_fromY = stage.mouseY;
					
					stage.addEventListener(Event.ENTER_FRAME, _move);
					stage.addEventListener(MouseEvent.MOUSE_UP, _drop);
					
					return;
				}
			}
		}
		
		
		static private function _move($e:Event):void 
		{
			var dragID:String, obj:*, stage:Stage, fromR:ListItemRenderer;
			
			if(_isDrag)
			{
				if(_dragContainer && _dragTarget)
				{
					_dragTarget.x = _dragContainer.mouseX - _offsetX;
					_dragTarget.y = _dragContainer.mouseY - _offsetY;
				}
				
				for(dragID in _fromListEvtData)
				{
					obj = _fromListEvtData[dragID];
					if(obj["__drag__"])	_bMove.evt(dragID, _fromListEvt);
				}
			}
			else
			{
				stage = CLIK.stage;
				
				fromR = _fromListEvt.itemRenderer as ListItemRenderer;
				
				if(Math.abs(_fromX - stage.mouseX) > 5 || Math.abs(_fromY - stage.mouseY) > 5)
				{
					_isDrag = true;
					
					fromR = _fromListEvt.itemRenderer as ListItemRenderer;
					
					//	드래그 핸들러 실행
					for(dragID in _fromListEvtData)
					{
						obj = _fromListEvtData[dragID];
						
						if(obj["__drag__"])
						{
							_bDrag.evt(dragID, _fromListEvt);
						}
					}
					
					if(_dragTarget && _dragContainer)
					{
						_offsetX = fromR.mouseX;
						_offsetY = fromR.mouseY;
						
						_offsetX = _dragTarget.width >> 1;
						_offsetY = _dragTarget.height >> 1;
						
						_dragTarget.x = _dragContainer.mouseX - _offsetX;
						_dragTarget.y = _dragContainer.mouseY - _offsetY;
						
						_dragContainer.visible = true;
					}
					
					stage.addEventListener(MouseEvent.MOUSE_OVER, _onDragOver);
					stage.addEventListener(MouseEvent.MOUSE_OUT, _onDragOut);
				}
			}	
		}
		
		
		/**
		 * 드래그 오버 핸들러 
		 * @param $e
		 * 
		 */		
		static private function _onDragOver($e:MouseEventEx):void
		{
			var toR:ListItemRenderer = $e.target as ListItemRenderer, listData:*, obj:*, dragID:String
				, toEvt:ListEvent;
			
			if(toR)
			{
				listData = _listDic[toR.owner as CoreList];
				if(!listData)	return;
				
				toEvt = new ListEvent(ListEvent.ITEM_ROLL_OVER, false, true, toR.index, - 1, - 1, toR, toR.data, $e.mouseIdx, $e.buttonIdx);
				
				for(dragID in _fromListEvtData)
				{
					obj = _fromListEvtData[dragID];
					if(obj["__drag__"])
					{
						obj = listData[dragID];
						if(obj && obj["__drop__"])
						{
							_bOver.evt(dragID, _fromListEvt, toEvt);
						}
					}
				}
			}
		}
		
		
		/**
		 * 드래그 오버 핸들러 
		 * @param $e
		 * 
		 */		
		static private function _onDragOut($e:MouseEventEx):void
		{
			var toR:ListItemRenderer = $e.target as ListItemRenderer, listData:*, obj:*, dragID:String
				, toEvt:ListEvent;
			
			if(toR)
			{
				listData = _listDic[toR.owner as CoreList];
				if(!listData)	return;
				
				toEvt = new ListEvent(ListEvent.ITEM_ROLL_OUT, false, true, toR.index, - 1, - 1, toR, toR.data, $e.mouseIdx, $e.buttonIdx);
				
				for(dragID in _fromListEvtData)
				{
					obj = _fromListEvtData[dragID];
					if(obj["__drag__"])
					{
						obj = listData[dragID];
						if(obj && obj["__drop__"])
						{
							_bOut.evt(dragID, _fromListEvt, toEvt);
						}
					}
				}
			}
		}
		
		
		/**
		 *  드래그 취소
		 * 
		 */		
		static private function _reset():void
		{
			var stage:Stage = CLIK.stage;
			
			if(_dragContainer)
			{
				_dragContainer.visible = false;
				
				if(_dragTarget && _dragContainer.contains(_dragTarget))	_dragContainer.removeChild(_dragTarget);
			}
			
			stage.removeEventListener(Event.ENTER_FRAME, _move);
			stage.removeEventListener(MouseEvent.MOUSE_UP, _drop);
			
			stage.removeEventListener(MouseEvent.ROLL_OVER, _onDragOver);
			stage.removeEventListener(MouseEvent.ROLL_OUT, _onDragOut);
			
			_dragTarget = null;
			_fromListEvtData = null;
			_fromListEvt = null;
			_isDrag = false;
		}
		
		
		/**
		 *  드래그 취소
		 * 
		 */		
		static public function cancel():void
		{
			var dragID:String, obj:*;
			
			if(!_fromListEvtData)
			{
				_reset();
				return;
			}
			
			for(dragID in _fromListEvtData)
			{
				obj = _fromListEvtData[dragID];
				if(obj["__drag__"])	_bCancel.evt(dragID, _fromListEvt);
			}
			
			_reset();
		}
		
		
		/**
		 * 드롭 핸들러 
		 * @param $e
		 * 
		 */		
		static private function _drop($e:MouseEventEx):void
		{
			var r:ListItemRenderer = $e.target as ListItemRenderer, listData:*, obj:*, isDrop:Boolean, dragID:String
				, toEvt:ListEvent, stage:Stage;
			
			if(_isDrag)
			{
				r = $e.target as ListItemRenderer;
				if(r)
				{
					listData = _listDic[r.owner as CoreList];
					if(!listData)	return;
					
					toEvt = new ListEvent(ListEvent.ITEM_CLICK, false, true, r.index, - 1, - 1, r, r.data, $e.mouseIdx, $e.buttonIdx);
					
					for(dragID in _fromListEvtData)
					{
						obj = _fromListEvtData[dragID];
						if(obj["__drag__"])
						{
							obj = listData[dragID];
							if(obj && obj["__drop__"])
							{
								isDrop = true;
								_bDrop.evt(dragID, _fromListEvt, toEvt);
							}
						}
					}
				}
				
				if(isDrop)	_reset();
				else	cancel();
			}
			else if(_fromListEvt)
			{
				_isDrag = true;
				stage = CLIK.stage;
				
				r = _fromListEvt.itemRenderer as ListItemRenderer;
				
				//	드래그 핸들러 실행
				for(dragID in _fromListEvtData)
				{
					obj = _fromListEvtData[dragID];
					
					if(obj["__drag__"])
					{
						_bDrag.evt(dragID, _fromListEvt);
					}
				}
				
				if(_dragTarget && _dragContainer)
				{
					_offsetX = r.mouseX;
					_offsetY = r.mouseY;
					
					_offsetX = _dragTarget.width >> 1;
					_offsetY = _dragTarget.height >> 1;
					
					_dragTarget.x = _dragContainer.mouseX - _offsetX;
					_dragTarget.y = _dragContainer.mouseY - _offsetY;
					
					_dragContainer.visible = true;
				}
				
				stage.addEventListener(MouseEvent.MOUSE_OVER, _onDragOver);
				stage.addEventListener(MouseEvent.MOUSE_OUT, _onDragOut);
			}
		}
		
		
		public function ListManager()
		{
			throw new Error("don't create ListManager instance")
		}
	}
}