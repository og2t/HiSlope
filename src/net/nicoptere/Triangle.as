package net.nicoptere
{
	/**
	 * @author nicoptere
	 */
	import net.nicoptere.Point2D;
	import flash.geom.Point;
	
	public class Triangle 
	{
		public var p1:Point2D;
		public var p2:Point2D;
		public var p3:Point2D;
		
		public var center:Point = new Point();
		
		public function Triangle(p1:Point2D, p2:Point2D, p3:Point2D)
		{
			this.p1 = p1;
			this.p2 = p2;
			this.p3 = p3;	
		}
		
		
		public function getCenter():void
		{
			center.x = (p1.X + p2.X + p3.X) / 3;
			center.y = (p1.Y + p2.Y + p3.Y) / 3;
		}
	}
}
