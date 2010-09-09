package net.nicoptere
{
	/**
	 * @author nicoptere
	 */

	import flash.display.Shape;
	
	public class Voronoi 
	{	
		public static function draw(array:Array, clip:Shape = null, drawPoints:Boolean = true):void
		{	
			if (array.length < 3) return;
			
			var cx:Number;
			var cy:Number;
			var midX:Number;
			var midY:Number;
			
			for (var i:int = 0; i < array.length; i++)
			{
				var t:Triangle = array[i] as Triangle;
				
				cx = ( t.p1.X + t.p2.X + t.p3.X ) / 3;
				cy = ( t.p1.Y + t.p2.Y + t.p3.Y ) / 3;
				
				if (drawPoints) clip.graphics.drawCircle(cx, cy, 0.5);
				//clip.graphics.moveTo( cx, cy );
			
				midX = t.p1.X + ( t.p2.X - t.p1.X )/2;
				midY = t.p1.Y + ( t.p2.Y - t.p1.Y )/2;
				
				/*clip.graphics.lineStyle( 2, 0x0000CC );
				clip.graphics.drawCircle( t.p1.X + midX / 2, t.p1.Y + midY/2, 5 );*/
				
				//clip.graphics.lineTo(midX, midY);
				//clip.graphics.moveTo( cx, cy );
				midX = t.p2.X + ( t.p3.X - t.p2.X )/2;
				midY = t.p2.Y + ( t.p3.Y - t.p2.Y )/2;
				/*
				clip.graphics.lineStyle( 2, 0x00CC00 );
				clip.graphics.drawCircle( t.p2.X + midX / 2, t.p2.Y + midY/2, 5 );
				*/
				//clip.graphics.lineTo(midX, midY);
				//clip.graphics.moveTo( cx, cy );
				
				midX = t.p3.X + ( t.p1.X - t.p3.X )/2;
				midY = t.p3.Y + ( t.p1.Y - t.p3.Y )/2;
				/*
				clip.graphics.lineStyle( 2, 0xCC0000 );
				clip.graphics.drawCircle( t.p3.X + midX / 2, t.p3.Y + midY/2, 5 );
				*/
				//clip.graphics.lineTo(midX, midY);
				//clip.graphics.moveTo( cx, cy );
				
				/*
				clip.graphics.drawCircle( t.p2.X, t.p2.Y, 5 );
				clip.graphics.lineStyle( 2, 0xCC0000 );
				clip.graphics.drawCircle( t.p3.X, t.p3.Y, 5 );
				
				*/
			}
			
			
		}
	}
}
