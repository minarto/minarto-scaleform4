package sample.controls
{
	import flash.display.DisplayObject;
			
	import scaleform.clik.controls.Button;
		
	
	public class Btn extends Button
	{
		public var mcNew:DisplayObject, mcHot:DisplayObject;
		
		
		override protected function configUI():void
		{
         		super.configUI();
			
				mcNew.visible = false;
				mcHot.visible = false;
	    }
		
		
		override protected function draw():void
		{
         		super.draw();
			
				if (_data)
				{
					if (isInvalid("new"))
					{
						trace("invalidate('new') 실행");
						if (_data)
						{
							mcNew.visible = _data["isNew"];
						}
						else
						{
							mcNew.visible = false;
						}
					}
				
					if (isInvalid("hot"))
					{
						trace("invalidate('hot') 실행");
						if (_data)
						{
							mcHot.visible = _data["isHot"];
						}
						else
						{
							mcHot.visible = false;
						}
					}
				}
				else
				{
					mcNew.visible = false;
					mcHot.visible = false;
				}
				
	    }
	}
}
