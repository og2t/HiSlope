/*---------------------------------------------------------------------------------------------

	[AS3] BackDropRemoval
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

package hislope.filters.motion
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Shape;
	import flash.display.BlendMode;
	import flash.filters.ColorMatrixFilter;
	import hislope.filters.IFilter;
	import hislope.filters.FilterBase;
	import hislope.util.PaletteMap;
	import net.blog2t.util.BitmapUtils;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	import flash.events.Event;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class BackDropRemoval extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Back Drop Removal";
		private static const PARAMETERS:Array = [
			{
				name: "sensitivity",
				label: "Sensitivity",
				current: 100,
				min: 0,
				max: 128,
				type: "int"	
			}, {
				name: "blurAmount",
				label: "Blur amount",
				current: 20,
				min: 1,
				max: 20,
				type: "number"
			}, {
				name: "blurQuality",
				label: "Blur quality",
				current: 1,
				min: 1,
				max: 3,
				type: "int"
			}, {
				name: "softenAmount",
				label: "Soften amount",
				current: 20,
				min: 1,
				max: 20,
				type: "number"
			}, {
				name: "softenQuality",
				label: "Soften quality",
				current: 1,
				min: 1,
				max: 3,
				type: "int"
			}, {
				label: "take shot",
				callback: "takeShot",
				type: "button"
			}
		];

		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var blurAmount:Number;
		public var softenAmount:Number;
		public var blurQuality:int;
		public var softenQuality:int;
		public var sensitivity:int;

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var areasBmpData:MetaBitmapData;
		private var sourceBmpData:MetaBitmapData;
		private var beforeBmpData:MetaBitmapData;
		private var outline:Shape = new Shape();

		private var copy:Boolean = false;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function BackDropRemoval(OVERRIDE:Object = null)
		{
			areasBmpData = resultMetaBmpData.cloneAsMeta();
			beforeBmpData = resultMetaBmpData.cloneAsMeta();
			sourceBmpData = resultMetaBmpData.cloneAsMeta();
			
			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.copyTo(areasBmpData);
			
			if (copy)
			{
				copy = false;
				metaBmpData.copyTo(beforeBmpData);
			}
			
			areasBmpData.draw(beforeBmpData, null, null, BlendMode.DIFFERENCE);

			// make all pixels greater than just over black (0xFF111111) green (0xFF00FF00)
			areasBmpData.threshold(areasBmpData, rect, point, ">", 0xFF111111, 0xFF00FF00, 0x00FFFFFF, true);
			
			sourceBmpData.fillRect(rect, 0xFF000000);
			// cutoff all green == 7f
			sourceBmpData.threshold(areasBmpData, rect, point, "==", 0xFF00FF00, 0xFF007F00, 0x00FFFFFF, false);

			// replace with blurthreshold filter
			BitmapUtils.blur(sourceBmpData, blurAmount, blurQuality);
			
			sourceBmpData.threshold(sourceBmpData, rect, point, ">", 128 - sensitivity << 8, 0xffffffff, 0x00FFFFFF, false);

			BitmapUtils.blur(sourceBmpData, softenAmount, softenQuality);
			metaBmpData.copyChannel(sourceBmpData, rect, point, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);

			postPreview(sourceBmpData as MetaBitmapData);
		}
		
		override public function dispose():void
		{
			areasBmpData.dispose();
			areasBmpData = null;
			beforeBmpData.dispose();
			beforeBmpData = null;
			
			super.dispose();
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////

		public function takeShot(event:Event = null):void
		{
			copy = true;
		}

		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}