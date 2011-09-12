/*---------------------------------------------------------------------------------------------

	[AS3] RectUtils
	=======================================================================================

	Copyright (c) 2010 blog2t.net
	All Rights Reserved

	VERSION HISTORY:
	v0.1	Born on 2010-09-14

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package net.blog2t.util
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.geom.Rectangle;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class RectUtils
	{
		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		
		public static function normalize(rect:Rectangle, obj:*):Rectangle 
		{
			return new Rectangle(rect.x / obj.width, rect.y / obj.height, rect.width / obj.width, rect.height / obj.height);
		}
		
		public static function scale(rect:Rectangle, obj:*):Rectangle
		{
			return new Rectangle(rect.x * obj.width, rect.y * obj.height, rect.width * obj.width, rect.height * obj.height);
		}
		
		public static function scaleAlignTL(rect:Rectangle, obj:*):Rectangle
		{
			return new Rectangle(0, 0, rect.width * obj.width, rect.height * obj.height);
		}
		
	}
}