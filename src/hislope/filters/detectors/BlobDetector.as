/*---------------------------------------------------------------------------------------------

	[AS3] BlobDetector
	=======================================================================================

	HiSlope toolkit copyright (c) 2008-2011 Tomek 'Og2t' Augustyn
	http://play.blog2t.net/HiSlope

	You are free to use this source code in any non-commercial project. 
	You are free to modify this source code in anyway you see fit.
	You are free to distribute this source code.

	You may NOT charge anything for this source code.
	This notice and the copyright information must be left intact in any distribution of this source code. 
	You are encouraged to release any improvements back to the ActionScript community.

	VERSION HISTORY:
	v0.1	Born on 17/07/2009

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.filters.detectors
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import hislope.filters.FilterBase;
	import net.blog2t.util.BlobDetection;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.display.Shape;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class BlobDetector extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Blob Detector";
		private static const PARAMETERS:Array = [
			{
				name: "maxBlobs",
				label: "max number of blobs",
				current: 2,
				min: 1,
				max: 200,
				type: "uint"
			}, {
				name: "blobColor",
				label: "blob color",
				current: 0xffffff,
				type: "rgb"
			}, {
				name: "minBlobWidth",
				label: "min blob width",
				current: 20,
				min: 1,
				max: 50,
				type: "uint"
			}, {
				name: "minBlobHeight",
				label: "min blob height",
				current: 20,
				min: 1,
				max: 50,
				type: "uint"
			}, {
				name: "maxBlobWidth",
				label: "max blob width",
				current: 50,
				min: 1,
				max: 200,
				type: "uint"
			}, {
				name: "maxBlobHeight",
				label: "max blob height",
				current: 50,
				min: 1,
				max: 200,
				type: "uint"
			}
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		
		private var blobRects:Array = [];
		private var oversizedBlobRects:Array = [];
		private var outline:Shape = new Shape();
		
		private var sourceBmpData:MetaBitmapData;
		
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var maxBlobs:int;
		public var blobColor:uint;
		public var maxBlobWidth:int;
		public var maxBlobHeight:int;
		public var minBlobWidth:int;
		public var minBlobHeight:int;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function BlobDetector(newParams:Object = null)
		{
			sourceBmpData = resultMetaBmpData.cloneAsMeta();
			
			init(NAME, PARAMETERS, newParams);
		}

		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		
		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.roi = rect;
			/*metaBmpData.copyTo(sourceBmpData);*/
			
			blobRects = [];
			oversizedBlobRects = [];
			
			// no motion observed
			if (!metaBmpData.motionAreasBmpData) return;
			
			BlobDetection.detect(
				metaBmpData.motionAreasBmpData as BitmapData,
				blobRects,
				blobColor,
				minBlobWidth,
				minBlobHeight,
				maxBlobWidth,
				maxBlobHeight,
				10,
				oversizedBlobRects
			);
			
			outline.graphics.clear();
			
			drawBlobs(blobRects, 0xff0000);
			drawBlobs(oversizedBlobRects, 0xffff00);


			sourceBmpData.draw(metaBmpData);
			sourceBmpData.draw(metaBmpData.motionAreasBmpData, null, null, BlendMode.SCREEN);
			sourceBmpData.draw(outline);
			
			postPreview(sourceBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		private function drawBlobs(blobsRectsArray:Array, color:uint = 0x00ff00):void
		{
			for each (var blobRect:Rectangle in blobsRectsArray)
			{
				outline.graphics.lineStyle(0, color, 1);
				outline.graphics.drawRect(blobRect.x, blobRect.y, blobRect.width, blobRect.height);
			}
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}