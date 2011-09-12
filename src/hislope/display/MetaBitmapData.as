/*---------------------------------------------------------------------------------------------

	[AS3] MetaBitmapData
	=======================================================================================

	HiSlope toolkit copyright (c) 2010 Tomek 'Og2t' Augustyn
	http://play.blog2t.net/hislope

	You are free to use this source code in any non-commercial project. 
	You are free to modify this source code in anyway you see fit.
	You are free to distribute this source code.

	You may NOT charge anything for this source code.
	This notice and the copyright information must be left intact in any distribution of this source code. 
	You are encouraged to release any improvements back to the ActionScript community.

	VERSION HISTORY:
	v0.1	Born on 16/07/2009

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.display
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;
	import flash.display.IBitmapDrawable;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import hislope.filters.FilterBase;
	
	import hislope.vo.faceapi.FaceFeatures;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	dynamic public class MetaBitmapData extends BitmapData
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////
		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		private var _fillColor:uint;
		private var _roi:Rectangle;
		public var originalPoint:Point;
		private var translationMatrix:Matrix;
		
		public var fullSizeBmpData:BitmapData;
		public var faceFeatures:Vector.<FaceFeatures>;
		public var trackedPoints:Vector.<Point>;
		
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
	
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////

		public function MetaBitmapData(width:int = -1, height:int = -1, transparent:Boolean = true, fillColor:uint = 0xFFFFFFFF) 
		{
			// defaultage
			if (width == -1 && height == -1)
			{
				width = FilterBase.WIDTH;
				height = FilterBase.HEIGHT;
				transparent = false;
				fillColor = 0x0;
			}
			
			super(width, height, transparent, fillColor);

			_fillColor = fillColor;
			
			_roi = new Rectangle(0, 0, width, height);
			
			originalPoint = new Point();
			translationMatrix = new Matrix();
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		
		public function cloneAsMeta():MetaBitmapData
		{
			return new MetaBitmapData(width, height, transparent, _fillColor);
		}
		
		
		public function pasteAreaTo(targetBmpData:MetaBitmapData, area:Rectangle):MetaBitmapData
		{
			if (targetBmpData.width < area.width || targetBmpData.height < area.height)
			{
				throw new Error("Error: destination BitmapData to small to paste slice to");
			}
			
			// just use draw with clipRect or copyPixels?
			
			var areaPixels:ByteArray = this.getPixels(area);
			areaPixels.position = 0;
			targetBmpData.fillRect(new Rectangle(0, 0, width, height), 0x000000);
			targetBmpData.originalPoint = area.topLeft.clone();
			// We have to offset the area to the top left corner as the applyFilter method is buggy
			// when used with ShaderFilter and totally ignores the destPoint
			area.offset(-area.x, -area.y);
			targetBmpData.setPixels(area, areaPixels);
			targetBmpData._roi = area;
			return targetBmpData;
		}
		
		
		public function drawActiveAreaTo(targetBmpData:MetaBitmapData, destPoint:Point = null):void
		{
			if (destPoint) targetBmpData.copyPixels(this, _roi, destPoint);
			else targetBmpData.copyPixels(this, _roi, originalPoint);
		}
		
		
		/*public function drawInPlace(source:IBitmapDrawable):void
		{
			translationMatrix.identity();
			translationMatrix.translate(originalPoint.x, originalPoint.y);
			super.draw(source, translationMatrix);
		}*/
		
		
		public function copyTo(targetBmpData:*):void
		{
			targetBmpData.lock();
			targetBmpData.copyPixels(this, roi, roi.topLeft);
			/*targetBmpData.copyPixels(this, rect, rect.topLeft);*/
			targetBmpData.unlock();
			
			if (targetBmpData is MetaBitmapData)
			{
				for (var property:Object in this)
				{
					targetBmpData[property] = this[property];
				}
			}
		}
		
		// seems slower
		/*public function processFilter(filter:*):void
			{
				if (_roi) super.applyFilter(this, _roi, _roi.topLeft, filter);
				super.applyFilter(this, rect, rect.topLeft, filter);
			}
		*/	
		
		// FIXME Flash bug when appling Shader to a portion of a BitmapData 
		public function applyShader(shaderFilter:*):void
		{
			// can't use here as input variable might be different for each Kernel
			/*shaderFilter.shader.data.srcPixel.input = this;
			var job:ShaderJob = new ShaderJob(shader, this as BitmapData, width, height);
			job.start(true);*/
			
			// buggy
			/*if (_roi) super.applyFilter(this, new Rectangle((width - _roi.width) / 2, (height - _roi.height) / 2, 0, 0), new Point(), shaderFilter);*/
			super.applyFilter(this, rect, rect.topLeft, shaderFilter);
			//super.applyFilter(this, rect, new Point(), shaderFilter);
		}
		
		
		public function get roi():Rectangle
		{
			if (_roi) return _roi.clone();
			return rect;
		}
		
		
		public function set roi(value:Rectangle):void
		{
			_roi = value;
		}
		
		
		public function resetROI():void
		{
			_roi.x = 0;
			_roi.y = 0;
			_roi.width = width;
			_roi.height = height;
		}
		
		
		/*public function set rect(value:Rectangle):void
		{
			_roi = value;
		}
		
		override public function get rect():Rectangle
		{
			return _roi;
		}*/
		
		
		public function fill(color:uint):void
		{
			super.fillRect(rect, color);
		}
		
		
		public function clear():void
		{
			super.fillRect(rect, _fillColor);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		
		public function set fillColor(value:uint):void
		{
			_fillColor = value;
		}
		
		// HELPERS ////////////////////////////////////////////////////////////////////////////
		
		public function scaleTo(targetBmpData:BitmapData, scale:Number = 1.0, smoothing:Boolean = true):void
		{
			targetBmpData.draw(this, new Matrix(scale, 0, 0, scale), null, "normal", null, smoothing);
		}
	}
}