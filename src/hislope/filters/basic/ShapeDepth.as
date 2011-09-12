/*---------------------------------------------------------------------------------------------

	[AS3] ShapeDepth
	=======================================================================================

	HiSlope toolkit copyright (c) 2010 Tomek 'Og2t' Augustyn
	http://play.blog2t.net/hislope

	You are free to use this source code in any project. 
	You are free to modify this source code in anyway you see fit.
	You are free to distribute this source code.

	You may NOT charge anything for this source code.
	This notice and the copyright information must be left intact in any distribution of this source code. 
	You are encouraged to release any improvements back to the ActionScript community.

	VERSION HISTORY:
	v0.1	Born on 09/07/2009

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.filters.basic
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Shape;

	import hislope.display.MetaBitmapData;
	import hislope.filters.FilterBase;
	import hislope.util.PaletteMap;
	import net.blog2t.util.BitmapUtils;
	import net.blog2t.util.BlobDetection;
	
	import net.nicoptere.Delaunay;
	import net.nicoptere.Triangle;
	import net.nicoptere.Voronoi;
	import net.nicoptere.Point2D;
	
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	import flash.utils.ByteArray;
	import hislope.filters.pixelbender.Levels;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class ShapeDepth extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Shape";
		private static const PARAMETERS:Array = [
			{
				name: "levels",
				label: "Number of levels",
				current: 5,
				min: 1,
				max: 50,
				type: "int"
			}, {
				name: "smoothing",
				label: "Smoothing",
				current: 4,
				min: 1,
				max: 20,
				type: "number"
			}
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		private var paletteMap:PaletteMap = new PaletteMap();
		private var outline:Shape = new Shape();

		private var pts:Array;
		private var activeBmpData:BitmapData;
		private var sourceBmpData:MetaBitmapData;
		private var activePixels:ByteArray;

		private var maxBlobs:int = 10;
		private var maxBlobWidth:int = 100;
		private var maxBlobHeight:int = 100;
		
		private var blobRects:Array = [];
		private var oversizedBlobRects:Array = [];
		
		private var centerDestX:Number;
		private var centerDestY:Number;
		private var spotRadiusDest:Number;
				
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var levels:Number;
		public var smoothing:Number;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function ShapeDepth(OVERRIDE:Object = null)
		{
			activeBmpData = resultMetaBmpData.clone();
			sourceBmpData = resultMetaBmpData.cloneAsMeta();
			
			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.copyTo(sourceBmpData);
			BitmapUtils.desaturate(sourceBmpData);
			BitmapUtils.blur(sourceBmpData, smoothing, 3);
			sourceBmpData.paletteMap(sourceBmpData, rect, point, paletteMap.reds, paletteMap.greens, paletteMap.blues);

			outline.graphics.clear();
			outline.graphics.lineStyle(0, 0xff0000, 0.25);
			
			if (metaBmpData.faceRect)
			{
				activePixels = sourceBmpData.getPixels(metaBmpData.faceRect);
				activePixels.position = 0;
				activeBmpData.fillRect(new Rectangle(0, 0, sourceBmpData.width, sourceBmpData.height), 0x7f0000);
				activeBmpData.setPixels(metaBmpData.faceRect, activePixels);
				
				outline.graphics.drawRect(metaBmpData.faceRect.x, metaBmpData.faceRect.y, metaBmpData.faceRect.width, metaBmpData.faceRect.height);
			}

			blobRects = [];
			oversizedBlobRects = [];
		
			for (var i:int = 0; i < levels; i++)
			{
				BlobDetection.detect(activeBmpData as BitmapData, blobRects, paletteMap.values[i], 2, 2, maxBlobWidth, maxBlobHeight, maxBlobs, oversizedBlobRects);
			}
			
			metaBmpData.blobRects = blobRects;
			metaBmpData.oversizedBlobRects = oversizedBlobRects;
			
			if (metaBmpData.faceRect)
			{
				if (!metaBmpData.faceRect.isEmpty())
				{
					centerDestX = metaBmpData.faceRect.x + metaBmpData.faceRect.width / 2;
					centerDestY = metaBmpData.faceRect.y + metaBmpData.faceRect.height / 2;
					spotRadiusDest = Math.max(metaBmpData.faceRect.width, metaBmpData.faceRect.height) / 2;
				} else {
					spotRadiusDest = 0;
				}
				
				metaBmpData.spot = {
					x: centerDestX,
					y: centerDestY,
					radius: spotRadiusDest
				};
			}
			
			outline.graphics.lineStyle(0, 0x0ff00, 0.75);
		
			for each (var blobRect:Rectangle in blobRects)
			{
				outline.graphics.drawCircle(blobRect.x + blobRect.width / 2, blobRect.y + blobRect.height / 2, 0.5);
			}
				
			sourceBmpData.draw(outline);
			
			postPreview(sourceBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////

		override public function updateParams():void
		{			
			paletteMap.posterize(levels);
			
			super.updateParams();
		}

		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}