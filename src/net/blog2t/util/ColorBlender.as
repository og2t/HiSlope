/*---------------------------------------------------------------------------------------------

	[AS3] ColorBlender
	=======================================================================================

	(c) 2010 Tomek 'Og2t' Augustyn
	http://play.blog2t.net/

	You are free to use this source code in any project. 
	You are free to modify this source code in anyway you see fit.
	You are free to distribute this source code.

	You may NOT charge anything for this source code.
	This notice and the copyright information must be left intact in any distribution of this source code. 
	You are encouraged to release any improvements back to the ActionScript community.

	VERSION HISTORY:
	v0.1	Born on 2008/10/16

	USAGE:

	TODOs:

	DEV IDEAS:

	- addColorAt() and delColorAt() methods
	- setRatioAt() and getRatioAt() methods
	- setAlphaAt() and getAlphaAt() methods

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package net.blog2t.util
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.display.Shape;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class ColorBlender
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		private var gradient:Shape = new Shape();
		private var gradientBitmapData:BitmapData;
		
		private var alphaColors:Boolean;
		
		private var _ratios:Array;
		private var _alphas:Array;
		private var _colors:Array;
		private var _gradientColors:Array;
		
		private var numColors:int;

		private var _range:int
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function ColorBlender(alphaColors:Boolean = false)
		{
			this.alphaColors = alphaColors;
		}
				
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		
		public function mix(passedColors:Array, range:int = 0, passedRatios:Array = null):void
		{
			numColors = passedColors.length;
			
			if (range == 0)
			{
				_range = numColors;
			} else {
				_range = range;
			}
			
			if (!prepareColors(passedColors)) return;
			
			prepareAlphas();
			prepareRatios(passedRatios);
			
			createBlend();
		}
	
		public function getColorAt(_range:int):uint
		{
			if (alphaColors) return gradientBitmapData.getPixel32(_range, 0);
			return gradientBitmapData.getPixel(_range, 0);
		}
	
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////

		/**
		 *	Check if range is wide enough 
		 */
		private function prepareColors(passedColors:Array):Boolean
		{
			if (_range < numColors)
			{
				throw new Error("Error: min blend range is: " + numColors);
				return false;
			}
			
			_colors = passedColors;
			
			return true;
		}
		
		/**
		 *	If alphaColors are enabled, extract alpha value, and trim _colors
		 */
		private function prepareAlphas():void
		{
			_alphas = [];
		
			for (var i:int = 0; i < numColors; i++)
			{
				if (!alphaColors)
				{
					_alphas.push(1);
				} else {
					_alphas.push((_colors[i] >> 24 & 0xff) / 0xff);
					_colors[i] &= 0x00ffffff;
				}
			}
		}
		
		/**
		 *	If _ratios aren't passed or wrong number of _ratios spread evenly
		 */
		private function prepareRatios(passedRatios:Array):void
		{
			if (passedRatios && passedRatios.length == numColors)
			{
				_ratios = passedRatios;
			} else {
				_ratios = [];

				var _ratiostep:Number = 1 / (numColors - 1);
				var _ratiostepper:Number = 0;
				
				for (var i:int = 0; i < numColors; i++)
				{
					_ratios.push(Math.ceil(_ratiostepper * 255));
					_ratiostepper += _ratiostep;
				}
			}
		}
		
		/**
		 *	Create gradient and draw it on BitmapData for future reference
		 */
		private function createBlend():void
		{	
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(_range, 1);
		
			var gradient:Shape = new Shape();
			gradient.graphics.beginGradientFill(GradientType.LINEAR, _colors, _alphas, _ratios, matrix);  
			gradient.graphics.drawRect(0, 0, _range, 1);

			gradientBitmapData = new BitmapData(_range, 1, alphaColors);
			gradientBitmapData.fillRect(new Rectangle(0, 0, _range, 1), 0x00000000)
			gradientBitmapData.draw(gradient);
			
			_gradientColors = [];
			
			for (var i:int = 0; i < _range; i++)
			{
				_gradientColors.push(getColorAt(i));
			}
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////

		public function get gradientBitmap():Bitmap
		{
			return new Bitmap(gradientBitmapData);
		}
		
		public function get gradientColors():Array
		{
			return _gradientColors;
		}

		public function get colors():Array
		{
			return _colors;
		}

		public function get alphas():Array
		{
			return _alphas;
		}
		
		public function get ratios():Array
		{
			return _ratios;
		}
		
		public function set ratios(value:Array):void
		{
			prepareRatios(value);
			createBlend();
		}
		
		public function set alphas(value:Array):void
		{
			if (value.length == numColors)
			{
				_alphas = value;
			} else {
				throw new Error("Error: Alpha array length doesn't match with the colors array.");
			}
			
			createBlend();
		}
		
		public function set colors(value:Array):void
		{
			prepareColors(value);
			createBlend();
		}

		// HELPERS ////////////////////////////////////////////////////////////////////////////
		// PROTOTYPES /////////////////////////////////////////////////////////////////////////

	}
	// END OF CLASS ///////////////////////////////////////////////////////////////////////////
}