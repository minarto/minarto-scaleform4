package com.minarto.controls.list
{
	import de.polygonal.core.ObjectPool;
	
	import com.minarto.data.ListDataX;
	
	import scaleform.clik.controls.ScrollingList;
	import scaleform.clik.data.ListData;
	import scaleform.clik.interfaces.IListItemRenderer;
	
	
	public class ScrollingListX extends ScrollingList
	{
		override public function toString():String
		{
			return	"[fcm.controls.ScrollingListX " + name + "]";
		}
		
		
		protected const pool:ObjectPool = new ObjectPool(true);
		
		
		override protected function configUI():void
		{
			super.configUI();
			
			pool.allocate(1, ListDataX);
		}
		
		
		override protected function populateData(data:Array):void
		{
			//super.populateData(data);
			
			var dl:uint = data.length, i:uint, l:uint = _renderers.length, renderer:IListItemRenderer, index:uint
				, itemData:*, listData:ListData;
			
			for (; i < l; i++)
			{
				renderer = getRendererAt(i);
				itemData = data[i];
				index = _scrollPosition + i;
				
				listData = pool.object;
				listData.index = index;
				listData.label = itemToLabel(itemData);
				listData.selected = (_selectedIndex == index);
				
				//listData = new ListData(index, itemToLabel(data[i]), _selectedIndex == index);
				//renderer.enabled = (i >= dl) ? false : true;
				
				renderer.setListData(listData);
				
				pool.object = listData;
				
				renderer.setData(itemData);
				renderer.validateNow();
			}
		}
	}
}