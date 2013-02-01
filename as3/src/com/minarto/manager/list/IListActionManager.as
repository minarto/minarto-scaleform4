package com.minarto.manager.list {
	import scaleform.clik.controls.CoreList;

	public interface IListActionManager {
		function addList($key:String, $list:CoreList, $param:ListParam):void;
		function delList($list:CoreList=null):void;
	}
}