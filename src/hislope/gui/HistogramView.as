/*---------------------------------------------------------------------------------------------

	[AS3] HistogramView
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
	v0.1	Born on 2009-08-02

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.gui
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import hislope.filters.FilterBase;
	import hislope.events.HiSlopeEvent;
	
	//import net.blog2t.minimalcomps.*;	/*Use Minimal Components+ in the first place*/
	import com.bit101.components.*;	/*Then default to original Minimal Components*/	
	/*import com.bit101.components.*;*/
	
	import net.blog2t.math.Range;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class HistogramView extends Sprite
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		public static const CHANGE_CHANNELS:String = "changeChannels";

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var filter:FilterBase;
		private var histogramBmp:Bitmap;
		
		private var panel:Panel;
		private var redRadio:RadioButton;
		private var greenRadio:RadioButton;
		private var blueRadio:RadioButton;
		private var alphaRadio:RadioButton;
		private var rgbRadio:RadioButton;
		
		private var activeChannel:int;
		private var position:Label;

		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function HistogramView(filter:FilterBase) 
		{
			this.filter = filter;
			
			activeChannel = 0x7;
			
			panel = new Panel(this);
			panel.name = "H" + filter.name;
			
			rgbRadio = new RadioButton(panel, 8, 8, "RGBA", true, toggleChannels);
			rgbRadio.name = "7";
			redRadio = new RadioButton(panel, 8, 22, "R", false, toggleChannels);
			redRadio.name = "1";
			greenRadio = new RadioButton(panel, 8, 36, "G", false, toggleChannels);
			greenRadio.name = "2";
			blueRadio = new RadioButton(panel, 8, 50, "B", false, toggleChannels);
			blueRadio.name = "4";
			/*alphaRadio = new RadioButton(panel, 8, 64, "A", false, toggleChannels);*/
			/*alphaRadio.name = "8";*/
			
			position = new Label(panel, 8, 80, "@ --");
			
			histogramBmp = new Bitmap(filter.histogram);
			addChild(histogramBmp);
			histogramBmp.x = 320 - histogramBmp.width;
			
			panel.setSize(histogramBmp.x - 1, 100);
			
			addEventListener(MouseEvent.MOUSE_OVER, mouseOver, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOut, false, 0, true);
		}
		

		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		
		private function toggleChannels(event:Event):void
		{
			activeChannel = int(event.currentTarget.name);
			filter.histogramChannels = activeChannel;
			dispatchEvent(new Event(HistogramView.CHANGE_CHANNELS));
		}
		
		
		private function mouseOver(event:MouseEvent):void
		{
			filter.addEventListener(HiSlopeEvent.FILTER_PROCESSED, getInfo, false, 0, true);
		}


		private function mouseOut(event:MouseEvent):void
		{
			filter.removeEventListener(HiSlopeEvent.FILTER_PROCESSED, getInfo);
			
			redRadio.label = "R";
			greenRadio.label = "G";
			blueRadio.label = "B";
			/*alphaRadio.label = "A";*/
		}

		
		private function getInfo(event:Event):void
		{
			var pos:Number = histogramBmp.mouseX;
			if (pos >= 0 && pos <= 0xff)
			{
				position.text = "px @ 0x" + pos.toString(16).toUpperCase();
				
				switch (activeChannel)
				{
					case 1:
						redRadio.label = "R " + filter.histogramData[0][pos];
						break;
					case 2:
						greenRadio.label = "G " + filter.histogramData[1][pos];
						break;
					case 4:
						blueRadio.label = "B " + filter.histogramData[2][pos];
						break;
					case 8:
						/*alphaRadio.label = "A " + filter.histogramData[3][pos];*/
						break;
					case 7:
						redRadio.label = "R " + filter.histogramData[0][pos];
						greenRadio.label = "G " + filter.histogramData[1][pos];
						blueRadio.label = "B " + filter.histogramData[2][pos];
						break;
					case 15:
						redRadio.label = "R " + filter.histogramData[0][pos];
						greenRadio.label = "G " + filter.histogramData[1][pos];
						blueRadio.label = "B " + filter.histogramData[2][pos];
						alphaRadio.label = "A " + filter.histogramData[3][pos];
						break;
				}
				
			} else {
				position.text = "px @ --";
			}
		}
		
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}