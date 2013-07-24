package com.minarto.manager {
	/**
	 * @author KIMMINHWAN
	 */
	public class ToolTipManager {
		private static var container:IToolTipContainer;
		
		
		public function ToolTipManager(){
			throw new Error("don't create instance");
		}
		
		
		public static function init($container:IToolTipContainer):void{
			container = $container;
		}
		
		
		public static function add(...$btns):void{
			container.add.apply(ToolTipManager, $btns);
		}
		
		
		public static function del(...$btns) : void {
			container.del.apply(ToolTipManager, $btns);
		}
	}
}