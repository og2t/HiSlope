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
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import org.libspark.faceit.utils.bitmap.ImgData;

	public class Tracker 
	{
		private var _modelHist:Histogram;
		private var _curHist:Histogram;
		private var _trackHist:Histogram;
		private var _pdf:ImgData;
		private var _trackingArea:Rectangle;
		private var _searchWindow:Rectangle;
		private var _trackObj:TrackObj;
		private var _sqrt:Function;
		private var _atan2:Function;
		private var _min:Function;
		private var _max:Function;
		
		public function Tracker() 
		{
			// shortcuts to improve speed of native Math class methods
			_sqrt = Math.sqrt;
			_atan2 = Math.atan2;
			_min = Math.min;
			_max = Math.max;
		}
		
		/**
		* Return the search windows used by the camshift algorithm into into the current analysed image
		* @return	Rectangle
		*/
		public function getSearchWindow():Rectangle { return _searchWindow.clone(); }
		
		/**
		* Return a TrackObj object with the size and orientation of the tracked object into the current analysed image
		* @return	TrackObj
		*/
		public function getTrackObj():TrackObj { return _trackObj; }
		/**
		* Return an ImgData oject representing color 
		* @return	Bitmapdata
		*/
		public function getPdf():ImgData { return _pdf; }
		
		/**
		* Return a grayscale bitmapdata representing pixel color probabilities
		* @return	Bitmapdata
		*/
		public function getBackProjectionBmp():BitmapData
		{
			var img:ImgData = _pdf;
			var weights:Array = img.getPixels();
			var w:Number = img.width;
			var h:Number = img.height;
			var bmp:BitmapData = new BitmapData(w, h);
			var x:int;
			var y:int;
			var val:int;
			var color:int;
			bmp.lock();
			for (x = 0; x < w; ++x)
			{
				for (y = 0; y < h; ++y)
				{
					val = Math.floor( 255 * weights[x][y]);
					color = ( val << 16) | (val << 8) | val;
					bmp.setPixel(x, y, color);
				}
			}
			bmp.unlock();
			return bmp;
		}
		
		/**
		 * Initialize the Tracker
		* @param  frame BitmapData Initial image where is the object to track
		* @param  trackedArea Rectangle Area of the initial image where is the tracked object
		* @param  scale Number Scale ratio to rescale the analyzed in order to improve computing speed
		* @return	Bitmapdata
		*/
		public function initTracker(frame:BitmapData, trackedArea:Rectangle, scale:Number = 0.25):void
		{
			var trackedImg:ImgData =  ImgData.createFromBmp(frame, trackedArea);
			_modelHist = new Histogram(trackedImg);	
			_searchWindow = trackedArea.clone();
			_trackObj = new TrackObj();
		}
		
		/**
		 *  Search the tracked objectby camshift
		* @param  frame BitmapData Image where the tracked object is searched
		* @return	Bitmapdata
		*/
		public function track(frame:BitmapData):void
		{
			if(frame.width != 0 && frame.height !=0) camShift(ImgData.createFromBmp(frame));
		}
		
		
		// Private Methods
		private function camShift(frame:ImgData):void
		{
			var w:Number = frame.width;
			var h:Number = frame.height;
			
			// search location
			var m:Moments = meanShift(frame);
			
			// use moments to find size and orientation
			var a:Number = m.mu20 * m.invM00;
			var b:Number = m.mu11 * m.invM00;
			var c:Number = m.mu02 * m.invM00;
			var d:Number = a + c;
			var e:Number = _sqrt((4*b * b) + ((a - c) * (a - c)));
			
			_trackObj.width = _sqrt((d - e)*0.5)*4;
			_trackObj.height = _sqrt((d + e)*0.5)*4;
			_trackObj.angle = _atan2(  2 * b, a - c + e );
			// to have a positive counter clockwise angle
			if (_trackObj.angle < 0) _trackObj.angle = _trackObj.angle + Math.PI;
		
			// check if tracked object is into the limit
			_trackObj.x = _max(0, _min(_searchWindow.x + _searchWindow.width/2, w));
			_trackObj.y = _max(0, _min(_searchWindow.y + _searchWindow.height / 2, h));

			// new search window size
			var s:int = 2 * _sqrt(m.m00);
			_searchWindow.width = 1.1 * _trackObj.width;
			_searchWindow.height = 1.1 * _trackObj.height;
			
		}
		
		
		/**
		* Return an array of the probalities of each histogram color bins
		* @return	Moments The moments 
		*/
		private function meanShift(frame:ImgData):Moments
		{
			var w:Number = frame.width;
			var h:Number = frame.height;
			var roi:ImgData = frame;//frame.getPart(_searchWindow);
			var curHist:Histogram = new Histogram(roi);
			var aWeights:Array = getWeights(_modelHist, curHist);
			
			// Color probabilities distributions
			_pdf = ImgData.createFromArray(getBackProjectionData(frame, aWeights));
			
			var meanShiftIterations:int = 10;
			var windowAreaData:Array;
			var m:Moments;
			var x:Number;
			var y:Number;
			var i:int;
			// Locate by iteration the maximun of density into the probalities distribution
			for (i = 0; i < meanShiftIterations; i++)
			{
				windowAreaData = _pdf.getPart(_searchWindow).getPixels();
				m = new Moments(windowAreaData, (i == meanShiftIterations -1));
				x = m.xc;
				y = m.yc;
				
				_searchWindow.x += x - _searchWindow.width/2;
				_searchWindow.y += y - _searchWindow.height/2; 
			}
			_searchWindow.x = Math.max(0, Math.min(_searchWindow.x, w));
			_searchWindow.y = Math.max(0, Math.min(_searchWindow.y , h));
			return m;
		}
		
		/**
		* Return an array of the probalities of each histogram color bins
		* @return	Bitmapdata
		*/
		private function getWeights(mh:Histogram, ch:Histogram):Array
		{
			var aWeights:Array = [];
			var p:Number
			for(var i:int = 0; i < Histogram.SIZE; ++i)
			{
				p = (ch.getBin(i) != 0)?_min(mh.getBin(i) / ch.getBin(i), 1):0;
				aWeights.push(p);  
			}
			return aWeights;
		}
		
		/**
		* Return a grayscale bitmapdata representing pixel color probabilities
		* @return	Bitmapdata
		*/
		private function getBackProjectionData(img:ImgData, aWeights:Array):Array
		{
			var aData:Array = [];
			var x:int;
			var y:int; 
			var pixel:int;
			var r:int;
			var g:int;
			var b:int;
			var a:Array;
			for (x = 0; x < img.width; ++x)
			{
				a = [];
				for (y = 0; y < img.height; ++y)
				{
					pixel = img.getPixel(x, y);
					r = (pixel>>16 & 0xFF)/16;
					g = (pixel>>8 & 0xFF)/16;
					b = (pixel & 0xFF)/16;
					a.push(aWeights[256 * r + 16 * g +  b]);
				}
				aData[x] = a;
			}
			return aData.slice();
		}
	}
	
}
