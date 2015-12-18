import com.minarto.data.*;
import gfx.controls.*;
import gfx.events.EventTypes;
import gfx.utils.Delegate;


class com.minarto.managers.ListDragManager
{
	static private var _listDic = { }, _dragContainer:MovieClip, _dragObj:MovieClip, _fromListEvtData, _fromListEvt, _fromX:Number = 0, _fromY:Number = 0, onMouseUp:Function, _isDrag:Boolean;
	
	
	static public function init($container:MovieClip):Void
	{
		$container.hitTestDisable = true;
		_dragContainer = $container;
		
		Mouse.addListener(ListDragManager);
	}
	
	
	static public function setDragObj($dragObj:MovieClip):Void
	{
		_dragObj = $dragObj;
	}
	
	
	static public function addList($dragID:String, $list:CoreList, $drag:Boolean, $drop:Boolean ):Void
	{
		var listData, obj, path:String;
		
		if(!$drag && !$drop)	return;
		
		path = targetPath($list);
		
		listData = _listDic[path] || (_listDic[path] = {});
		
		obj = listData[$dragID] || (listData[$dragID] = {});
		obj["__drag__"] = $drag;
		obj["__drop__"] = $drop;
	}
	
	
	static public function addDrag($dragID:String, $handler:Function):Void
	{
		var b:Binding = BindingDic.get("__ListDragManager__.drag");
		
		b.add.apply(null, arguments);
	}
	
	
	static public function addDragOver($dragID:String, $handler:Function):Void
	{
		var b:Binding = BindingDic.get("__ListDragManager__.dragOver");
		
		b.add.apply(null, arguments);
	}
	
	
	static public function addDragOut($dragID:String, $handler:Function):Void
	{
		var b:Binding = BindingDic.get("__ListDragManager__.dragOut");
		
		b.add.apply(null, arguments);
	}
	
	
	static public function addMove($dragID:String, $handler:Function):Void
	{
		var b:Binding = BindingDic.get("__ListDragManager__.move");
		
		b.add.apply(null, arguments);
	}
	
	
	static public function addDrop($dragID:String, $handler:Function):Void
	{
		var b:Binding = BindingDic.get("__ListDragManager__.drop");
		
		b.add.apply(null, arguments);
	}
	
	
	static public function addCancel($dragID:String, $handler:Function):Void
	{
		var b:Binding = BindingDic.get("__ListDragManager__.cancel");
		
		b.add.apply(null, arguments);
	}
	
	
	static public function del($dragID:String, $handler:Function):Void
	{
		var b:Binding = BindingDic.get("__ListDragManager__.drag");
		
		b.del($dragID, $handler);
		
		b = BindingDic.get("__ListDragManager__.dragOver");
		b.del($dragID, $handler);
		
		b = BindingDic.get("__ListDragManager__.dragOut");
		b.del($dragID, $handler);
		
		b = BindingDic.get("__ListDragManager__.move");
		b.del($dragID, $handler);
		
		b = BindingDic.get("__ListDragManager__.drop");
		b.del($dragID, $handler);
		
		b = BindingDic.get("__ListDragManager__.cancel");
		b.del($dragID, $handler);
	}
	
	
	static private function _hasListenerCheckList($list:CoreList):Void
	{
		var path:String = targetPath($list), listData = _listDic[path], dragID:String, obj, isOk:Boolean;
			
		for(dragID in listData)
		{
			obj = listData[dragID];
			if(obj["__drag__"] || obj["__drop__"])
			{
				isOk = true;
				break;
			}
		}
		
		if(!isOk)	delete	_listDic[path];
	}
	
	
	static public function delList($dragID:String, $list:CoreList):Void
	{
		var path:String, listData, list, i:Number;
			
		if($list)
		{
			path = targetPath($list);
			if($dragID)
			{
				listData = _listDic[path];
				if(listData)
				{
					delete	listData[$dragID];
				}
				
				_hasListenerCheckList($list);
			}
			else
			{
				delete	_listDic[path];
			}
		}
		else if($dragID)
		{
			arguments.length = 0;
			
			for(path in _listDic)
			{
				listData = _listDic[path];
				delete	listData[$dragID];
				
				i = arguments.push(eval(path));
			}
			
			while(i --)
			{
				_hasListenerCheckList(arguments[i]);
			}
		}
	}
	
	
	static private function onMouseDown($button:Number, $path:String, $mouseIDx:Number):Void
	{
		var fromR:ListItemRenderer = Mouse.getTopMostEntity(), dragID:String, obj;
		
		cancel();
		
		if (!fromR || !fromR.data)	return;
		
		$path = targetPath(fromR.owner);
		
		_fromListEvtData = _listDic[$path];
		if (!_fromListEvtData)	return;
		
		_fromListEvt = { type:"itemPress", target:fromR, item:fromR.data, renderer:fromR, index:fromR.index, button:$button, controllerIdx:$mouseIDx };
		
		//	드래그 실행 여부
		for(dragID in _fromListEvtData)
		{
			obj = _fromListEvtData[dragID];
			if(obj["__drag__"])
			{
				_fromX = _root._xmouse;
				_fromY = _root._ymouse;
				
				_dragContainer.onEnterFrame = Delegate.create(this, _onMove);
				onMouseUp = _onDrop;
				return;
			}
		}
	}
	
	
	static private var _pr:ListItemRenderer;
	
	
	static private function _onMove():Void
	{
		var dragID:String, obj, b:Binding, fromR:ListItemRenderer;
			
		if(_isDrag)
		{
			if(_dragContainer && _dragObj)
			{
				_dragObj._x = _dragContainer._xmouse - _offsetX;
				_dragObj._y = _dragContainer._ymouse - _offsetY;
			}
			
			b = BindingDic.get("__ListDragManager__.move");
			
			for(dragID in _fromListEvtData)
			{
				obj = _fromListEvtData[dragID];
				if(obj["__drag__"])	b.event(dragID, _fromListEvt);
			}
			
			fromR = ListItemRenderer(Mouse.getTopMostEntity());
			if (fromR != _pr)
			{
				_pr = fromR;
				_onDragOut(_pr);
				_onDragOver(fromR);
			}
			
			_dragObj.topmostLevel = true;
		}
		else
		{
			if(Math.abs(_fromX - _root._xmouse) > 5 || Math.abs(_fromY - _root._ymouse) > 5)
			{
				_isDrag = true;
				
				fromR = _fromListEvt.renderer;
				
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
					_offsetX = fromR._xmouse;
					_offsetY = fromR._ymouse;
					
					_offsetX = _dragTarget._width >> 1;
					_offsetY = _dragTarget._height >> 1;
					
					_dragTarget._x = _dragContainer._xmouse - _offsetX;
					_dragTarget._y = _dragContainer._ymouse - _offsetY;
					
					_dragContainer._visible = true;
				}
			}
		}
	}
	
	
	static private function _onDragOver($toR:ListItemRenderer):Void
	{
		var path:String, listData, obj, dragID:String, toEvt, b:Binding;
			
		if($toR)
		{
			path = targetPath($toR.owner);
			listData = _listDic[path];
			if(!listData)	return;
			
			toEvt = { type:EventTypes.ITEM_ROLL_OVER, target:$toR, item:$toR.data, renderer:$toR, index:$toR.index, controllerIdx:_fromListEvt["controllerIdx"] };
			
			b = BindingDic.get("__ListDragManager__.dragOver");
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
	
	
	static private function _onDragOut($toR:ListItemRenderer):Void
	{
		var path:String, listData, obj, dragID:String, toEvt, b:Binding;
			
		if($toR)
		{
			path = targetPath($toR.owner);
			listData = _listDic[path];
			if(!listData)	return;
			
			toEvt = { type:EventTypes.ITEM_ROLL_OUT, target:$toR, item:$toR.data, renderer:$toR, index:$toR.index, controllerIdx:_fromListEvt["controllerIdx"] };
			
			b = BindingDic.get("__ListDragManager__.dragOut");
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
	static private function _reset():Void
	{
		var path:String, list:CoreList;
		
		if(_dragContainer)
		{
			_dragContainer.visible = false;
			if(_dragObj)	_dragObj.topmostLevel = false;
		}
		
		delete	_dragContainer.onEnterFrame;
		delete	onMouseUp;
		
		_dragObj = null;
		_fromListEvtData = null;
		_fromListEvt = null;
		_isDrag = false;
		
		for (path in _listDic)
		{
			if (!eval(path))
			{
				delete	_listDic[path];
			}
		}
	}
	
	
	static public function cancel():Void
	{
		var dragID:String, obj, b:Binding;
			
		if(!_fromListEvtData)
		{
			_reset();
			return;
		}
		
		b = BindingDic.get("__ListDragManager__.cancel");
		for(dragID in _fromListEvtData)
		{
			obj = _fromListEvtData[dragID];
			if(obj["__drag__"])	b.event(dragID, _fromListEvt);
		}
		
		_reset();
	}
	
	
	static private function _onDrop($button:Number, $path:String, $mouseIDx:Number):Void
	{
		var toR:ListItemRenderer = ListItemRenderer(Mouse.getTopMostEntity()), listData, obj, isDrop:Boolean, dragID:String
			, toEvt, b:Binding;
		
		if(toR)
		{
			$path = targetPath(toR.owner);
			listData = _listDic[$path];
			if(!listData)	return;
			
			toEvt = { type:EventTypes.ITEM_CLICK, target:toR, item:toR.data, renderer:toR, index:toR.index, controllerIdx:$mouseIDx, button:$button };
			
			b = BindingDic.get("__ListDragManager__.drop");
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
		trace("Error - don't create instance")
	}
}
