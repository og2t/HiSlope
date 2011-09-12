/*---------------------------------------------------------------------------------------------

	[AS3] NoiseDitherer
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

package hislope.filters.displace
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import hislope.filters.FilterBase;

	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.filters.DisplacementMapFilterMode;
	import flash.filters.DisplacementMapFilter;
	import net.blog2t.util.BitmapUtils;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class NoiseDitherer extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Noise Ditherer";
		private static const PARAMETERS:Array = [
			{
				name: "scale",
				current: 10.0,
				min: 0,
				max: 0xFF,
				type: "number"
			}, {
				name: "diffusion",
				current: 10.0,
				min: 0,
				max: 0x7F,
				type: "number"
			}, {
				name: "blur",
				current: 1.0,
				min: 0,
				max: 30,
				lock: true,
				type: "number"
			}, {
				name: "regenerateNoise",
				type: "boolean",
				current: true,
				lock: true
			}
		];
		
		private static const DEBUG_VARS:Array = [
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		private var noiseBmpData:BitmapData;
		
		private var displacementMapFilter:DisplacementMapFilter;
		private var componentX:uint = BitmapDataChannel.RED;
		private var componentY:uint = BitmapDataChannel.GREEN;
		private var mode:String = DisplacementMapFilterMode.CLAMP;
		private var color:uint = 0xFF000000;
	
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var scale:Number;
		private var _diffusion:Number;
		private var _blur:Number;
		public var regenerateNoise:Boolean;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function NoiseDitherer(OVERRIDEN:Object = null)
		{
			noiseBmpData = resultMetaBmpData.clone();
			
			displacementMapFilter = new DisplacementMapFilter(
				noiseBmpData,
				noiseBmpData.rect.topLeft,
				componentX,
				componentY,
				scale,
				scale,
				mode,
				color,
				(color >> 24 & 0xFF) / 0xFF
			);
			
			init(NAME, PARAMETERS, OVERRIDEN, DEBUG_VARS);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			if (regenerateNoise) renderNoise();
			
			metaBmpData.applyFilter(metaBmpData, rect, point, displacementMapFilter);
			
			postPreview(noiseBmpData);
		}
		
		private function renderNoise():void
		{
			var seed:int = int(Math.random() * int.MAX_VALUE);
			
			var low:uint = 0x80 - diffusion;
			var high:uint = 0x7F + diffusion;

			noiseBmpData.noise(seed, low, high, componentX | componentY, false);

			if (_blur > 1) BitmapUtils.blur(noiseBmpData, _blur, 2);
        }
		
		override public function updateParams():void
		{
			displacementMapFilter.scaleX = scale;
			displacementMapFilter.scaleY = scale;
		}
		
		public function set diffusion(value:Number):void
		{
			_diffusion = value;
			if (!regenerateNoise) renderNoise();
		}
		
		public function get diffusion():Number
		{
			return _diffusion;
		}
		
		public function set blur(value:Number):void
		{
			_blur = value;
			renderNoise();
		}
		
		public function get blur():Number
		{
			return _blur;
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}