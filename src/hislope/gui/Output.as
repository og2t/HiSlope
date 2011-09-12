/*---------------------------------------------------------------------------------------------

	[AS3] Output
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
	v0.1	Born on 2009-10-26
	v0.2	Moved the content into Window
	v0.3	Added background tansparency chessboard and debug mode

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.gui
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import hislope.filters.FilterBase;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import net.blog2t.util.saveImage;
	
	/*import com.bit101.components.*;*/
	//import net.blog2t.minimalcomps.*;	/*Use Minimal Components+ in the first place*/
	import com.bit101.components.*;	/*Then default to original Minimal Components*/

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class Output extends Sprite
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private const LIGHT_COLOR:uint = 0xFFFFFF;
		private const DARK_COLOR:uint = 0xF0F0F0;

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		
		public var outputBitmap:Bitmap;
		private var window:Window;
		private var chessboardBmpData:BitmapData;
		private var chessboardUnderlay:Shape = new Shape();
		private var label:String;
		private var _scale:Number = 1;
		private var outputBmpData:BitmapData;
		private var saveButton:PushButton;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function Output(filterOrMetaBitmapData:*, label:String = "Output", smoothing:Boolean = true, debug:Boolean = true) 
		{
			if (filterOrMetaBitmapData is MetaBitmapData || filterOrMetaBitmapData is BitmapData)
			{
				outputBmpData = filterOrMetaBitmapData as BitmapData;
			}
			
			else if (filterOrMetaBitmapData is FilterBase)
			{
				outputBmpData = filterOrMetaBitmapData.resultMetaBmpData as BitmapData;
				(filterOrMetaBitmapData as FilterBase).storeResult = true;
			}

			outputBitmap = new Bitmap(outputBmpData);
			outputBitmap.smoothing = smoothing;
			this.label = label;

			if (debug)
			{
				if (outputBmpData.transparent) drawTransparencyBackground();
				window = new Window(this);
				window.content.addChild(chessboardUnderlay);
				window.content.addChild(outputBitmap);
				window.setSize(outputBitmap.width, outputBitmap.height + 20);
				window.hasMinimizeButton = true;
				window.draggable = true;
				window.shadow = false;
				setTitle();
				saveButton = new PushButton(window, outputBitmap.width - 102, 2, "SAVE AS .PNG", saveButtonHandler);
				saveButton.setSize(100, 16);
			} else {
				addChild(outputBitmap);
			}
		}

		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		private function drawTransparencyBackground():void
		{
			// TODO move too utils
			
			chessboardBmpData = new BitmapData(2, 2, false, 0xff0000);
			chessboardBmpData.setPixel(0, 0, LIGHT_COLOR);
			chessboardBmpData.setPixel(1, 1, LIGHT_COLOR);
			chessboardBmpData.setPixel(1, 0, DARK_COLOR);
			chessboardBmpData.setPixel(0, 1, DARK_COLOR);
		
			var matrix:Matrix = new Matrix();
			matrix.scale(10, 10);
			/*matrix.rotate(45 * Math.PI / 180);*/
			chessboardUnderlay.graphics.beginBitmapFill(chessboardBmpData, matrix);
			chessboardUnderlay.graphics.drawRect(0, 0, outputBitmap.width, outputBitmap.height);
			chessboardUnderlay.graphics.endFill();
		}
		
		
		private function setTitle():void
		{
			window.title = label + " @ " + int(outputBitmap.width / _scale) + "x" + int(outputBitmap.height / _scale) + " px (scaled " + _scale.toFixed(1) + "x)";
		}
		
		
		private function saveButtonHandler(event:Event):void
		{
			saveImage(outputBmpData);
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		
		public function set scale(value:Number):void
		{
			_scale = value;
			outputBitmap.scaleX = outputBitmap.scaleY = value;
			if (window) window.setSize(outputBitmap.width, outputBitmap.height + 20);
			saveButton.x = outputBitmap.width - 102;
			setTitle();
		}
		
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}