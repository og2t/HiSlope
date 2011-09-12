/*---------------------------------------------------------------------------------------------

	[AS3] ChainFooter
	=======================================================================================

	Copyright (c) 2011 blog2t.net
	All Rights Reserved

	VERSION HISTORY:
	v0.1	Born on 2011-08-29

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.core
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.display.Sprite;
	import com.bit101.components.Label;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class ChainFooter extends Sprite
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		public static const WIDTH:int = 320;
		public static const HEIGHT:int = 20;

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		
		private var info:Label;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function ChainFooter()
		{
			setup();
		}

		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		
		public function dispose():void
		{
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		private function setup():void
		{
			graphics.beginFill(0x000000);
			graphics.drawRect(0, 0, WIDTH, HEIGHT);
			graphics.lineStyle(0, 0x888888);
			graphics.moveTo(0, 0);
			graphics.lineTo(WIDTH, 0);
			
			info = new Label(this, 10, 0, "HiSlope v0.8");
		}

		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		
		public function set status(value:String):void
		{
			info.text = value;
		}
		
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}