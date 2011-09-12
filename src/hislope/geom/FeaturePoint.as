/*---------------------------------------------------------------------------------------------

	[AS3] FeaturePoint
	=======================================================================================

	Copyright (c) 2010 blog2t.net
	All Rights Reserved

	VERSION HISTORY:
	v0.1	Born on 2010-11-03

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.geom
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.geom.Point;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class FeaturePoint extends Point
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		public static var autoIncrement:int = 0;

		public var vx:Number;
		public var vy:Number;

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var _id:String;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function FeaturePoint(x:Number, y:Number, id:String = "") 
		{
			super(x, y);
			
			if (id == "")
			{
				FeaturePoint.autoIncrement++;
				_id = FeaturePoint.autoIncrement.toString();
			} else {
				_id = id;
			}
		}

		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		
		public function get id():String
		{
			return _id;
		}
		
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}