package com.minarto.controls.list
{
	import de.polygonal.core.ObjectPool;
	
	import com.minarto.data.ListDataX;
	
	import scaleform.clik.constants.DirectionMode;
	import scaleform.clik.controls.TileList;
	import scaleform.clik.data.ListData;
	import scaleform.clik.interfaces.IListItemRenderer;
	

	public class TileListX extends TileList
	{
		override public function toString():String 
		{
			return "[fcm.controls.TileListX " + name + "]";
		}
		
		
		protected var pool:ObjectPool = new ObjectPool(true);
		
		
		override protected function configUI():void
		{
			super.configUI();
			
			pool = new ObjectPool(true);
			pool.allocate(1, ListDataX);
		}
		
		
		override protected function populateData(data:Array):void
		{
			//super.populateData(data);
			
			var dl:uint = data.length, l:uint = _renderers.length, renderer:IListItemRenderer, i:uint, index:uint
				, itemData:*, listData:ListData
				, c:uint = _scrollPosition * ((_direction == DirectionMode.HORIZONTAL) ? _totalRows : _totalColumns);
			
			for (; i < l; i++)
			{
				renderer = getRendererAt(i);
				itemData = data[i];
				index = c + i;
				
				//renderer.enabled = (i >= dl) ? false : true;
				
				listData = pool.object;
				listData.index = index;
				listData.label = itemToLabel(itemData);
				listData.selected = (_selectedIndex == index);
				
				renderer.setListData(listData);
				
				pool.object = listData;
				
				renderer.setData(itemData);
				
				renderer.validateNow();
			}
		}
	}
}