import com.minarto.data.ListBinding;
import com.minarto.manager.list.*;
import gfx.controls.CoreList;


class com.minarto.manager.list.ListActionBridge {
	private static var _manager:ListActionManager, _reservations:Array = [];
		
		
	public static var itemMoveActionType:String = ItemMoveActionType.DRAG_AND_DROP;	//	아이템 이동 방식
	public static var itemMoveButton:Number = 0;	//	아이템 이동시 사용하는 마우스 버튼
	public static var itemUseMouseButton:Number = 1;	//	아이템 사용시 사용하는 마우스 버튼
	public static var keyURL:String;	//	데이터의 이미지 키 이름
	public static var keyUseEnable:String;	//	데이터의 사용여부 키 이름
	public static var keyMoveEnable:String;	//	데이터의 이동여부 키 이름
	
	
	public static function init($manager:ListActionManager):Void{
		_manager = $manager;
		
		if ($manager) {
			for(var i in _reservations){
				$manager.addList.apply(null, _reservations[i]);
			}
			_reservations.length = 0;
		}
	}
	
	
	public static function addList($key:String, $list:CoreList, $param):Void{
		ListBinding.addListBind($key, $list);
		
		if(_manager){
			_manager.addList($key, $list, $param);
		}
		else{
			_reservations.push(arguments);
		}
	}
	
	
	public static function delList($list:CoreList):Void{
		ListBinding.delListBind($list);
		
		if(_manager){
			_manager.delList($list);
		}
		else if ($list) {
			for (var i:Number = 1, c:Number = _reservations.length; ++i) {
				var a:Array = _reservations[i];
				if (a[1] == $list) {
					_reservations.splice(i, 1);
					return;
				}
			}
		}
		else{
			_reservations.length = 0;
		}
	}
}