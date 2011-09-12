/*---------------------------------------------------------------------------------------------

	[AS3] getURL
	=======================================================================================

	Copyright © 2008 blog2t.net
	All Rights Reserved.
	
	VERSION HISTORY:
	v0.1	Born on 2008-05-09

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package net.blog2t.net
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.net.navigateToURL;
	import flash.net.URLRequest;

	// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
	
	public function getURL(url:String, window:String = "_self"):void
	{
		var req:URLRequest = new URLRequest(url);

		trace("navigateToURL");

		try
		{
			navigateToURL(req, window);
		} 
		
		catch (event:Error)
		{
			trace("Navigate to URL failed: " + event.message);
		}
	}
}