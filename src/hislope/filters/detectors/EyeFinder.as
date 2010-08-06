/*---------------------------------------------------------------------------------------------

	[AS3] EyeFinder
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

package hislope.filters.detectors
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import net.blog2t.util.BlobDetection;
	import flash.events.Event;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import net.blog2t.util.ColorUtils;
	import net.blog2t.util.BitmapUtils;
	import hislope.filters.FilterBase;
	import hislope.filters.pixelbender.Levels;
	import hislope.filters.color.ColorRange;
	
	import flash.utils.ByteArray;
	import flash.geom.Rectangle;
	import flash.geom.Point;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class EyeFinder extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Eye Finder";
		private static const PARAMETERS:Array = [
			{
				name: "blur",
				label: "blur",
				current: 3.0,
				min: 1,
				max: 20,
				type: "number"
			}, {
				name: "fuziness",
				label: "fuziness",
				current: 0.5,
				min: 0,
				max: 1,
				type: "number"
			}, {
				name: "eyeAreaHeight",
				label: "eye area height",
				current: 0.6,
				min: 0,
				max: 1,
				type: "number"
			}, {
				name: "eyeAreaDeflationX",
				label: "eye area deflation X",
				current: -20,
				min: -50,
				max: -5,
				type: "number"
			}, {
				name: "eyeAreaDeflationY",
				label: "eye area deflation Y",
				current: -30,
				min: -50,
				max: -5,
				type: "number"
			}, {
				name: "debug",
				label: "debug",
				current: false,
				type: "boolean"
			}, {
				name: "colorSample",
				label: "color sample",
				type: "rgb"
			}
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var rmin:uint;
		private var gmin:uint;
		private var bmin:uint;
		
		private var rmax:uint;
		private var gmax:uint;
        private var bmax:uint;

		private var rgbMin:uint;
        private var rgbMax:uint;

		public var eyeAreaHeight:Number;
		public var eyeAreaDeflationX:Number;
		public var eyeAreaDeflationY:Number;

		private var sourceBmpData:MetaBitmapData;
		private var activeBmpData:BitmapData;
		private var activePixels:ByteArray;

		private var eyeArea:Rectangle = new Rectangle();
		private var outline:Shape = new Shape();
		
		private var maxBlobs:int = 2;
		private var minBlobWidth:int = 5;
		private var minBlobHeight:int = 4;
		private var maxBlobWidth:int = 25;
		private var maxBlobHeight:int = 15;
		private var blobRects:Array = [];

		private var levels:Levels = new Levels({autoLevels:true});
		private var colorRange:ColorRange = new ColorRange();

		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var fuziness:Number;
		public var blur:Number;
		public var colorSample:uint;
		public var debug:Boolean;
	
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function EyeFinder(OVERRIDE:Object = null) 
		{
			activeBmpData = resultMetaBmpData.clone();
			sourceBmpData = resultMetaBmpData.getClone();
			
			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.copyTo(sourceBmpData);
			
			if (metaBmpData.activeRect)
			{
				eyeArea = metaBmpData.activeRect.clone();
				eyeArea.inflate(eyeAreaDeflationX, eyeAreaDeflationY);
				eyeArea.height = int(eyeArea.height * eyeAreaHeight);

				BitmapUtils.blur(sourceBmpData, blur);
				
				activePixels = sourceBmpData.getPixels(eyeArea);
				activePixels.position = 0;
				activeBmpData.fillRect(new Rectangle(0, 0, sourceBmpData.width, sourceBmpData.height), 0x000000);
				/*levels.apply(activeBmpData as MetaBitmapData);*/
				activeBmpData.setPixels(eyeArea, activePixels);
				
				/*levels.restrictToRegion(eyeArea);*/

				/*colorRange.restrictToRegion(eyeArea);
					colorRange.fuziness = fuziness;
					colorRange.blur = blur;
					colorRange.sample = 0x000000;
					colorRange.apply(activeBmpData as MetaBitmapData);*/
				
				// replace with color range filter
				
				activeBmpData.lock();

				activeBmpData.threshold(activeBmpData, eyeArea, eyeArea.topLeft, "<", rmin << 16, 0, 0x00ff0000, true);
				activeBmpData.threshold(activeBmpData, eyeArea, eyeArea.topLeft, "<", gmin << 8, 0, 0x0000ff00, true);
				activeBmpData.threshold(activeBmpData, eyeArea, eyeArea.topLeft, "<", bmin, 0, 0x000000ff, true);
				activeBmpData.threshold(activeBmpData, eyeArea, eyeArea.topLeft, ">", rmax << 16, 0, 0x00ff0000, true);
				activeBmpData.threshold(activeBmpData, eyeArea, eyeArea.topLeft, ">", gmax << 8, 0, 0x0000ff00, true);
				activeBmpData.threshold(activeBmpData, eyeArea, eyeArea.topLeft, ">", bmax, 0, 0x000000ff, true);
				activeBmpData.threshold(activeBmpData, eyeArea, eyeArea.topLeft, "==", 0xff000000, 0xffffffff, 0xff000000, true);

				activeBmpData.unlock();

				blobRects = [];

				BlobDetection.detect(activeBmpData as BitmapData, blobRects, 0xffffff, minBlobWidth, minBlobHeight, maxBlobWidth, maxBlobHeight, maxBlobs);
				outline.graphics.clear();

				if (debug) sourceBmpData.copyPixels(activeBmpData, eyeArea, eyeArea.topLeft);

				var point:Point = new Point();

				for each (var blobRect:Rectangle in blobRects)
				{
					blobRect.inflate(6, 5);
					outline.graphics.beginFill(0x00ff00, 0.6);
					outline.graphics.drawRect(blobRect.x, blobRect.y, blobRect.width, blobRect.height);
					outline.graphics.endFill();

					sourceBmpData.copyPixels(metaBmpData, blobRect, point);

					point.x += blobRect.width + 1;
				}

				sourceBmpData.draw(outline);

				metaBmpData.eyes = blobRects;
			} /*else {
				//copy metaBmpData to activeBmpData
				}*/

				getPreviewFor(sourceBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		override public function updateParams():void
		{		
			rgbMin = ColorUtils.brighten(colorSample, -fuziness);
			rgbMax = ColorUtils.brighten(colorSample, fuziness);

			rmin = (rgbMin >> 16) & 0xff;
			gmin = (rgbMin >> 8) & 0xff;
			bmin = rgbMin  & 0xff;

			rmax = (rgbMax >> 16) & 0xff;
			gmax = (rgbMax >> 8) & 0xff;
			bmax = rgbMax  & 0xff;
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}