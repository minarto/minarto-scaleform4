package com.minarto.controls.list
{
	import flash.display.InteractiveObject;
	import flash.events.*;
	
	import scaleform.clik.constants.DirectionMode;
	import scaleform.clik.data.ListData;
	import scaleform.clik.interfaces.IListItemRenderer;
	
	
	public class MultiSelectList extends TileListX
	{
		override public function toString():String
		{
			return "[com.minarto.controls.list.MultiSelectList "+ name +"]";
		}
		
		
		/**
		 * 
		 */
		protected var _selectedItems:Array = [], _maxSelect:uint = 10;
		
		
		/**
		 * 
		 */
		public function get selectedItems():Array
		{
			return	_selectedItems;
		}
		
		
		/**
		 * 최대 선택 갯수
		 */
		public function get maxSelect():uint
		{
			return	_maxSelect;
		}
		public function set maxSelect($v:uint):void
		{
			_maxSelect = $v || 1;
		}
		
		
		override protected function setupRenderer($renderer:IListItemRenderer):void
		{
			$renderer.addEventListener(MouseEvent.CLICK, dispatchItemEvent, false, 0, true);

			super.setupRenderer($renderer);
		}
		
		
		override protected function cleanUpRenderer($renderer:IListItemRenderer):void
		{
			super.cleanUpRenderer($renderer);

			$renderer.removeEventListener(MouseEvent.CLICK, dispatchItemEvent);
		}
		
		
		override protected function dispatchItemEvent($e:Event):Boolean
		{
			var renderer:IListItemRenderer, me:MouseEvent, index:int;
			
			if ($e.type == MouseEvent.CLICK)
			{
				renderer = $e.currentTarget as IListItemRenderer;
				index = renderer.index;
				me = $e as MouseEvent;
				
				if(me.ctrlKey)
				{
					if(_selectedItems.indexOf(index) > -1)
					{
						_selectedItems.splice(_selectedItems.indexOf(index), 1);
					}
					else if(_selectedItems.length < _maxSelect)
					{
						_selectedItems.push(index);
					}
				}
				else
				{
					_selectedItems.length = 0;
					_selectedItems.push(index);
				}
				
				invalidateSelectedIndex();
				
				return	false;
			}
			
			return super.dispatchItemEvent($e);
		}
		
		
		override protected function updateSelectedIndex():void
		{
			super.updateSelectedIndex();
			
			var i:uint, l:uint = _renderers ? _renderers.length : 0, renderer:IListItemRenderer;
			
			if(_selectedIndex == -1)	_selectedItems.length = 0;
			
			for(; i<l; ++i)
			{
				renderer = getRendererAt(i);
				renderer.selected = _selectedItems.indexOf(renderer.index) > - 1;
				renderer.validateNow();
			}
		}
		
		
		override protected function populateData($datas:Array):void
		{
			//super.populateData(data);
			
			var dl:uint = $datas.length, l:uint = _renderers.length, i:uint, r:IListItemRenderer, itemData:*, index:uint, 
				_index:uint = _scrollPosition * ((_direction == DirectionMode.HORIZONTAL) ? _totalRows : _totalColumns)
				, listData:ListData;
			
			for (; i < l; ++i)
			{
				r = getRendererAt(i);
				itemData = $datas[i];
				index = _index + i;
				//r.enabled = (i < dl);
				
				listData = pool.object;
				listData.index = index;
				listData.label = itemToLabel(itemData);
				listData.selected = (_selectedItems.indexOf(index) > - 1);
				
				r.setListData(listData);
				
				pool.object = listData;
				
				r.setData(itemData);
				r.validateNow();
			}
		}
	}
}