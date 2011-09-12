/*---------------------------------------------------------------------------------------------

	[AS3] EyesArea
	=======================================================================================

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
	import net.blog2t.util.RectUtils;
	import hislope.filters.FilterBase;
	import hislope.filters.pixelbender.Levels;
	import hislope.filters.color.ColorRange;
	
	import flash.utils.ByteArray;
	import flash.geom.Rectangle;
	import flash.geom.Point;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class EyesArea extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Eyes Area";
		private static const PARAMETERS:Array = [
			{
				name: "eyesAreaLevel",
				label: "eye area level",
				current: 0.15,
				min: 0,
				max: 1,
				type: "number"
			}, {
				name: "eyesAreaDeflationX",
				label: "eye area deflation X",
				current: 0.15,
				min: 0,
				max: 1,
				type: "number"
			}, {
				name: "eyesAreaDeflationY",
				label: "eye area deflation Y",
				current: 0.6,
				min: 0,
				max: 1,
				type: "number"
			}
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		
		private var tempBmpData:MetaBitmapData;
		private var sourceBmpData:BitmapData;
		
		private var activePixels:ByteArray;

		private var eyesArea:Rectangle = new Rectangle();
		private var outline:Shape = new Shape();
		
		private var levels:Levels = new Levels({autoLevels:true});
		private var colorRange:ColorRange = new ColorRange();

		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var eyesAreaLevel:Number;
		public var eyesAreaDeflationX:Number;
		public var eyesAreaDeflationY:Number;
	
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function EyesArea(OVERRIDE:Object = null) 
		{
			sourceBmpData = resultMetaBmpData.clone();
			tempBmpData = resultMetaBmpData.cloneAsMeta();
			
			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.copyTo(tempBmpData);
			
			outline.graphics.clear();
			
			if (metaBmpData.faceRectNorm)
			{
				eyesArea = metaBmpData.faceRect.clone();
				
				outline.graphics.lineStyle(0, 0x0000ff, 1);
				outline.graphics.drawRect(eyesArea.x, eyesArea.y, eyesArea.width, eyesArea.height);
				
				eyesArea.offset(0, int(-eyesArea.height * eyesAreaLevel));
				eyesArea.inflate(
					-int(eyesAreaDeflationX * 0.3 * eyesArea.width),
					-int(eyesAreaDeflationY * 0.5 * eyesArea.height)
				);
			}
			
			outline.graphics.lineStyle(0, 0x00ff00, 1);
			outline.graphics.drawRect(eyesArea.x, eyesArea.y, eyesArea.width, eyesArea.height);
			tempBmpData.draw(outline);

			// normalized eye position
			var eyesAreaNorm:Rectangle = new Rectangle(eyesArea.x / metaBmpData.width, eyesArea.y / metaBmpData.height, eyesArea.width / metaBmpData.width, eyesArea.height / metaBmpData.height);
			metaBmpData.eyesArea = eyesArea;
			metaBmpData.eyesAreaNorm = eyesAreaNorm;
			
			/*if (metaBmpData.fullSizeBmpData) sourceBmpData = metaBmpData.fullSizeBmpData; else sourceBmpData = metaBmpData as BitmapData;
			var sourceRect:Rectangle = new Rectangle(eyesAreaNorm.x * sourceBmpData.width, eyesAreaNorm.y * sourceBmpData.height, eyesAreaNorm.width * sourceBmpData.width, eyesAreaNorm.height * sourceBmpData.height);*/

			/*metaBmpData.roi = eyesArea.clone();*/

			/*metaBmpData.eyesArea = RectUtils.scaleAlignTL(eyesAreaNorm, sourceBmpData);
			metaBmpData.roi = RectUtils.scaleAlignTL(eyesAreaNorm, sourceBmpData);
			metaBmpData.copyPixels(sourceBmpData, sourceRect, new Point());*/

			postPreview(tempBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}