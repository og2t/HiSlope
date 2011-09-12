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
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import jungbenj.utils.math.MathUtils;
	
	public class BitmapDataUtils 
	{
		
		static public function getBitmapData(target:DisplayObject, transparent:Boolean = true, scale:Number = 1):BitmapData
		{
			var output:BitmapData = new BitmapData(target.width, target.height, transparent, 0x00000000);
			var oBounds:Rectangle = target.getBounds(target);
			output.draw(target, new Matrix(scale, 0, 0, scale, -oBounds.x, -oBounds.y), null, null, null, true);
			return output;
		}
		
		static public function crop(src:BitmapData, rect:Rectangle, output:BitmapData = null):BitmapData
		{
			if(!output) output = new BitmapData(rect.width, rect.height, src.transparent);
			output.copyPixels(src, rect, new Point());
			return output;
		}
		
		static public function diffBmp(bmp1:BitmapData, bmp2:BitmapData):BitmapData
		{
			var output:BitmapData = bmp1.clone();
			output.draw(bmp2, new Matrix(), null, BlendMode.DIFFERENCE);
			return output;
		}
		
		static public function convertToGrayscale(src:BitmapData):BitmapData
		{
			var p:Number = 1 / 3;
			/*var kernel:Array = [	0, 0, 0, 0, 0,
									0, 0, 0, 0, 0,
									p, p, p, 0, 0,
									0, 0, 0, 1, 0 ];*/
			
			var r:Number=0.212671;
			var g:Number=0.715160;
			var b:Number=0.072169;	
			var kernel:Array = [	r, g, b, 0, 0,
									r, g, b, 0, 0,
									r, g, b, 0, 0,
									0, 0, 0, 1, 0 ];
			var cf:ColorMatrixFilter = new ColorMatrixFilter(kernel);
			var output:BitmapData = new BitmapData(src.width, src.height, src.transparent, 0x00000000);
			output.applyFilter(src, src.rect, new Point(), cf);
			return output;
		}
		
		static public function applyConvFilter(src:BitmapData, cf:ConvolutionFilter):BitmapData
		{
			var output:BitmapData = new BitmapData(src.width, src.height, src.transparent, 0x00000000);
			output.applyFilter(src, src.rect, new Point(), cf);
			return output;
		}
		

		static public function getColors(src:BitmapData, area:Rectangle = null):Array
		{
			if (area == null) area = src.rect;
			var	x:int = Math.max(area.x, 0);
			var y:int = Math.max(area.y, 0);
			var w:int = Math.min(x + area.width, src.width);
			var h:int =  Math.min(y + area.height, src.height);
			var data:Array = []; 
			var color: int;
			var m:Boolean = true;
			while (true)
			{
				color = src.getPixel(m ? x++ : --x, y);
				if (x == w || x == 0)
				{
					if (y++ == h)
					break;
					m = !m;
				}
				//trace(x + " " + y);
				data.push(color);
			}
			
			return data;
		}
		
		static public function getBrightness(rgb:int):int 
		{
			var r:int = (rgb >> 16) & 0xFF;
			var g:int = (rgb >> 8) & 0xFF;
			var b:int = rgb & 0xFF;
			return int(0.299 * r + 0.587 * g + 0.114 * b);
		}
		
		static public function mixPixel(p1:int, p2:int):int
		{
			var r:int = ((p1 >> 16 & 0xFF) | (p2 >> 16 & 0xFF)) >> 1;
			var g:int = ((p1 >> 8 & 0xFF) | (p2 >> 8 && 0xFF)) >> 1;
			var b:int = ((p1 & 0xFF) | (p2 && 0xFF)) >> 1;
			
			return r << 16 | g << 8 | b;
		}
		
		static public function getRGB(col:int):Array
		{
			var r:int = (col >> 16 & 0xFF);
			var g:int = (col >> 8 & 0xFF);
			var b:int = (col & 0xFF);
			
			return [r, g, b];
		}
		
		static public function getPixelsDiff(col1:int, col2:int):int
		{
			var rgb1:Array = getRGB(col1);
			var rgb2:Array = getRGB(col2);
			var diffR:int = rgb1[0] - rgb2[0];
			var diffG:int = rgb1[1] - rgb2[1];
			var diffB:int = rgb1[2] - rgb2[2];
			
			return Math.sqrt( diffR * diffR +diffG * diffG + diffB * diffB);
		}
		
	}
	
}