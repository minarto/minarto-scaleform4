/**
 * The EventDispatcher manages the notification mechanism used throughout the components. EventDispatcher can be inherited from, or mixed in to add notification capabilities to a class.  The Scaleform EventDispatcher mirrors the API in the Macromedia AS2 EventDispatcher, and the common methods found in the AS3 EventDispatcher, but also includes some enhancements, such as the {@link #removeAllEventListeners()} method.
 */

/**************************************************************************

Filename    :   EventDispatcher.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

class gfx.events.EventDispatcher {
	/**
	 * Initialize a component or class, adding Event Dispatching capabilities to it.
	 */
	public static function initialize(target):Void {
		var listeners = { };
		
		target.addEventListener = function($type:String, $scope, $callBack:String) {
			var a:Array = listeners[$type], i, arg:Array;
		
			for (i in a) {
				arg = a[i];
				if (arg[1] == $scope && arg[2] == $callBack)	return;
			}
			
			if (!a) listeners[$type] = a = [];
			a.push(arguments);
		}
		
		
		target.dispatchEvent = function($e):Void {
			var a:Array = listeners[$e.type], i:Number, l:Number = a ? a.length : 0, arg:Array;
			
			if(!$e.target)	$e.target = this;
			
			for (i = 0; i < l; ++ i) {
				arg = a[i];
				arg[1][arg[2]]($e);
			}
		}
		
		
		target.hasEventListener = function($type:String):Boolean {
			return listeners[$type];
		}
		
		
		target.removeEventListener = function($type:String, $scope, $callBack:String):Void {
			var a:Array = listeners[$type], i, arg:Array;
			
			for (i in a) {
				arg = a[i];
				if (arg[1] == $scope && arg[2] == $callBack) {
					a.splice(i, 1);
					if (!a.length) delete	listeners[$type];
					return;
				}
			}
		}
		
		
		target.removeAllEventListeners = function($type:String):Void {
			if ($type) delete listeners[$type];
			else listeners = { };
		}
	}
	
	
	public function EventDispatcher() {
		initialize(this);
	}
	
	
//Public Methods:	
	/**
	 * Subscribe a listener to an event.
	 * @param event The type of event.
	 * @param scope The scope of the listener.
	 * @param callBack The function name to call on the listener.
	 */
	public function addEventListener($type:String, $scope, $callBack):Void {
	}
	
	
	/**
	 * Unsubscribe a listener from an event.
	 * @param event The type of event.
	 * @param scope The scope of the listener.
	 * @param callBack The function name to call on the listener.
	 */
	public function removeEventListener($type:String, $scope, $callBack):Void {
	}
	
	
	/**
	 * Dispatch an event to all listeners.
	 * @param event The event object to dispatch to the listeners.
	 */
	public function dispatchEvent($e):Void {
	}
	
	/**
	 * Check if a listener has been added for a specific event type.
	 * @param event The event type
	 * @param scope The scope of the listener.
	 * @param callBack The function name to call on the listener.
	 * @return If the component has a specific listener
	 */
	public function hasEventListener($type:String):Boolean {
		return	0;
	}
	
	/**
	 * Unsubscribe all listeners from a specific event, or all events.
	 * @param event The type of event.
	 */
	public function removeAllEventListeners($type:String):Void {
	}
}