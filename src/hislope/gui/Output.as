/*---------------------------------------------------------------------------------------------

	[AS3] Output
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
	import flash.display.DisplayObject;
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
		
		private var window:Window;
		
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
			
			window = new Window(this);
			window.content.addChild(outputBitmap);
			window.setSize(320, 240);
			window.hasMinimizeButton = true;
			window.title = label;
			window.draggable = true;
			window.shadow = false;
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}