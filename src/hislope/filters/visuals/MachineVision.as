/*---------------------------------------------------------------------------------------------

	[AS3] MachineVision
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
	v0.1	Born on 09/07/2009

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.filters.visuals
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.text.TextField;

	import hislope.display.MetaBitmapData;
	import hislope.filters.FilterBase;
	import hislope.filters.PaletteMap;
	import net.blog2t.util.BitmapUtils;
	import net.blog2t.util.BlobDetection;
	import net.blog2t.util.Spotlight;
	
	import net.nicoptere.Delaunay;
	import net.nicoptere.Triangle;
	import net.nicoptere.Voronoi;
	import net.nicoptere.Point2D;
	
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
	
	import flash.utils.ByteArray;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class MachineVision extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Machine Vision";
		private static const PARAMETERS:Array = [
			{
				name: "radiusDeflation",
				label: "Radius Deflation",
				current: 1.0,
				min: 0.25,
				max: 1.5,
				type: "number"
			}, {
				name: "overlayOpacity",
				label: "Overlay Opacity",
				current: 0.5,
				min: 0.1,
				max: 1,
				type: "number"
			}, {
				name: "points",
				label: "Show points",
				current: true,
				type: "boolean"
			}, {
				name: "lines",
				label: "Show lines",
				current: true,
				type: "boolean"
			}, {
				name: "fills",
				label: "Show fills",
				current: false,
				type: "boolean"
			}, {
				name: "blur",
				label: "Blur",
				current: 1,
				min: 1,
				max: 50,
				type: "number"
			}, {
				name: "linesColor",
				label: "lines color",
				current: 0xff9f00,
				type: "rgb"
			}, {
				name: "pointsColor",
				label: "points color",
				current: 0xffffff,
				type: "rgb"
			}
		];
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		private var spotlight:Spotlight = new Spotlight();

		private var outline:Shape = new Shape();
		private var pts:Array;
		private var blobRects:Array = [];
		private var oversizedBlobRects:Array = [];
		private var infoArea:TextField = new InfoArea().textTF;
		private var matrix:Matrix = new Matrix();
	
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var radiusDeflation:Number;
		public var overlayOpacity:Number;
		public var points:Boolean;
		public var lines:Boolean;
		public var fills:Boolean;
		public var blur:Number;
		public var linesColor:uint;
		public var pointsColor:uint
		
		public var circleColor:uint = 0xffffff;
		public var centersColor:uint = 0xffcc00;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function MachineVision(OVERRIDE:Object = null)
		{
			spotlight.width = width;
			spotlight.height = height;
			spotlight.opacity = overlayOpacity;
			spotlight.on(0, blur, 0 ,0);
			
			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			outline.graphics.clear();
							
			spotlight.centerX += (metaBmpData.spot.x - spotlight.centerX) * 0.7;
			spotlight.centerY += (metaBmpData.spot.y - spotlight.centerY) * 0.7;
			spotlight.radius += (metaBmpData.spot.radius * radiusDeflation - spotlight.radius) * 0.7;
			
			outline.graphics.lineStyle(1.5, circleColor, 0.5);
			drawArc(outline.graphics, spotlight.centerX, spotlight.centerY, spotlight.radius, -60, 60);
			drawArc(outline.graphics, spotlight.centerX, spotlight.centerY, spotlight.radius, 120, 240);
			
			pts = [];

			var pt:Point2D;

			for each (var blobRect:Rectangle in metaBmpData.blobRects)
			{
				pt = new Point2D(blobRect.x + blobRect.width / 2, blobRect.y + blobRect.height / 2);
				var distance:int = Math.sqrt((spotlight.centerX - pt.X) * (spotlight.centerX - pt.X) + (spotlight.centerY - pt.Y) * (spotlight.centerY - pt.Y)); 
				if (distance < spotlight.radius) pts.push(pt);
			}
			
			if (lines) outline.graphics.lineStyle(1, linesColor, 0.25);
			else outline.graphics.lineStyle(0, 0, 0);
			
			if (lines || fills || points)
			{
				var delaunay:Array = Delaunay.Triangulate(pts);

				for (var i:int = 0; i < delaunay.length; i++)
				{
					var t:Triangle = (delaunay[i] as Triangle);
					t.getCenter();
					outline.graphics.beginFill(metaBmpData.getPixel(t.center.x, t.center.y), (fills) ? 1 : 0);
					outline.graphics.moveTo(t.p1.X, t.p1.Y);
					outline.graphics.lineTo(t.p2.X, t.p2.Y);
					outline.graphics.lineTo(t.p3.X, t.p3.Y);
					outline.graphics.lineTo(t.p1.X, t.p1.Y);
				}
				
				if (points)
				{
					outline.graphics.lineStyle(0, centersColor, 0.75);
					Voronoi.draw(delaunay, outline, points);
				}
			}
			
			outline.graphics.lineStyle(0, pointsColor, 0.75);

			if (points)
			{
				for each (pt in pts)
				{
					outline.graphics.drawCircle(pt.X, pt.Y, 0.5);
				}
				
				infoArea.text = pts.length + " PTS\n" + delaunay.length + " TRGS";
			}
			
			if (metaBmpData.eyes)
			{
				for each (var eyeRect:Rectangle in metaBmpData.eyes)
				{
					outline.graphics.drawCircle(eyeRect.x + eyeRect.width / 2, eyeRect.y + eyeRect.height / 2, (eyeRect.width + eyeRect.height) * 0.3);
				}
			}
			
			metaBmpData.draw(outline);
		
			spotlight.redraw();

			metaBmpData.draw(spotlight, null, null, BlendMode.LAYER);
			
			matrix.identity();
			matrix.translate(spotlight.centerX + spotlight.radius + 10, spotlight.centerY);
			
			metaBmpData.draw(infoArea, matrix);

			getPreviewFor(metaBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////

		override public function updateParams():void
		{
			spotlight.blur = blur;
			spotlight.opacity = overlayOpacity;
		}
		
		/**
		 * Draws an arc (a segment of a circle's circumference)
		 * @param g the graphics context to draw with
		 * @param x the center x-coordinate of the arc
		 * @param y the center y-coorindate of the arc
		 * @param radius the radius of the arc
		 * @param a0 the starting angle of the arc (in degrees)
		 * @param a1 the ending angle of the arc (in degrees)
		 */
		public static function drawArc(g:Graphics, x:Number, y:Number, radius:Number, a0:Number, a1:Number):void
		{
			a0 = a0 * Math.PI / 180;
			a1 = a1 * Math.PI / 180;
			
			var slices:Number = (Math.abs(a1 - a0) * radius) / 4;
			var a:Number, cx:Number = x, cy:Number = y;

			for (var i:uint = 0; i <= slices; ++i)
			{
				a = a0 + i * (a1 - a0) / slices;
				x = cx + radius * Math.cos(a);
				y = cy - radius * Math.sin(a);
				
				if (i == 0)
				{
					g.moveTo(x, y);
				} else {
					g.lineTo(x, y);
				}
			}
		}

		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}