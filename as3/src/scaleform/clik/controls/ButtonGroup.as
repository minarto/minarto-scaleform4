﻿/**
    The CLIK ButtonGroup component is used to manage sets of buttons. It allows one button in the set to be selected, and ensures that the rest are unselected. If the user selects another button in the set, then the currently selected button will be unselected. Any component that derives from the CLIK Button component such as CheckBox and RadioButton) can be assigned a ButtonGroup instance.
    
    <b>Inspectable Properties</b>
    The ButtonGroup does not have a visual representation on the Stage. Therefore no inspectable properties are available.
    
    <b>States</b>
    The ButtonGroup does not have a visual representation on the Stage. Therefore no states are associated with it.
    
    <b>Events</b>
    All event callbacks receive a single Event parameter that contains relevant information about the event. The following properties are common to all events. <ul>
    <li><i>type</i>: The event type.</li>
    <li><i>target</i>: The target that generated the event.</li></ul>
        
    The events generated by the Button component are listed below. The properties listed next to the event are provided in addition to the common properties.
    <ul>
        <li><i>ComponentEvent.SHOW</i>: The visible property has been set to true at runtime.</li>
        <li><i>ComponentEvent.HIDE</i>: The visible property has been set to false at runtime.</li>
        <li><i>Event.CHANGE</i>: The selected button of the ButtonGroup has changed.</li>
        <li><i>ButtonEvent.BUTTON_CLICK</i>: A button in the group has been clicked.</li>
    </ul>
 */

/**************************************************************************

Filename    :   ButtonGroup.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.controls {
    
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;
    import flash.utils.Dictionary;
    
    import scaleform.clik.controls.Button;
    import scaleform.clik.events.ButtonEvent;
    
    [Event(name="click", type="flash.events.MouseEvent")]
    [Event(name="change", type="flash.events.Event")]
    
    public class ButtonGroup extends EventDispatcher {
    
    // Constants:
        public static var groups:Dictionary = new Dictionary(true);
        public static function getGroup(name:String, scope:DisplayObjectContainer):ButtonGroup {
            var list:Object = groups[scope];
            if (list == null) { list = groups[scope] = new Object(); }
            var group:ButtonGroup = list[name.toLowerCase()];
            if (group == null) { group = list[name.toLowerCase()] = new ButtonGroup(name, scope); }
            return group;
        }
        
        //LM: No clean up implemented.
        
    // Public Properties:
        /**
         * The name of the ButtonGroup, specified by the {@code groupName} property on the subscribing Buttons.
         * @see Button#groupName
         */
        public var name:String;
        /** The MovieClip container in which this ButtonGroup belongs. */
        protected var weakScope:Dictionary;
        /** The current Button that is selected. Only a single Button can be selected at one time. */
        public var selectedButton:Button;
        
    // Protected Properties:
        protected var _children:Array;
        
    // Initialization:
        public function ButtonGroup(name:String, scope:DisplayObjectContainer) {
            this.name = name;
            
            // We do this to avoid creating a strong reference to the scope. A strong reference
            // may interfere with unloading content. A Dictionary is used to provide weak reference
            // support.
            this.weakScope = new Dictionary(true);
            this.weakScope[scope] = null;

            _children = [];
        }

    // Public getter / setters:
        /**
         * The number of buttons in the group.
         */
        public function get length():uint { return _children.length; }
        /**
         * The data for the selected Button.
         */
        public function get data():Object { return selectedButton.data; }
        /**
         * The index of the Button in the ButtonGroup's children array.
         */
        public function get selectedIndex():int { 
            return _children.indexOf(selectedButton); 
        }
        
        public function get scope():DisplayObjectContainer {
            var doc:DisplayObjectContainer = null;
            for (var a:* in scope) {
                doc = a as DisplayObjectContainer;
                break;
            }
            return doc;
        }
        
    // Public Methods:
        /**
         * Add a Button to group.  A Button can only be added once to a ButtonGroup, and can only exist in
         * a single group at a time. Buttons will change the selection of a ButtonGroup by dispatching "select"
         * and "click" events.
         * @param button The Button instance to add to this group
         */
        public function addButton(button:Button):void {
            removeButton(button);
            _children.push(button);
            
            if (button.selected) {
                updateSelectedButton(button, true);
            }
            
            button.addEventListener(Event.SELECT, handleSelect, false, 0, true);
            button.addEventListener(ButtonEvent.CLICK, handleClick, false, 0, true);
            button.addEventListener(Event.REMOVED, handleRemoved, false, 0, true);
        }

        /**
         * Remove a button from the group. If it the last button in the group, the button should clean up
         * and destroy the ButtonGroup.
         * @param button The Button instance to be removed from group.
         */
        public function removeButton(button:Button):void {
            var index:int = _children.indexOf(button);
            if (index == -1) { return; }
            
            _children.splice(index, 1);
            
            button.removeEventListener(Event.SELECT, handleSelect, false);
            button.removeEventListener(ButtonEvent.CLICK, handleClick, false);
        }
        
        /**
         * Find a button at a specified index in the ButtonGroup. Buttons are indexed in the order that they are added.
         * @param index Index in the ButtonGroup of the Button.
         * @returns The button at the specified index. null if there is no button at that index.
         */
        public function getButtonAt( index:int ):Button { return _children[index] as Button; }
        
        public function setSelectedButtonByIndex( index:uint, selected:Boolean = true ):Boolean {
            var success:Boolean = false;
            var btn:Button = _children[index] as Button;
            if (btn != null) {
                btn.selected = selected;
                success = true;
            }
            return success;
        }

        /**
         * Sets the specified button to the {@code selectedButton}. The selected property of the previous selected
         * Button will be set to {@code false}. If {@code null} is passed to this method, the current selected Button
         * will be deselected, and the {@code selectedButton} property set to {@code null}.
         * @param button The button instance to select.
         * @see #selectedButton
         */
        protected function updateSelectedButton(button:Button, selected:Boolean = true):void {
            if (selected && button == selectedButton) { return; }
            
            // Determine if this is just a "turn off currently selected" action.
            var turnOffOnly:Boolean = (!selected && button == selectedButton && button.allowDeselect);
            
            // Set the selectedButton early, because subsquent deselection of the current button will fire this method
            // again.
            var oldButton:Button = selectedButton;
            if (selected) { selectedButton = button; }

            if (selected && oldButton != null) {
                oldButton.selected = false;
            }
            
            if (turnOffOnly) {
                selectedButton = null;
            } else if (!selected) {
                return;
            }
        
            dispatchEvent(new Event(Event.CHANGE));
        }
        
        /** Returns true if the Button provided is part of the ButtonGroup. */
        public function hasButton(button:Button):Boolean {
            return _children.indexOf(button) > -1;
        }
        
        /** @exclude */
        override public function toString():String {
            return "[CLIK ButtonGroup " + name + " (" + _children.length + ")]";
        }
        
    // Protected Methods:
        /**
         * The "selected" state of one of the buttons in the group has changed. If the button is selected,
         * it will become the new {@code selectedButton}. If it is not, the selectedButton in the group will be
         * set to {@code null}.
         */
        protected function handleSelect(event:Event):void {
            var button:Button = event.target as Button;
            if (button.selected) {
                updateSelectedButton(button, true);
            } else {
                updateSelectedButton(button, false);
            }
        }
        
        /**
         * A button in the group has been clicked. The button will be set to the {@code selectedButton}.
         */
        protected function handleClick(event:ButtonEvent):void {
            dispatchEvent(event);
        }
        
        protected function handleRemoved(event:Event):void {
            removeButton(event.target as Button);
        }
    }

}
