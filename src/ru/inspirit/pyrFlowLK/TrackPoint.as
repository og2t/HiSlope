package ru.inspirit.pyrFlowLK
{
	import flash.geom.Point;
	
	/**
	 * @author Eugene Zatepyakin
	 */
	public final class TrackPoint extends Point
	{
		public var vx:Number;
		public var vy:Number;
		
		public var tracked:Boolean = false;
		
		public function TrackPoint(x:Number, y:Number)
		{
			super(x, y);
		}
	}
}
