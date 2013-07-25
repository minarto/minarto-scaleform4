import com.minarto.manager.*;
import com.minarto.utils.Util;
import gfx.controls.*;
import gfx.data.DataProvider;
import gfx.events.EventTypes;
import gfx.utils.Delegate;


class com.minarto.manager.ListManager extends EventDispatcher {
	private static var hnItemPress:Function, hnItemLoadComplete:Function, hnItemDrag:Function, hnMouseUp:Function, hnItemClick:Function;
	
	
	private static function _init() {
		var listDic = { }, fromSlot:ListItemRenderer, mEvt:MovieClip, point = { }, dataDic = {};
		
		mEvt = _root.createEmptyMovieClip("__mEvt__", _root.getNextHighestDepth());
		_global.ASSetPropFlags(_root, "__mEvt__", 1);
		
		var content:MovieClip = mEvt.createEmptyMovieClip("content", 0);
		
		mEvt._visible = false;
		mEvt.hitTestDisable = true;
		mEvt.topmostLevel = true;
		mEvt.enabled = false;
		
		
		add = function() {
			var i, c:Number, id:String, list:CoreList, pType:String = EventTypes.ITEM_PRESS, cType:String = EventTypes.ITEM_CLICK, data, a:Array, j:Number, l:Number;
			
			for (i = 0, c = arguments.length; i < c; ++ i) {
				id = arguments[i ++];
				list = arguments[i];
				
				list["id"] = id;
				list.addEventListener(pType, ListManager, "hnItemPress");
				list.addEventListener(cType, ListManager, "hnItemClick");
				
				list.dataProvider = data = dataDic[id];
				
				a = listDic[id];
				if (!a)	listDic[id] = a;
				for (j = 0, l = a.length; j < l; ++ j)	if (a[id] == list)	break;
				if (j == l)	a.push(list);
			}
		}
		
		
		del = function() {
			var i, c:Number, list:CoreList, pType:String = EventTypes.ITEM_PRESS, cType:String = EventTypes.ITEM_CLICK, a:Array, j;
			
			if(arguments.length){
				for (i = 0, c = arguments.length; i < c; ++ i) {
					list =  arguments[i];
					list.removeEventListener(pType, ListManager, "hnItemPress");
					list.removeEventListener(cType, ListManager, "hnItemClick");
					
					a = listDic[list["id"]];
					for (j in a) {
						if (a[j] == list) {
							a.splice(j, 1);
							if (!a.length)	delete listDic[list["id"]];
							break;
						}
					}
				}
			}
			else {
				for (i in listDic) {
					list = listDic[i];
					list.removeEventListener(pType, ListManager, "hnItemPress");
					list.removeEventListener(cType, ListManager, "hnItemClick");
				}
				
				listDic = {};
			}
		}
		
		
		hnItemPress = function($e) {
			var list:CoreList, data = $e.item, content:MovieClip, startPoint;
			
			if (data) {
				LoadManager.load(mEvt["content"], data.src, hnItemLoadComplete, ListManager);
				
				list = $e.target;
				fromSlot = $e.renderer;
				
				startPoint = Util.point;
				startPoint.x = 0;
				startPoint.y = 0;
				
				content = fromSlot["content"];
				
				content.localToGlobal(startPoint);
				
				point.x = content._xmouse;
				point.y = content._ymouse;
				content.localToGlobal(point);
				
				point.x -= startPoint.x;
				point.y -= startPoint.y;
				
				Mouse.addListener(ListManager);
			}
		}
		
		
		hnItemLoadComplete = function($content:MovieClip) {
			$content._width = 64;
			$content._height = 64;
			mEvt._visible = true;
			mEvt.onEnterFrame = Delegate.create(ListManager, hnItemDrag);
		}
		
		
		hnItemDrag = function() {
			var c:MovieClip = mEvt["content"], p = point;
			
			c._x = _root._x + p.x;
			c._y = _root._y + p.y;
		}
		
		
		hnMouseUp = function() {
			var targetSlot:MovieClip = eval(arguments[1]), list:CoreList, e;
			
			Mouse.removeListener(ListManager);
			
			mEvt._visible = false;
			LoadManager.unLoad(mEvt["content"]);
			
			while (targetSlot) {
				if (targetSlot.owner) {
					list = targetSlot.owner;
					break;
				}
				
				targetSlot = targetSlot._parent;
			}
			
			if (list) {
				e = { type:"itemDrag", target:ListManager, fromListID:fromSlot.owner["id"], fromIndex:fromSlot.index, targetListID:list["id"], targetIndex:targetSlot.index, item:fromSlot.data };
			}
		}
		
		
		hnItemClick = function($e) {
			var slot:ListItemRenderer = $e.renderer, listID = slot.owner["id"], index:Number = $e.index, data = $e.item;
		}
		
		
		setList = function($id, $datas) {
			var a:Array, i;
			
			if ($datas) {
				if (dataDic[$id] == $datas)	$datas.invalidate();
				else {
					DataProvider.initialize($datas);
					dataDic[$id] = $datas;
					
					a = listDic[$id];
					for (i in a)	a[i].dataProvider = $datas;
				}
			}
			else {
				dataDic[$id] = $datas;
				a = listDic[$id];
				for (i in a)	a[i].dataProvider = $datas;
			}
		}
		
		
		getList = function() {
			return	dataDic[arguments[0]];
		}
		
		
		setData = function($id, $index:Number, $data) {
			var datas:Array = dataDic[$id];
			
			if (datas) {
				datas[$index] = $data;
				datas.invalidate();
			}
			else {
				datas = [];
				datas[$index] = $data;
				
				setList($id, datas);
			}
		}
	}
		
		
	public static function add($id, $list:CoreList):Void {
		_init();
		add.apply(ListManager, arguments);
	}
		
		
	public static function del($list:CoreList):Void {
		_init();
		del.apply(ListManager, arguments);
	}
		
		
	public static function setList($id, $datas:Array):Void {
		_init();
		setList($id, $datas);
	}
		
		
	public static function getList($id):Array {
		_init();
		return	getList($id);
	}
		
		
	public static function setData($id, $index:Number, $data):Void {
		_init();
		setData($id, $index, $data);
	}
}