/*---------------------------------------------------------------------------------------------

	[AS3] PaletteMap
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
	v0.1	Born on 10/07/2009

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.filters
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import net.blog2t.util.ColorBlender;
	import net.blog2t.util.ColorUtils;
	
	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class PaletteMap
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var colorBlend:ColorBlender = new ColorBlender();

		private var _reds:Array = new Array(256);
		private var _greens:Array = new Array(256);
		private var _blues:Array = new Array(256);
		private var _alphas:Array;
		private var _values:Array = new Array();
	
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function PaletteMap() 
		{
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		public function discretize(colors:int):void
		{
			var lNorm:Number = (0xff + 1) / colors;
			var step:Number = 0xff / (colors - 1);
			var val:int;

			for(var i:uint = 0; i <= 0xff; i++)
			{
				val = int(i / lNorm) * step;

			    _reds[i] = val << 16;
			    _greens[i] = val << 8;
				_blues[i] = val;
			}
		}

		public function posterize(levels:int):void
		{
			var n:Number = 0xff / levels;
			var val:int;
			
			for (var i:int = 0; i <= 0xff; i++)
			{
				val = Math.round((i / 0xff) * levels) * n;
				_reds[i] = val << 16;
				_greens[i] = val << 8;
				_blues[i] = val;
				
				//trace("A", i, (val << 16 | val << 8 | val).toString(16));
			}
			
			for (var j:int = 0; j < levels; j++)
			{
				val = j * n;
				_values[j] = val << 16 | val << 8 | val;
				
				//trace("B", i, (val << 16 | val << 8 | val).toString(16));
			}
		}
		
		public function colorGrading(array:Array, steps:int = 256):void
		{
			colorBlend.mix(array, steps);
			
			var n:Number = 0xff / steps;
			
			for (var i:int = 0; i <= 0xff; i++)
			{
				var val:uint = colorBlend.gradientColors[i];	
				
				_reds[i] = val & 0xff0000;
				_greens[i] = val & 0x00ff00;
				_blues[i] = val & 0x0000ff;
			}
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		
		public function get reds():Array
		{
			return _reds;
		}
		
		public function get greens():Array
		{
			return _greens;
		}
		
		public function get blues():Array
		{
			return _blues;
		}
		
		public function get alphas():Array
		{
			return _alphas;
		}
		
		public function get values():Array
		{
			return _values;
		}
		
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}