package com.minarto.controls
{
	import com.minarto.interfaces.IContent;
	
	import scaleform.clik.core.UIComponent;

	
	/**
	 * @author KIMMINHWAN
	 */
	public class ToolTipBase extends UIComponent implements IContent
	{
		protected var datas:*;
		
		
		public function setData(...$datas) : void
		{
			datas = $datas;
		}
	}
}
