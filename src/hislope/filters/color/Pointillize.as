/*---------------------------------------------------------------------------------------------

	[AS3] Pointillize
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

package hislope.filters.color
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.display.Sprite;
	import hislope.display.MetaBitmapData;
	import hislope.filters.FilterBase;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class Pointillize extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Pointillize";
		private static const PARAMETERS:Array = [
			{
				name: "spread",
				label: "spread",
				current: 10,
				min: 5,
				max: 50,
				type: "number"
			}, {
				name: "maxSize",
				label: "max dot size",
				current: 5,
				min: 1,
				max: 50,
				type: "number"
			}, {
				name: "descendingOrder",
				label: "darker to brighter",
				type: "boolean",
				current: true
			}, {
				name: "clearBackground",
				label: "clear background",
				type: "boolean",
				current: false
			}
		];
		
		private static const DEBUG_VARS:Array = [
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		
		private var output:Sprite = new Sprite();
		
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var spread:Number;
		public var maxSize:int;
		public var descendingOrder:Boolean;
		public var clearBackground:Boolean;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function Pointillize(OVERRIDEN:Object = null)
		{
			init(NAME, PARAMETERS, OVERRIDEN, DEBUG_VARS);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			var pyRef:Number = 0;
			var px:int = 0;
			var py:int = 0;
			
			var particles:Array = [];

			while (py < metaBmpData.height)
			{
				px = Math.random() * spread;
			
				while (px < metaBmpData.width)
				{
					var p:Object = {};

					p.px = px + Math.random();
					p.py = py + Math.random();
					p.pc = metaBmpData.getPixel32(px, py);
					
					//TODO sort out size order
					p.pz = 1 + (1 - brightness(p.pc)) * maxSize;
					p.pa = 1.0;
					
					particles.push(p);
				
					px += Math.random() * spread;
					py = pyRef + Math.random() * spread;
				}
			
				py = pyRef += spread;
			}
			
			var sortMode:int = 0;
			if (descendingOrder) sortMode = Array.DESCENDING;
			
			particles.sortOn("pz", sortMode | Array.NUMERIC);
			
			output.graphics.clear();
			
			for each (p in particles)
			{
				output.graphics.beginFill(p.pc, p.pa);
				output.graphics.drawCircle(p.px, p.py, p.pz);
			}
			
			if (clearBackground) metaBmpData.clear();
			
			metaBmpData.lock();
			metaBmpData.draw(output);
			metaBmpData.unlock();
			
			postPreview(metaBmpData);
		}
		
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		private function brightness(col:uint):Number
		{
			var r:int = (col >> 16) & 0xff;
			var g:int = (col >> 8) & 0xff;
			var b:int = col & 0xff;
			
			/*return (0.299 * r + 0.587 * g + 0.114 * b) / 255;*/

			// HSP is more accurate, using weighted 3D space:
			return Math.sqrt(0.241 * Math.pow(r, 2) + 0.691 * Math.pow(g, 2) + 0.068 * Math.pow(b, 2)) / 255;
		}
	}
}