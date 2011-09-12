/**
 * HBarSlider.as
 * based on Minimal Components by Keith Peters
 * 
 * A progress bar component for showing a changing value in relation to a total.
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
	import com.bit101.components.ProgressBar;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import com.bit101.components.Style;
	
	public class HBarSlider extends ProgressBar
	{
		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this ProgressBar.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 */
		public function HBarSlider(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, defaultEventHandler:Function = null)
		{
			super(parent, xpos, ypos);
			if (defaultEventHandler != null) addEventListener(Event.CHANGE, defaultEventHandler);
		}
		
		
		/**
		 * Creates and adds the child display objects of this component.
		 */
		override protected function addChildren():void
		{
			super.addChildren();
			_back.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			_back.buttonMode = true;
			_back.useHandCursor = true;
			_bar.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			_bar.buttonMode = true;
			_bar.useHandCursor = true;
		}
		
		
		/**
		 * Convenience method to set the three main parameters in one shot.
		 * @param min The minimum value of the slider.
		 * @param max The maximum value of the slider.
		 * @param value The value of the slider.
		 */
		public function setSliderParams(min:Number, max:Number, value:Number):void
		{
			this.minimum = min;
			this.maximum = max;
			this.value = value;
		}
		
		
		/**
		 * Updates the size of the progress bar based on the current value.
		 */
		override protected function update():void
		{
			_bar.scaleX = (_value - _min) / (_max - _min);
		}
		
		
		/**
		 * Internal mouseDown handler.
		 * @param event The MouseEvent passed by the system.
		 */
		protected function onDown(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onSliderChange);
			onSliderChange(event);
		}

		
		/**
		 * Internal mouseUp handler. 
		 * @param event The MouseEvent passed by the system.
		 */
		protected function onUp(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onSliderChange);
		}

		
		/**
		 * Internal mouseMove handler for when the slider is clicked or moved.
		 * @param event The MouseEvent passed by the system.
		 */
		protected function onSliderChange(event:MouseEvent):void
		{
			value = Math.max(_min, mouseX / (width - 2) * (_max - _min) + _min);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		
		/**
		 * Gets / sets the tick value of this slider. This round the value to the nearest multiple of this number. 
		 */
		public function set tick(t:Number):void
		{
			_tick = t;
		}
		public function get tick():Number
		{
			return _tick;
		}
	}
}