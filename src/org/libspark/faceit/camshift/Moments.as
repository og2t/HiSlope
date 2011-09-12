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
	
	public class Moments
	{
		
		public var m00:Number;
		public var m10:Number;
		public var m01:Number;
		public var m11:Number;
		public var m20:Number;
		public var m02:Number;
		public var mu00:Number;
		public var mu10:Number;
		public var mu01:Number;
		public var mu11:Number;
		public var mu20:Number;
		public var mu02:Number;
		public var invM00:Number;
		public var xc:Number;
		public var yc:Number;
		
		
		public function Moments(aData:Array, bSecond:Boolean = false)
		{
			m00 =  m01 = m10 = m11 = m02 = m20  = 0;
			var x:int;
			var y:int;
			var a:Array;
			var val:Number;
			for(x = 0; x < aData.length; ++x)
			{
				a = aData[x];
				for(y = 0; y < a.length; ++y)
				{
					val = a[y];
					m00 += val;
					m01 += y * val;
					m10 += x * val;
					if (bSecond)
					{
						m11 += x * y * val;
						m02 += y * y * val;
						m20 += x * x * val;
					}
				}
			}
			
			invM00 = 1 / m00;
			xc = m10 * invM00;
			yc = m01 * invM00;
			mu00 = m00;
			mu01 = mu10 = 0;
			if (bSecond)
			{
				mu20 = m20 - m10 * xc;
				mu02 = m02 - m01 * yc;
				mu11 = m11 - m01 * xc;
			}
		}
		
		public function toString():String
		{
			return "m00 = " + m00 + " , m01 = " + m01 + " , m10 = " + m10 + ", m02 = " + m02 + " , m20 = " + m20 + " , mu00 = " + mu00 + " , mu01 = " + mu01 + " , mu10 = " + mu10 + " , mu11 = " + mu11 + " , mu02 = " + mu02 + " , mu20 = " + mu20;
		}
	}	
}
