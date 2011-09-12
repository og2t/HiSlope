/**
 * SmallKnob.as
 * Based on Knob.as by Keith Peters
 * 
 * A knob component for choosing a numerical value.
 * 
 * Copyright (c) 2010 Keith Peters
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
 
 package com.bit101.components
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.bit101.components.Knob;
	import com.bit101.components.Style;
	
	public class SmallKnob extends com.bit101.components.Knob
	{
		public static const ANGULAR:String = "angular";
		
		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this Knob.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 * @param label String containing the label for this component.
		 * @param defaultHandler The event handling function to handle the default event for this component (change in this case).
		 */
		public function SmallKnob(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number =  0, label:String = "", defaultHandler:Function = null)
		{
			super(parent, xpos, ypos, label, defaultHandler);
			mode = ANGULAR;
		}
		
		/**
		 * Draw the knob at the specified radius.
		 */
		override protected function drawKnob():void
		{
			_knob.graphics.clear();
			_knob.graphics.beginFill(Style.BACKGROUND);
			_knob.graphics.drawCircle(0, 0, _radius / 2);
			_knob.graphics.endFill();
			
			_knob.graphics.beginFill(Style.BUTTON_FACE);
			_knob.graphics.drawCircle(0, 0, _radius / 2 - 1);
			_knob.graphics.endFill();
			
			_knob.graphics.beginFill(Style.HANDLE_FACE);
			var s:Number = _radius / 2 * .1;
			_knob.graphics.drawRect(_radius / 2, -s, -s * 8, s * 2);
			_knob.graphics.endFill();
			
			updateKnob();
		}
		
		///////////////////////////////////
		// public methods
		///////////////////////////////////
		
		/**
		 * Draws the visual ui of the component.
		 */
		override public function draw():void
		{
			super.draw();

			_label.x = 0;
			_label.y = 0;

			_knob.x = _radius + _label.width - 5;
			_knob.y = _radius / 2;

			_valueLabel.x = _knob.x + _radius - 5;
			_valueLabel.y = 0;

			_width = _valueLabel.x + _valueLabel.width;
			_height = _radius * 2;
		}
		
		///////////////////////////////////
		// event handler
		///////////////////////////////////
		
		/**
		 * Internal handler for mouse move event. Updates value based on how far mouse has moved up or down.
		 */
		override protected function onMouseMoved(event:MouseEvent):void
		{
			super.onMouseMoved(event);
				
			if(_mode == ANGULAR)
			{
				var oldValue:Number = _value;
				var diffX:Number = _startX - mouseX;
				var diffY:Number = _startY - mouseY;
				var range:Number = _max - _min;
				var percent:Number = range / _mouseRange;
				_value += percent * (diffY - diffX);
				correctValue();
				if(_value != oldValue)
				{
					updateKnob();
					dispatchEvent(new Event(Event.CHANGE));
				}
				_startX = mouseX;
				_startY = mouseY;
			}
		}		
    }
}