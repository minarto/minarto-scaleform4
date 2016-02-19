package com.minarto.manager 
{
	import com.minarto.loader.MUILoader;
	
	import flash.display.*;
	import flash.events.*;
	import flash.external.ExternalInterface;
	
	import scaleform.gfx.InteractiveObjectEx;
	
	
	/**
	 * @author KIMMINHWAN
	 */
	public class SceneManager 
	{
		protected const loader:MUILoader = new MUILoader;
		
		
		protected var dic:* = {}, container:DisplayObjectContainer, sceneDataDic:* = {}, trashDic:* = {}, srcDic:* = {}, sceneID:*;
		
		
		public function SceneManager($container:DisplayObjectContainer):void
		{
			container = $container;
			dic = {};
		}
		
		
		public function set($sceneID:*, $vars:*=null):void
		{
			var sceneDatas:Array = sceneDataDic[$sceneID], i:uint, l:uint = sceneDatas ? sceneDatas.length : 0, a:Array = []
				, vars:*, id:*, src:String, pVars:*;
			
			sceneID = $sceneID;
			
			for(; i < l; ++ i)
			{
				vars = sceneDatas[i];
				
				id = vars.id;
				src = vars.src;
				src = srcDic[src] ? srcDic[src] : src;
				
				pVars = get(id);
				if(pVars && (pVars.src == src) && vars.noCache)
				{
					delete	dic[id];
					trashDic[id] = pVars;
				}
				else	continue;
				
				a.push(id, src, vars);
			}
			
			del(null);
			
			add.apply(null, a);
		}
		
		
		public function add($id:*, $src:String, $vars:*=null, ...$args):void
		{
			var i:uint, l:uint, pVars:*;
			
			$args.unshift($id, $src, $vars);
			
			for(l = $args.length; i<l; i += 3)
			{
				$id = $args[i];
				$src = $args[i + 1];
				$vars = $args[i + 2];
				if(!$vars)	$vars = {};
				
				$src = srcDic[$src] ? srcDic[$src] : $src;
				
				pVars = get($id);
				if(pVars && (pVars.src == $src) && $vars.noCache)	trashDic[$id] = pVars;
				else	continue;
				
				$vars.id = $id;
				
				dic[$id] = $vars;
				
				loader.add($src, $vars);
			}
		}
		
		
		public function load($loadSceneComplete:Function=null, $startSceneComplete:Function=null, $delSceneComplete:Function=null, $vars:*=null):void
		{
			if(!$vars)	$vars = {};
			
			$vars.loadSceneComplete = $loadSceneComplete;
			$vars.startSceneComplete = $startSceneComplete;
			$vars.delSceneComplete = $delSceneComplete;
			
			loader.load(allComplete, $vars);
		}
		
		
		public function del($id:*, $vars:*=null, ...$args):void
		{
			var i:uint, l:uint, vars:*, d:DisplayObject, func:Function;
			
			if($id)
			{
				$args.unshift($id, $vars);
				
				for(l = $args.length; i<l; i += 2)
				{
					$id = $args[i];
					$vars = $args[i + 2];
					
					vars = dic[$id];
					if(vars)
					{
						if($vars)
						{
							vars.onDelComplete = $vars.onDelComplete;
							vars.onDelCompleteParams = $vars.onDelCompleteParams;
							vars.onDelError = $vars.onDelError;
							vars.onDelErrorParams = $vars.onDelErrorParams;
						}						
						
						delete	dic[$id];
						trashDic[$id] = vars;
					}
					else
					{
						if($vars)
						{
							func = $vars.onDelError;
							if(func)	func.apply(null, $vars.onDelErrorParams);
						}
						ExternalInterface.call("delError", $id);
					}
				}
			}
			else
			{
				for($id in dic)
				{
					vars = dic[$id];
					trashDic[$id] = vars;
				}
				
				dic = {};
			}
			
			delRun();
		}
		
		
		protected function delRun():void
		{
			var id:*, vars:*, d:DisplayObject, func:Function;
			
			for(id in trashDic)
			{
				vars = trashDic[id];
				d = vars.content;
				if(d)
				{
					if(d.hasOwnProperty("destroy"))
					{
						func = d["destroy"];
						d.addEventListener("delComplete", delComplete);
						func();
					}
					else
					{
						container.removeChild(d);

						delete	vars.content;
						delete	trashDic[id];
						
						func = vars.onDelComplete;
						if(func)	func.apply(null, vars.onDelCompleteParams);
						
						ExternalInterface.call("delComplete", id);
					}
				}
				else
				{
					func = vars.onDelError;
					if(func)	func.apply(null, vars.onDelErrorParams);
					ExternalInterface.call("delError", id);
				}
			}
		}
		
		
		public function get($id:*):*
		{
			return	dic[$id];
		}
		
		
		protected function delComplete($e:Event):void
		{
			var d:DisplayObject = $e.target as DisplayObject, id:*, vars:*, func:Function;
			
			for(id in trashDic)
			{
				vars = trashDic[id];
				if(d == vars.content)
				{
					d.removeEventListener("delComplete", delComplete);
					container.removeChild(d);
					
					delete	vars.content;
					delete	trashDic[id];
					
					func = vars.onDelComplete;
					if(func)	func.apply(null, vars.onDelCompleteParams);
					
					ExternalInterface.call("delComplete", id);
					
					return;
				}
			}
		}
		
		
		protected function allComplete($contents:Array, ...$args):void
		{
			var i:uint, l:uint = $contents.length, vars:*, id:*, d:DisplayObject, io:InteractiveObject, func:Function, index:uint = container.numChildren;
			
			for(; i<l; ++i)
			{
				vars = $contents[i];
				id = vars.id;
				d = vars.content;
				if(d)
				{
					io = d as InteractiveObject;
					if(io)
					{
						if(vars.hitTestDisable)	InteractiveObjectEx.setHitTestDisable(io, true);
						else	InteractiveObjectEx.setHitTestDisable(io, false);
					}
					
					if(vars.visible === false)	d.visible = false;
					if(vars.add !== false)
					{
						if(container.contains(d))	container.setChildIndex(d, index + i);
						else	container.addChild(d);
					}					
					else	if(container.contains(d))	container.removeChild(d);
					
					if(d && d.hasOwnProperty("init"))
					{
						func = d["init"];
						func();
					}
					
					ExternalInterface.call("addComplete", id);
				}
				else
				{
					ExternalInterface.call("addError", id);
				}
			}
			
			ExternalInterface.call("setSceneComplete", sceneID);
			
			startRun();
		}
		
		
		protected function startRun():void
		{
			var id:*, vars:*, d:DisplayObject, func:Function;
			
			for(id in dic)
			{
				vars = trashDic[id];
				d = vars.content;
				if(d)
				{
					if(d.hasOwnProperty("start"))
					{
						func = d["start"];
						d.addEventListener("startComplete", startComplete);
						func();
						
						vars.__isStarted__ = false;
					}
					else
					{
						container.removeChild(d);
						delete	trashDic[id];
						
						func = vars.onStartComplete;
						if(func)	func.apply(null, vars.onStartCompleteParams);
						
						vars.__isStarted__ = true;
					}
				}
				else
				{
					func = vars.onStartError;
					if(func)	func.apply(null, vars.onStartErrorParams);
					
					vars.__isStarted__ = true;
				}
			}
			
			_checkSceneStartComplete();
		}
		
		
		protected function startComplete($e:Event):void
		{
			var d:DisplayObject = $e.target as DisplayObject, id:*, vars:*, func:Function;
			
			for(id in dic)
			{
				vars = dic[id];
				if(d == vars.content)
				{
					d.removeEventListener("startComplete", startComplete);
					
					vars.__isStarted__ = true;
					
					func = vars.onStartComplete;
					if(func)	func.apply(null, vars.onStartCompleteParams);
					
					return;
				}
			}
			
			_checkSceneStartComplete();
		}
		
		
		protected function _checkSceneStartComplete():void
		{
			var id:*, vars:*;
			
			for(id in dic)
			{
				vars = dic[id];
				if(!vars.__isStarted__)	return;
			}
			
			ExternalInterface.call("startSceneComplete", sceneID);
		}
	}
}