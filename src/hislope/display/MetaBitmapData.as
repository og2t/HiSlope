/*---------------------------------------------------------------------------------------------

	[AS3] MetaBitmapData
	=======================================================================================

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

	import flash.display.BitmapData;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;
	import flash.display.IBitmapDrawable;
	import flash.utils.ByteArray;
	import hislope.filters.FilterBase;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	dynamic public class MetaBitmapData extends BitmapData
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////
		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		private var _fillColor:uint;
		private var _activeRect:Rectangle;
		public var originalPoint:Point;
		private var translationMatrix:Matrix;
		
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
	
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////

		public function MetaBitmapData(width:int = -1, height:int = -1, transparent:Boolean = true, fillColor:uint = 0xFFFFFFFF) 
		{
			if (width == -1 && height == -1)
			{
				width = FilterBase.WIDTH;
				height = FilterBase.HEIGHT;
				transparent = false;
				fillColor = 0x0;
			}
			
			super(width, height, transparent, fillColor);

			_fillColor = fillColor;
			
			_activeRect = new Rectangle(0, 0, width, height);
			originalPoint = new Point();
			translationMatrix = new Matrix();
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		
		public function getEmpty():MetaBitmapData
		{
			return new MetaBitmapData(width, height, transparent, _fillColor);
		}
		
		override public function clone():BitmapData
		{
			return new MetaBitmapData(width, height, transparent, _fillColor);
		}
		
		public function getClone():MetaBitmapData
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
			targetBmpData.activeRect = area;
			return targetBmpData;
		}
		
		public function drawActiveAreaTo(targetBmpData:MetaBitmapData, destPoint:Point = null):void
		{
			if (destPoint) targetBmpData.copyPixels(this, activeRect, destPoint);
			else targetBmpData.copyPixels(this, activeRect, originalPoint);
		}
		
		/*public function drawInPlace(source:IBitmapDrawable):void
		{
			translationMatrix.identity();
			translationMatrix.translate(originalPoint.x, originalPoint.y);
			super.draw(source, translationMatrix);
		}*/
		
		public function copyTo(targetBmpData:BitmapData):void
		{
			targetBmpData.lock();
			targetBmpData.copyPixels(this, this.rect, this.rect.topLeft);
			targetBmpData.unlock();
		}
		
		public function processFilter(filter:*):void
		{
			if (_activeRect) return super.applyFilter(this, activeRect, activeRect.topLeft, filter);
			return super.applyFilter(this, rect, rect.topLeft, filter);
		}
		
		public function applyShader(shaderFilter:*):void
		{
			if (_activeRect) return super.applyFilter(this, new Rectangle((width - activeRect.width) / 2, (height - activeRect.height) / 2, 0, 0), new Point(), shaderFilter);
			return super.applyFilter(this, rect, rect.topLeft, shaderFilter);
			//return super.applyFilter(this, rect, new Point(), shaderFilter);
		}
		
		public function get activeRect():Rectangle
		{
			if (_activeRect) return _activeRect.clone();
			return null;
		}
		
		public function set activeRect(value:Rectangle):void
		{
			_activeRect = value;
		}
		
		public function blur(blur:int = 0, quality:int = 2):void
		{
			//trace(_activeRect);
			
			super.applyFilter(this, _activeRect, _activeRect.topLeft, new BlurFilter(blur, blur, quality));
			/*super.applyFilter(this, rect, point, new BlurFilter(blur, blur, quality));*/
		}
		
		public function clear():void
		{
			super.fillRect(rect, _fillColor);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
		
		public function scaleTo(targetBmpData:BitmapData, scale:Number = 1.0, smoothing:Boolean = true):void
		{
			targetBmpData.draw(this, new Matrix(scale, 0, 0, scale), null, "normal", null, smoothing);
		}
	}
}