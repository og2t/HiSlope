/*---------------------------------------------------------------------------------------------

	[AS3] SpotMotion
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

package hislope.filters.motion
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.BlendMode;
	import flash.geom.Rectangle;

	import hislope.display.MetaBitmapData;
	import hislope.filters.FilterBase;
	import net.blog2t.util.Spotlight;
	import net.blog2t.util.BitmapUtils;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class SpotMotion extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Spot Motion";
		private static const PARAMETERS:Array = [
			{
				name: "blur",
				label: "Blur",
				current: 2,
				min: 0,
				max: 50,
				type: "number"
			}, {
				name: "opacity",
				label: "Opacity",
				current: 0.5,
				min: 0,
				max: 1,
				type: "number"
			}, {
				name: "color",
				label: "Overlay colour",
				current: 0x000000,
				min: 0x0,
				max: 0xFFFFFF,
				type: "rgb"
			}, {
				name: "blendMode",
				label: "Blend mode",
				current: 0,
				min: 0,
				max: 10,
				type: "uint"
			}
		];

		private const blendModes:Array = [
			BlendMode.LAYER,
			BlendMode.ADD,
			BlendMode.DARKEN,
			BlendMode.DIFFERENCE,
			BlendMode.HARDLIGHT,
			BlendMode.INVERT,
			BlendMode.LIGHTEN,
			BlendMode.MULTIPLY,
			BlendMode.OVERLAY,
			BlendMode.SCREEN,
			BlendMode.SUBTRACT
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		private var spotlight:Spotlight = new Spotlight();
		private var centerDestX:Number = 0;
		private var centerDestY:Number = 0;
		private var radiusDest:Number = 0;
		private var sourceBmpData:MetaBitmapData;
	
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var blur:Number;
		public var opacity:Number;
		public var color:uint;
		public var blendMode:uint;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function SpotMotion(OVERRIDE:Object = null)
		{
			spotlight.width = width;
			spotlight.height = height;
			spotlight.on();
			
			sourceBmpData = resultMetaBmpData.cloneAsMeta();
			
			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			//metaBmpData.copyTo(sourceBmpData);
			
			spotlight.centerX += (centerDestX - spotlight.centerX) * 0.5;
			spotlight.centerY += (centerDestY - spotlight.centerY) * 0.5;
			spotlight.radius += (radiusDest - spotlight.radius) * 0.5;

			if (metaBmpData.spot)
			{
				spotlight.centerX = metaBmpData.spot.x;
				spotlight.centerY = metaBmpData.spot.y;
				spotlight.radius = metaBmpData.spot.radius;
			}
			
			else if (metaBmpData.faceRect)
			{
				if (!metaBmpData.faceRect.isEmpty())
				{
					centerDestX = metaBmpData.faceRect.x + metaBmpData.faceRect.width / 2;
					centerDestY = metaBmpData.faceRect.y + metaBmpData.faceRect.height / 2;
					radiusDest = Math.max(metaBmpData.faceRect.width, metaBmpData.faceRect.height) / 2;
				} else {
					radiusDest = 0;
				}
			}
			
			spotlight.redraw();
			
			metaBmpData.draw(spotlight, null, null, blendModes[int(blendMode)]);
			
			postPreview(metaBmpData);
			/*postPreview(sourceBmpData);*/
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////

		override public function updateParams():void
		{
			spotlight.blur = blur;
			spotlight.opacity = opacity;
			spotlight.color = color;
			
			super.updateParams();
		}

		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}