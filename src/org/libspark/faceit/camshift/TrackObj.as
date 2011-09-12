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
	
	public class TrackObj 
	{
		public var height:Number;
		public var width:Number;
		public var angle:Number;
		public var x:Number;
		public var y:Number;
		
		public function TrackObj() 
		{
			height = width = angle = 0;
		}
		
	}
	
}