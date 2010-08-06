/*---------------------------------------------------------------------------------------------

	[AS3] Output
	=======================================================================================

	Copyright (c) 2009 blog2t.net
	All Rights Reserved

	VERSION HISTORY:
	v0.1	Born on 2009-10-26

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.gui
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import com.bit101.components.*;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class Output extends Sprite
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		
		private var outputLabel:Label;
		private var outputBmpData:MetaBitmapData;
		private var outputBitmap:Bitmap;
		private var label:String;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function Output(outputBmpData:MetaBitmapData, label:String = "output", stageInit:Boolean = true) 
		{
			if (stageInit) addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
			
			this.outputBmpData = outputBmpData;
			this.label = label;
		}

		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		public function init(event:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			outputBitmap = new Bitmap(outputBmpData);
			outputBitmap.smoothing = true;
			addChild(outputBitmap);
			
			if (label != "")
			{
				outputLabel = new Label(this, 0, 0, label);
				/*outputLabel.background = true;*/
			}
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		
		/*public function set smooting(value:Boolean):void
		{
			outputBitmap.smooting = value;
		}*/
		
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}