/*---------------------------------------------------------------------------------------------

	[AS3] HiSlopeLogo
	=======================================================================================

	Copyright (c) 2011 blog2t.net
	All Rights Reserved

	VERSION HISTORY:
	v0.1	Born on 2011-09-02

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.display
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import net.blog2t.net.getURL;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class HiSlopeLogo extends Sprite
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		[Embed(source="../../../assets/assets.swf", symbol="Logo")]
		private const HiSlopeLogoAsset:Class;

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		
		private var logo:Sprite = new HiSlopeLogoAsset();
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function HiSlopeLogo() 
		{
			addChild(logo);
			logo.buttonMode = true;
			logo.addEventListener(MouseEvent.CLICK, onLogoClick, false, 0, true);
		}

		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		
		public function setPosition(posX:Number, posY:Number):void
		{
			logo.x = posX;
			logo.y = posY;
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		
		private function onLogoClick(event:MouseEvent):void
		{
			getURL("http://play.blog2t.net/HiSlope", "_blank");
		}
		
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}