/*---------------------------------------------------------------------------------------------

	[AS3] BitmapUtils
	=======================================================================================

	VERSION HISTORY:
	v0.1	Born on 2008/8/13

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package net.blog2t.util
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////
	
	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import com.gskinner.geom.ColorMatrix;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class BitmapUtils
	{		
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		public static const point:Point = new Point();

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private static var rl:Number = 0.3086;
		private static var gl:Number = 0.6094;
		private static var bl:Number = 0.0820;
		
		/**
		 * Desaturate bitmap
		 * 
		 * @param	targetBmpData
		 */
		public static function desaturate(targetBmpData:BitmapData):void
		{
			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustColor(0, 0, -100, 0);
			var colorMatrixFilter:ColorMatrixFilter = new ColorMatrixFilter(colorMatrix);
			targetBmpData.applyFilter(targetBmpData, targetBmpData.rect, point, colorMatrixFilter);
		}

		/**
		 * Desaturate bitmap with given matrix
		 * 
		 * @param	targetBmpData
		 */
		public static function colorMatrixFilter(targetBmpData:BitmapData, colorMatrixFilter:ColorMatrixFilter):void
		{
			targetBmpData.applyFilter(targetBmpData, targetBmpData.rect, point, colorMatrixFilter);
		}


		/**
		 * Desaturate color by rgb weights
		 */
		public static function desaturateWeighted(targetBmpData:BitmapData, rl:Number = 0.3086, gl:Number = 0.6094, bl:Number = 0.0820):void
		{
			targetBmpData.applyFilter(targetBmpData, targetBmpData.rect, point, new ColorMatrixFilter(
				[rl, gl, bl, 0, 0,
				 rl, gl, bl, 0, 0,
				 rl, gl, bl, 0, 0,
				 0,  0,  0,  1, 0]
			));
		}
		

		/**
		 * Adjust brightness and constrast of bitmap 
		 * 
		 * @param	sourceBmpData
		 * @param	targetBmpData
		 * @param	brightness
		 * @param	contrast
		 */
		public static function brightnessContrast(sourceBmpData:BitmapData, targetBmpData:BitmapData, brightness:int = 0, contrast:int = 0):void
		{
			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustColor(brightness, contrast, 0, 0);
			var colorMatrixFilter:ColorMatrixFilter = new ColorMatrixFilter(colorMatrix);
			targetBmpData.applyFilter(sourceBmpData, targetBmpData.rect, point, colorMatrixFilter);
		}
		
		
		/**
		 * Fill bitmap with a given ARGB colour
		 * 
		 * @param	targetBmpData
		 * @param	fillColor
		 */
		public static function fill(targetBmpData:BitmapData, fillColor:uint):void
		{
			targetBmpData.fillRect(new Rectangle(0, 0, targetBmpData.width, targetBmpData.height), fillColor);
		}


		/**
		 * Blur bitmap
		 * 
		 * @param	targetBmpData
		 * @param	blur
		 */
		public static function blur(targetBmpData:*, blur:int = 0, quality:int = 2):void
		{
			targetBmpData.applyFilter(targetBmpData, targetBmpData.rect, point, new BlurFilter(blur, blur, quality));
		}
		
		
		/**
		 * Perform threshold operation to get 1-bit bitmap
		 * 
		 * @param	sourceBmpData
		 * @param	targetBmpData
		 * @param	value
		 */
		public static function cutOff(sourceBmpData:BitmapData, targetBmpData:BitmapData, value:int, foregroundColor:uint, backgroundColor:uint):void
		{			
			fill(targetBmpData, foregroundColor);
	
			var thresholdValue:uint = 0xff000000 | value << 16 | value << 8 | value;
			var mask:uint = 0x00ffffff;
	
			targetBmpData.threshold(sourceBmpData, targetBmpData.rect, point, "<=", thresholdValue, backgroundColor, mask, false);
		}

		public static function copy(sourceBmpData:BitmapData, targetBmpData:BitmapData):void
		{
			targetBmpData.lock();
			targetBmpData.copyPixels(sourceBmpData, sourceBmpData.rect, sourceBmpData.rect.topLeft);
			targetBmpData.unlock();
		}

		public static function scale(sourceBmpData:BitmapData, targetBmpData:BitmapData, scale:Number = 1.0, smoothing:Boolean = true):void
		{
			targetBmpData.draw(sourceBmpData, new Matrix(scale, 0, 0, scale), null, "normal", null, smoothing);
		}
	}
}