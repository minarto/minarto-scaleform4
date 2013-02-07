package com.minarto.manager.list {
	import com.minarto.data.ListBinding;
	
	import scaleform.clik.controls.CoreList;
	import scaleform.gfx.*;
	
	
	public class ListActionBridge {
		private static var _manager:ListActionManager, _reservations:Array = [];
		
		
		public static var itemMoveActionType:String = ItemMoveActionType.DRAG_AND_DROP;	//	아이템 이동 방식
		public static var itemMoveButton:uint = MouseEventEx.LEFT_BUTTON;	//	아이템 이동시 사용하는 마우스 버튼
		public static var itemUseMouseButton:uint = MouseEventEx.RIGHT_BUTTON;	//	아이템 사용시 사용하는 마우스 버튼
		public static var keyURL:String;	//	데이터의 이미지 키 이름
		public static var keyUseEnable:String;	//	데이터의 사용여부 키 이름
		public static var keyMoveEnable:String;	//	데이터의 이동여부 키 이름
		
		
		public static function init($manager:ListActionManager):void{
			_manager = $manager;
			
			if($manager){
				for(var i:* in _reservations){
					$manager.addList.apply($manager, _reservations[i]);
				}
				_reservations.length = 0;
			}
		}
		
		
		public static function addList($key:String, $list:CoreList, $param:*):void{
			ListBinding.addListBind($key, $list);
			
			if(_manager){
				_manager.addList($key, $list, $param);
			}
			else{
				_reservations.push(arguments);
			}
		}
		
		
		public static function delList($list:CoreList=null):void{
			ListBinding.delListBind($list);
			
			if(_manager){
				_manager.delList($list);
			}
			else if($list){
				var i:int = _reservations.length;
				while(i --){
					var a:Array = _reservations[i];
					if(a[1] == $list){
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
}