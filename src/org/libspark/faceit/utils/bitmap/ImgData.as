/* 
 * PROJECT: FaceIt
 * --------------------------------------------------------------------------------
 * This work is based on the Camshift algorithm introduced and developed by Gary Bradski for the openCv library.
 * http://isa.umh.es/pfc/rmvision/opencvdocs/papers/camshift.pdf
 *
 * FaceIt is ActionScript 3.0 library to track color object using the camshift algorithm.
 * Copyright (C)2009 Benjamin Jung
 *
 * 
 * Licensed under the MIT License
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
 * 
 * For further information please contact.
 *	<jungbenj(at)gmail.com>
 * 
 * 
 * 
 */

package org.libspark.faceit.utils.bitmap
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class ImgData
	{	
		public var width:int;
		public var height:int;
		
		private var aPixels:Array;
		
		public function ImgData(w:int, h:int, aPixels:Array) 
		{
			width = w;
			height = h;
			this.aPixels = aPixels.slice();
		}
		
		public static function createFromBmp(src:BitmapData, area:Rectangle = null):ImgData
		{
			var aPixels:Array = []; 
			var x:int;
			var y:int;
			var h:int;
			var w:int;
			var i:int;
			var j:int;
			var a:Array;
			if (area != null)
			{
				x = area.x;
				y = area.y;
				w = area.width;
				h = area.height;
			}
			else
			{
				x = 0;
				y = 0;
				w = src.width;
				h = src.height;
			}
			for (i = x; i < x + w; ++i)
			{
				a = [];
				for (j = y; j < y + h; ++j) a.push(src.getPixel(i, j));
				aPixels.push(a);
			}
			return new ImgData(w, h, aPixels);
		}
		
		public static function createFromArray(a:Array):ImgData
		{
			var w:int = a.length;
			var h:int = a[0].length;
			return new ImgData(w, h, a);
		}

		public function getPixel(i:int, j:int):int
		{
			return aPixels[i][j];
		}
		
		public function getPixels():Array
		{
			return aPixels.slice();
		}
		
		public function getPart(area:Rectangle):ImgData
		{
			//trace("get part " + area);
			var a:Array = [];
			var x:Number = Math.max(area.x, 0);
			var y:Number = Math.max(area.y, 0);
			var w:Number = Math.min(x + area.width, width);
			var h:Number =  Math.min(y + area.height, height);
			var i:int;
			var j:int;
			var row:Array;
			for (i = x; i < w; ++i)
			{
				row = [];
				for (j = y; j < h; ++j) row.push(aPixels[i][j]);
				a.push(row);
			}
			return createFromArray(a);
		}
		
		public function toBimapdata():BitmapData
		{
			var i:int;
			var j:int;
			var bmp:BitmapData = new BitmapData(width, height, true);
			bmp.lock();
			for (i = 0; i < width; ++i)
			{
				for (j = 0; j < height; ++j) bmp.setPixel(i, j, aPixels[i][j]);
			}
			bmp.unlock();
			return bmp;
		}
		
	}
}
