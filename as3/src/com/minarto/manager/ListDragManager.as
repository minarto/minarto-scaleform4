package com.minarto.manager 
{
	import com.minarto.data.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.Dictionary;
	
	import scaleform.clik.controls.*;
	import scaleform.clik.core.CLIK;
	import scaleform.clik.events.ListEvent;
	import scaleform.gfx.*;

	
	/**
	 * @author minarto
	 */
	public class ListDragManager
	{
		static private const _listDic:Dictionary = new Dictionary(true);
		
		
		static private var _fromListEvt:ListEvent, _dragContainer:DisplayObjectContainer, _offsetX:Number, _offsetY:Number
		, _dragTarget:DisplayObject, _fromListEvtData:*, _fromX:Number, _fromY:Number, _isDrag:Boolean;
		
		
		/**
		 * 리스트 매니저 초기화 
		 * @param $stage
		 * @param $container
		 * 
		 */		
		static public function init($container:DisplayObjectContainer):void
		{
			InteractiveObjectEx.setHitTestDisable($container, true);
			_dragContainer = $container;
			
			CLIK.stage.addEventListener(MouseEvent.MOUSE_DOWN, _onDown);
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
		static public function add($dragID:*, $list:CoreList, $drag:Boolean=true, $drop:Boolean=true):void
		{
			var listData:*, obj:*;
			
			if(!$drag && !$drop)	return;
			
			listData = _listDic[$list] || (_listDic[$list] = {});
			
			obj = listData[$dragID] || (listData[$dragID] = {});
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
		static public function addDragHandler($dragID:String, $handler:Function, ...$args):void
		{
			var b:Binding = BindingDic.get("__ListDragManager__.drag");
			
			$args.unshift($dragID, $handler);
			b.add.apply(null, $args);
		}
		
		
		/**
		 * 드래그 오버 핸들러 등록 
		 * @param $dragID
		 * @param $handler
		 * @param $args
		 * 
		 */		
		static public function addDragOverHandler($dragID:String, $handler:Function, ...$args):void
		{
			var b:Binding = BindingDic.get("__ListDragManager__.dragOver");
			
			$args.unshift($dragID, $handler);
			b.add.apply(null, $args);
		}
		
		
		/**
		 * 드래그 오버 핸들러 등록 
		 * @param $dragID
		 * @param $handler
		 * @param $args
		 * 
		 */		
		static public function addDragOutHandler($dragID:String, $handler:Function, ...$args):void
		{
			var b:Binding = BindingDic.get("__ListDragManager__.dragOut");
			
			$args.unshift($dragID, $handler);
			b.add.apply(null, $args);
		}
		
		
		/**
		 * 무브 핸들러 등록 
		 * @param $dragID
		 * @param $handler
		 * @param $args
		 * 
		 */		
		static public function addMoveHandler($dragID:*, $handler:Function, ...$args):void
		{
			var b:Binding = BindingDic.get("__ListDragManager__.move");
			
			$args.unshift($dragID, $handler);
			b.add.apply(null, $args);
		}
		
		
		/**
		 * 드롭 핸들러 등록 
		 * @param $dragID
		 * @param $handler
		 * @param $args
		 * 
		 */		
		static public function addDropHandler($dragID:*, $handler:Function, ...$args):void
		{
			var b:Binding = BindingDic.get("__ListDragManager__.drop");
			
			$args.unshift($dragID, $handler);
			b.add.apply(null, $args);
		}
		
		
		/**
		 * 캔슬 핸들러 등록 
		 * @param $dragID
		 * @param $handler
		 * @param $args
		 * 
		 */		
		static public function addCancelHandler($dragID:*, $handler:Function, ...$args):void
		{
			var b:Binding = BindingDic.get("__ListDragManager__.cancel");
			
			$args.unshift($dragID, $handler);
			b.add.apply(null, $args);
		}
		
		
		/**
		 * 핸들러 삭제 
		 * @param $handler
		 * @param $dragID
		 * 
		 */			
		static public function delHandler($dragID:*=null, $handler:Function = null):void
		{
			var b:Binding;
			
			b = BindingDic.get("__ListDragManager__.drag");
			b.del($dragID, $handler);
			
			b = BindingDic.get("__ListDragManager__.move");
			b.del($dragID, $handler);
			
			b = BindingDic.get("__ListDragManager__.dragOver");
			b.del($dragID, $handler);
			
			b = BindingDic.get("__ListDragManager__.dragOut");
			b.del($dragID, $handler);			
			
			b = BindingDic.get("__ListDragManager__.drop");
			b.del($dragID, $handler);
			
			b = BindingDic.get("__ListDragManager__.cancel");
			b.del($dragID, $handler);
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
		static public function del($dragID:*=null, $list:CoreList=null):void
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
		static private function _onDown($e:MouseEventEx):void
		{
			var fromR:ListItemRenderer = $e.target as ListItemRenderer, dragID:String, obj:*, stage:Stage;
			
			cancel();
			if(!fromR || !fromR.data)	return;
			
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
					
					stage.addEventListener(Event.ENTER_FRAME, _onMove);
					stage.addEventListener(MouseEvent.MOUSE_UP, _onDrop);
					
					return;
				}
			}
		}
		
		
		static private function _onMove($e:Event):void 
		{
			var dragID:String, obj:*, b:Binding, stage:Stage, fromR:ListItemRenderer;
			
			if(_isDrag)
			{
				if(_dragContainer && _dragTarget)
				{
					_dragTarget.x = _dragContainer.mouseX - _offsetX;
					_dragTarget.y = _dragContainer.mouseY - _offsetY;
				}
				
				b = BindingDic.get("__ListDragManager__.move");
				
				for(dragID in _fromListEvtData)
				{
					obj = _fromListEvtData[dragID];
					if(obj["__drag__"])	b.event(dragID, _fromListEvt);
				}
			}
			else
			{
				stage = CLIK.stage;
				
				if(Math.abs(_fromX - stage.mouseX) > 5 || Math.abs(_fromY - stage.mouseY) > 5)
				{
					_isDrag = true;
					
					fromR = _fromListEvt.itemRenderer as ListItemRenderer;
					
					b = BindingDic.get("__ListDragManager__.drag");
					
					//	드래그 핸들러 실행
					for(dragID in _fromListEvtData)
					{
						obj = _fromListEvtData[dragID];
						
						if(obj["__drag__"])
						{
							b.event(dragID, _fromListEvt);
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
				, toEvt:ListEvent, b:Binding = BindingDic.get("__ListDragManager__.dragOver");
			
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
							b.event(dragID, _fromListEvt, toEvt);
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
				, toEvt:ListEvent, b:Binding = BindingDic.get("__ListDragManager__.dragOut");
			
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
							b.event(dragID, _fromListEvt, toEvt);
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
			
			stage.removeEventListener(Event.ENTER_FRAME, _onMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, _onDrop);
			
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
			var dragID:String, obj:*, b:Binding = BindingDic.get("__ListDragManager__.cancel");
			
			if(!_fromListEvtData)
			{
				_reset();
				return;
			}
			
			for(dragID in _fromListEvtData)
			{
				obj = _fromListEvtData[dragID];
				if(obj["__drag__"])	b.event(dragID, _fromListEvt);
			}
			
			_reset();
		}
		
		
		/**
		 * 드롭 핸들러 
		 * @param $e
		 * 
		 */		
		static private function _onDrop($e:MouseEventEx):void
		{
			var toR:ListItemRenderer = $e.target as ListItemRenderer, listData:*, obj:*, isDrop:Boolean, dragID:String
				, toEvt:ListEvent, b:Binding = BindingDic.get("__ListDragManager__.drop");
			
			if(toR)
			{
				listData = _listDic[toR.owner as CoreList];
				if(!listData)	return;
				
				toEvt = new ListEvent(ListEvent.ITEM_CLICK, false, true, toR.index, - 1, - 1, toR, toR.data, $e.mouseIdx, $e.buttonIdx);
				
				for(dragID in _fromListEvtData)
				{
					obj = _fromListEvtData[dragID];
					if(obj["__drag__"])
					{
						obj = listData[dragID];
						if(obj && obj["__drop__"])
						{
							isDrop = true;
							b.event(dragID, _fromListEvt, toEvt);
						}
					}
				}
			}
			
			if(isDrop)	_reset();
			else	cancel();
		}
		
		
		public function ListDragManager()
		{
			throw new Error("don't create ListManager instance")
		}
	}
}