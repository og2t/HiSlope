/**
 * ColorChooser.as
 * Keith Peters
 * version 0.96
 *
 * version 0.96.1 by Tomek 'Og2t' Augustyn [http://play.blog2t.net]
 * 9/7/2009 Added label and live color sampling
 * 
 * A bare bones Color Chooser component, allowing for textual input only.
 * 
 * Copyright (c) 2008 Keith Peters
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
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.InterpolationMethod;
	import flash.display.SpreadMethod;

	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Matrix;
	
	public class ColorChooser extends Component
	{		
		protected var _label:Label;
		private var _labelText:String;
		private var _input:InputText;
		private var _swatch:Sprite;
		private var _value:uint = 0xff0000;
		private var _sampledPixel:BitmapData;
		private var _offset:Matrix;
		private var _localPoint:Point;
		private var _model:DisplayObject;
		private var _defaultModelColors:Array=[0xFF0000, 0xFFFF00, 0x00FF00, 0x00FFFF, 0x0000FF, 0xFF00FF, 0xFF0000,0xFFFFFF,0x000000];
		private var _colors:BitmapData;
		private var _colorsContainer:Sprite;
		
		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this ColorChooser.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 * @param value The initial color value of this component.
		 * @param defaultHandler The event handling function to handle the default event for this component (change in this case).
		 */
		public function ColorChooser(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number =  0, label:String = "", defaultHandler:Function = null)
		{
			_labelText = label;
			super(parent, xpos, ypos);
			if(defaultHandler != null)
			{
				addEventListener(Event.CHANGE, defaultHandler);
			}
		}
		
		
		/**
		 * Initializes the component.
		 */
		override protected function init():void
		{
			super.init();

			_width = 65;
			_height = 15;
			_sampledPixel = new BitmapData(1, 1, false, 0x0);
			_offset = new Matrix();
			value = _value;
		}
		
		override protected function addChildren():void
		{
			_input = new InputText();
			_input.width = 45;
			_input.restrict = "[0-9][a-f][A-F]";
			_input.maxChars = 6;
			addChild(_input);
			_input.addEventListener(Event.CHANGE, onChange);
		
			_swatch = new Sprite();
			_swatch.filters = [getShadow(2, true)];
			addChild(_swatch);
			_swatch.addEventListener(MouseEvent.CLICK, onSwatchClick);
			
			_colorsContainer = new Sprite();
			//_colorsContainer.addEventListener(Event.ADDED_TO_STAGE, onColorsAddedToStage);
			//_colorsContainer.addEventListener(Event.REMOVED_FROM_STAGE, onColorsRemovedFromStage);
			_model = getDefaultModel();
			drawColors(_model);
			
			_label = new Label(this, 0, 0);
		}
		
		/**
		 * Centers the label when label text is changed.
		 */
		protected function positionLabel():void
		{
			_input.x = _label.width + _label.x + 5;
			_swatch.x = _input.x + 50;
		}
		
		/**
		 *	Sample the color of a DisplayObject with a globalPoint offset.
		 *	Skip the component itself and when it's not IBitmapDrawable. 
		 */
		protected function sampleColor(displayObject:Object, globalPoint:Point):void
		{
			if (displayObject == this || !(displayObject is IBitmapDrawable)) return;

			_localPoint = displayObject.globalToLocal(globalPoint);

			if (displayObject is Bitmap)
			{				
				value = displayObject.bitmapData.getPixel(_localPoint.x, _localPoint.y);
			} else {
				_offset.identity();
				_offset.translate(-_localPoint.x, -_localPoint.y);
				_sampledPixel.draw(displayObject as IBitmapDrawable, _offset);
				value = _sampledPixel.getPixel(0, 0);
			}
		}
		
		private function drawColors(d:DisplayObject):void
		{
			_colors = new BitmapData(d.width, d.height);
			_colors.draw(d);
			while (_colorsContainer.numChildren) _colorsContainer.removeChildAt(0);
			_colorsContainer.addChild(new Bitmap(_colors));
			placeColors();
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
			_swatch.graphics.clear();
			_swatch.graphics.beginFill(_value);
			_swatch.graphics.drawRect(0, 0, 16, 16);
			_swatch.graphics.endFill();
			
			_label.text = _labelText;
			_label.draw();
			
			positionLabel();
		}		
		
		///////////////////////////////////
		// event handlers
		///////////////////////////////////
		
		/**
		 * Internal change handler.
		 * @param event The Event passed by the system.
		 */
		protected function onChange(event:Event):void
		{
			event.stopImmediatePropagation();
			_value = parseInt("0x" + _input.text, 16);
			_input.text = _input.text.toUpperCase();
			invalidate();
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 *	When swatch is clicked, listen for stage mouse down and start sampling the color.
		 */
		protected function onSwatchClick(event:MouseEvent):void
		{
			_swatch.removeEventListener(MouseEvent.CLICK, onSwatchClick);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseSample);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			
			displayColors();
		}
			
		/**
		 *	Get the last object under mouse and try sampling it's color.
		 */
		protected function onMouseSample(event:MouseEvent):void
		{
			var globalPoint:Point = new Point(event.stageX, event.stageY);
			var objects:Array = stage.getObjectsUnderPoint(globalPoint);
			sampleColor(objects[objects.length - 1], globalPoint);
			dispatchEvent(new Event(Event.CHANGE));
		}
				
		/**
		 *	Sampling color done. Revert all events to their default stage.
		 */
		protected function onStageMouseDown(event:MouseEvent):void
		{
			_swatch.addEventListener(MouseEvent.CLICK, onSwatchClick);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseSample);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			displayColors();
		}
		
		/**
		 * The color picker mode Display functions
		 */
		
		private function displayColors():void 
		{
			if (_colorsContainer.parent) _colorsContainer.parent.removeChild(_colorsContainer);
			else {
				_swatch.addChild(_colorsContainer);
				_colorsContainer.y = -84;
			}
		}		
		
		private function placeColors():void
		{
			_colorsContainer.x = 20;
			_colorsContainer.y = _swatch.y;
		}
		
		/**
		 * Create the default gradient Model
		 */

		private function getDefaultModel():Sprite
		{	
			var w:Number = 100;
			var h:Number = 100;
			var bmd:BitmapData = new BitmapData(w, h);
			
			var g1:Sprite = getGradientSprite(w, h, _defaultModelColors);
			bmd.draw(g1);
					
			var blendmodes:Array = [BlendMode.MULTIPLY,BlendMode.ADD];
			var nb:int = blendmodes.length;
			var g2:Sprite = getGradientSprite(h/nb, w, [0xFFFFFF, 0x000000]);		
			
			for (var i:int = 0; i < nb; i++) {
				var blendmode:String = blendmodes[i];
				var m:Matrix = new Matrix();
				m.rotate(-Math.PI / 2);
				m.translate(0, h / nb * i + h/nb);
				bmd.draw(g2, m, null, blendmode);
			}
			
			var s:Sprite = new Sprite();
			var bm:Bitmap = new Bitmap(bmd);
			s.addChild(bm);
			return(s);
		}
		
		private function getGradientSprite(w:Number, h:Number, ca:Array):Sprite 
		{
			var gc:Array = ca;
			var gs:Sprite = new Sprite();
			var g:Graphics = gs.graphics;
			var gn:int = gc.length;
			var ga:Array = [];
			var gr:Array = [];
			var gm:Matrix = new Matrix(); gm.createGradientBox(w, h, 0, 0, 0);
			for (var i:int = 0; i < gn; i++) { ga.push(1); gr.push(0x00 + 0xFF / (gn - 1) * i); }
			g.beginGradientFill(GradientType.LINEAR, gc, ga, gr, gm, SpreadMethod.PAD,InterpolationMethod.RGB);
			g.drawRect(0, 0, w, h);
			g.endFill();	
			return(gs);
		}
		
		///////////////////////////////////
		// getter/setters
		///////////////////////////////////
		
		/**
		 * Gets / sets the color value of this ColorChooser.
		 */
		public function set value(n:uint):void
		{
			var str:String = n.toString(16).toUpperCase();
			while(str.length < 6)
			{
				str = "0" + str;
			}
			_input.text = str;
			_value = parseInt("0x" + _input.text, 16);
			invalidate();
		}
		public function get value():uint
		{
			return _value;
		}
		
		/**
		 * Gets / sets the text shown in this component's label.
		 */
		public function set label(str:String):void
		{
			_labelText = str;
//			invalidate();
			draw();
		}
		public function get label():String
		{
			return _labelText;
		}
	}
}