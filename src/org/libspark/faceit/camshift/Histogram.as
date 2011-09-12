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

package org.libspark.faceit.camshift
{
	import org.libspark.faceit.utils.bitmap.ImgData;
	
	public class Histogram 
	{
		public static var SIZE:Number = 0x10000 / 16;
		
		private var aBins:Vector.<uint>;
		
		public function Histogram(img:ImgData)
		{
			createBins(img);
		}
		
		public function getBin(index:Number):Number 
		{
			return aBins[index];
		}
		
		private function createBins(img:ImgData):void
		{
			aBins = new Vector.<uint>();
			
			var i:uint;
			
			var x:uint;
			var y:uint;
			var pixel:uint;
			
			var r:uint;
			var g:uint;
			var b:uint;
			
			// init bins
			for (i = 0; i < SIZE; ++i) aBins[i] = 0;
			
			for (y = 0; y < img.height; ++y)
			{
				for (x = 0; x < img.width; ++x)
				{
					pixel = img.getPixel(x, y);
					
					r = (pixel >> 16 & 0xFF) >> 4;
					g = (pixel >> 8 & 0xFF) >> 4;
					b = (pixel & 0xFF) >> 4;
					
					aBins[256 * r + 16 * g + b] += 1;	
				}
			}
		}
	}
	
}
