/*---------------------------------------------------------------------------------------------

	[AS3] BlobDetection
	=======================================================================================

	VERSION HISTORY:
	v0.1	Born on 2009-07-17

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package net.blog2t.util
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.geom.Rectangle;
	import flash.display.BitmapData;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class BlobDetection
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const FLOOD_FILL_COLOR:uint = 0xffff00ff;
		private static const PROCESSED_COLOR:uint = 0xff00ffff;
		private static const MASK:uint = 0xFFFFFFFF;

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public static function detect(
			bitmapData:BitmapData,
			blobRects:Array,
			blobColor:uint = 0xffffff,
			minWidth:int = 2,
			minHeight:int = 2,
			maxWidth:int = 20,
			maxHeight:int = 20,
			maxBlobs:int = 20,
			oversizedBlobRects:Array = null):void
		{
			var blobRect:Rectangle;
			var blobMaxRect:Rectangle = new Rectangle(0, 0, maxWidth, maxHeight);
			var blobMinRect:Rectangle = new Rectangle(0, 0, minWidth, minHeight);
			var mainRect:Rectangle;

			var i:int = 0;
			var x:int;
			
			while (i < maxBlobs)
			{
				// get the rectangle containing only pixels of the searched color
				mainRect = bitmapData.getColorBoundsRect(MASK, blobColor);

				// exit if the rectangle is empty
				if (mainRect.isEmpty()) break;

				// get the first column of the rectangle
				x = mainRect.x;

				// examine pixel by pixel unless you find the first blobColor pixel
				for (var y:uint = mainRect.y; y < mainRect.bottom; y++)
				{
					if (bitmapData.getPixel(x, y) == blobColor)
					{
						// fill it with some color
						bitmapData.floodFill(x, y, FLOOD_FILL_COLOR);

						// get the bounds of the filled area – this is the blob
						blobRect = bitmapData.getColorBoundsRect(MASK, FLOOD_FILL_COLOR);

						blobMaxRect.x = blobRect.x;
						blobMaxRect.y = blobRect.y;
						blobMinRect.x = blobRect.x;
						blobMinRect.y = blobRect.y;

						// check if the size of the blob is equal or smaller than needed
						if (blobMaxRect.containsRect(blobRect) && blobRect.containsRect(blobMinRect)) blobRects.push(blobRect);
							else if (oversizedBlobRects) oversizedBlobRects.push(blobRect);

						// mark blob as processed with some other color
						bitmapData.floodFill(x, y, PROCESSED_COLOR);
					}
				}

				// increase number of detected blobs
				i++;
			}
		}

		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}