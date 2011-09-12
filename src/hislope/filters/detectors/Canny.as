/*---------------------------------------------------------------------------------------------

	[AS3] Canny
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
	import hislope.filters.FilterBase;
	import ru.inspirit.image.CannyEdgeDetector;
	import net.blog2t.util.BitmapUtils;
	import flash.display.BitmapData;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class Canny extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Canny Edge Detector";
		private static const PARAMETERS:Array = [
			{
				name: "blurSize",
				label: "blur Size",
				current: 3.0,
				min: 0,
				max: 10,
				type: "number"
			}, {
				name: "lowThreshold",
				label: "low Threshold",
				current: 0.5,
				min: 0,
				max: 1,
				type: "Number"
			}, {
				name: "highThreshold",
				label: "high Threshold",
				current: 0.9,
				min: 0,
				max: 1,
				type: "Number"
			}
		];
		
		private static const DEBUG_VARS:Array = null;

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		private var canny:CannyEdgeDetector;
		private var detectionBmpData:MetaBitmapData;
		private var edgesBmpData:BitmapData;
 	
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var blurSize:Number;
		public var lowThreshold:Number;
		public var highThreshold:Number;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function Canny(OVERRIDEN:Object = null)
		{
			detectionBmpData = resultMetaBmpData.cloneAsMeta();
			edgesBmpData = resultMetaBmpData.clone();
			
			canny = new CannyEdgeDetector(detectionBmpData)
			
			init(NAME, PARAMETERS, OVERRIDEN, DEBUG_VARS);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.copyTo(detectionBmpData);
			BitmapUtils.desaturate(detectionBmpData);

			canny.detectEdges(edgesBmpData);
			metaBmpData.cannyEdgesBmpData = edgesBmpData;
	        
			postPreview(edgesBmpData);
		}
		
		override public function updateParams():void
		{
			canny.blurSize = blurSize;
			canny.lowThreshold = lowThreshold;
			canny.highThreshold = highThreshold;
			
			// update parameters if changed
			super.updateParams();
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
	}
}