package ru.inspirit.image 
{
	import cmodule.canny.CLibInit;

	import com.joa_ebert.apparat.memory.Memory;
	import com.joa_ebert.apparat.memory.MemoryMath;

	import flash.display.BitmapData;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	/**
	 * released under MIT License (X11)
	 * http://www.opensource.org/licenses/mit-license.php
	 * 
	 * This class provides a configurable implementation of the Canny edge
	 * detection algorithm. This classic algorithm has a number of shortcomings,
	 * but remains an effective tool in many scenarios.
	 * 
	 * @author Eugene Zatepyakin
	 * @see http://blog.inspirit.ru
	 */
	final public class CannyEdgeDetector 
	{		
		protected const GAUSS_BLUR:BlurFilter = new BlurFilter( 2, 2, 2 );
		protected const ORIGIN:Point = new Point();
		
		protected static var CANNY_LIB:Object;		
		protected static var alchemyRAM:ByteArray;
		
		protected var _imagePointer:int;
		protected var _edgesPointer:int;
		protected var imagePointer:int;
		protected var edgesPointer:int;
		protected var lowThreshPointer:int;
		protected var highThreshPointer:int;
		
		protected var image:BitmapData;
		protected var buffer:BitmapData;
		protected var rect:Rectangle;
		protected var width:int;
		protected var height:int;
		protected var area:int;
		protected var _lowThreshold:Number;
		protected var _highThreshold:Number;
		protected var _blurSize:uint = 0;
		
		public function CannyEdgeDetector(image:BitmapData, lowThreshold:Number = 0.2, highThreshold:Number = 0.9)
		{	
			CANNY_LIB = (new CLibInit()).init();
			var ns:Namespace = new Namespace( "cmodule.canny" );
			alchemyRAM = (ns::gstate).ds;
			
			var pts:Array = CANNY_LIB.getPointers();
			_imagePointer = pts[0];
			_edgesPointer = pts[1];
			lowThreshPointer = pts[2];
			highThreshPointer = pts[3];
			
			this.lowThreshold = lowThreshold;
			this.highThreshold = highThreshold;
			
			source = image;
		}

		public function set source(bmp:BitmapData):void
		{
			this.image = bmp;
			
			if(bmp.width != width || bmp.height != height)
			{
				width = this.image.width;
				height = this.image.height;
				area = width * height;
				rect = this.image.rect;
				
				buffer = new BitmapData(width, height, false, 0x00);
				buffer.lock();
				
				CANNY_LIB.setupCanny(width, height, _lowThreshold, _highThreshold);
				
				imagePointer = Memory.readInt(_imagePointer);
				edgesPointer = Memory.readInt(_edgesPointer);
			}
		}

		public function detectEdges(edgesImage:BitmapData):void
		{
			//buffer.applyFilter(image, rect, ORIGIN, GRAYSCALE_MATRIX);
			//buffer.copyPixels(image, rect, ORIGIN);
			
			if(blurSize > 0)
			{
				buffer.applyFilter(image, rect, ORIGIN, GAUSS_BLUR);
			} else {
				buffer.copyPixels(image, rect, ORIGIN);
			}
			
			var data:Vector.<uint> = buffer.getVector(rect);
			var pos:int = imagePointer;
			var i:int;
			
			i = area;		
			while( --i > -1 )
			{
				Memory.writeInt(data[i]&0xFF, pos + (i<<2));
			}
			
			CANNY_LIB.runCanny();
			
			edgesImage.lock();
			alchemyRAM.position = edgesPointer;
			edgesImage.setPixels( rect, alchemyRAM );
			edgesImage.unlock( rect );
		}
		
		public function set blurSize(value:uint):void
		{
			if(value > 0) 
			{
				_blurSize = MemoryMath.nextPow2(value);
				GAUSS_BLUR.blurX = GAUSS_BLUR.blurY = _blurSize;
			} else {
				_blurSize = 0;
			}
		}
		public function get blurSize():uint 
		{
			return _blurSize;
		}

		public function set lowThreshold(value:Number):void
		{
			_lowThreshold = value;
			if(_lowThreshold > _highThreshold){
				value = _lowThreshold;
				_lowThreshold = _highThreshold;
				_highThreshold = value;
			}
			Memory.writeDouble(_lowThreshold, lowThreshPointer);
			Memory.writeDouble(_highThreshold, highThreshPointer);
		}
		public function get lowThreshold():Number
		{
			return _lowThreshold;
		}

		public function set highThreshold(value:Number):void
		{
			_highThreshold = value;
			if(_lowThreshold > _highThreshold){
				value = _lowThreshold;
				_lowThreshold = _highThreshold;
				_highThreshold = value;
			}
			Memory.writeDouble(_lowThreshold, lowThreshPointer);
			Memory.writeDouble(_highThreshold, highThreshPointer);
		}
		public function get highThreshold():Number
		{
			return _highThreshold;
		}
		
		public function dispose():void
		{
			if(buffer) buffer.dispose();
			CANNY_LIB.destroyCanny();
			CANNY_LIB = null;
		}
	}
}
