/*---------------------------------------------------------------------------------------------

	[AS3] Levels
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

package hislope.filters.pixelbender
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import flash.events.Event;
	import flash.display.BitmapData;
	import flash.display.Shader;
	import net.blog2t.util.ColorUtils;
	import hislope.filters.FilterBase;
	import flash.filters.ShaderFilter;
	import flash.utils.ByteArray;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class Levels extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Levels";
		private static const PARAMETERS:Array = [
			{
				name: "luminanceMin",
				label: "luminance min",
				current: 0,
				min: 0,
				max: 1,
				type: "number"
			}, {
				name: "luminanceMax",
				label: "luminance Max",
				current: 1,
				min: 0,
				max: 1,
				type: "number"
			}, {
				name: "redMin",
				label: "red min",
				current: 0,
				min: 0,
				max: 1,
				type: "number"
			}, {
				name: "redMax",
				label: "red Max",
				current: 1,
				min: 0,
				max: 1,
				type: "number"
			}, {
				name: "greenMin",
				label: "green min",
				current: 0,
				min: 0,
				max: 1,
				type: "number"
			}, {
				name: "greenMax",
				label: "green Max",
				current: 1,
				min: 0,
				max: 1,
				type: "number"
			}, {
				name: "blueMin",
				label: "blue min",
				current: 0,
				min: 0,
				max: 1,
				type: "number"
			}, {
				name: "blueMax",
				label: "blue Max",
				current: 1,
				min: 0,
				max: 1,
				type: "number"
			}, {
				name: "autoLevels",
				label: "auto levels",
				current: true
			}, {
				name: "numPixels",
				label: "num pixels threshold",
				current: 0,
				min: 0,
				max: 20,
				type: "int"
			}/*, {
							name: "rectX",
							label: "rectX",
							current: 0,
							min: 0,
							max: 320,
							type: "int"
						}, {
							name: "rectY",
							label: "rectY",
							current: 0,
							min: 0,
							max: 240,
							type: "int"
						}, {
							name: "rectWidth",
							label: "rectWidth",
							current: 0,
							min: 0,
							max: 320,
							type: "int"
						}, {
							name: "rectHeight",
							label: "rectHeight",
							current: 0,
							min: 0,
							max: 240,
							type: "int"
						}, {
							name: "pointX",
							label: "pointX",
							current: 0,
							min: 0,
							max: 320,
							type: "int"
						}, {
							name: "pointY",
							label: "pointY",
							current: 0,
							min: 0,
							max: 240,
							type: "int"
						}*/
		];

		private static const DEBUG_VARS:Array = [
			/*"redMin", "redMax",
			"greenMin", "greenMax",
			"blueMin", "blueMax"*/
		];

		[Embed("../../pbj/Levels.pbj", mimeType="application/octet-stream")]
		private const pbjFile:Class;
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var shaderFilter:ShaderFilter;
		private var shader:Shader;
		private var channelIndexes:Array = [
				["redMin", "redMax"],
				["greenMin", "greenMax"],
				["blueMin", "blueMax"]
		];

		// PARAMETERS /////////////////////////////////////////////////////////////////////////

		public var luminanceMin:Number;
		public var luminanceMax:Number;
		public var redMin:Number;
		public var redMax:Number;
		public var greenMin:Number;
		public var greenMax:Number;
		public var blueMin:Number;
		public var blueMax:Number;
		public var autoLevels:Boolean;
		public var numPixels:Number;
		
		public var rectX:int;
		public var rectY:int;
		public var rectWidth:int;
		public var rectHeight:int;
		public var pointX:int;
		public var pointY:int;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function Levels(OVERRIDE:Object = null) 
		{
			shader = new Shader(new pbjFile() as ByteArray);
           	shaderFilter = new ShaderFilter(shader);
			
			init(NAME, PARAMETERS, OVERRIDE, DEBUG_VARS);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			if (autoLevels)
			{
				getHistogramDataFor(metaBmpData);
				findThresholds();
				updateParams();
			}
			
			/*metaBmpData.applyShader(shaderFilter);*/
			metaBmpData.applyFilter(metaBmpData, rect, point, shaderFilter);
			/*metaBmpData.applyFilter(metaBmpData, new Rectangle(rectX, rectY, rectWidth, rectHeight), new Point(pointX, pointY), shaderFilter);*/

			/*getPreviewFor(metaBmpData);*/
			getPreviewFor(metaBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////

		private function findThresholds():void
		{
			for (var c:int = 0; c < 3; c++)
			{
				this[channelIndexes[c][0]] = 0;
				var i:int = 0;
			
				while (i < 256)
				{
					if (histogramData[c][i] > numPixels)
					{
						this[channelIndexes[c][0]] = i / 256;
						updateUI(channelIndexes[c][0], i / 256);
						break;
					}
					i++;
				}

				this[channelIndexes[c][1]] = 1;
				i = 255;
				
				while (i > 0)
				{
					if (histogramData[c][i] > numPixels)
					{
						this[channelIndexes[c][1]] = i / 256;
						updateUI(channelIndexes[c][1], i / 256);
						break;
					}
					i--;
				}
			}
		}
		
		override public function updateParams():void
		{
			shader.data.luminance.value = [luminanceMin, luminanceMax];
			shader.data.red.value = [redMin, redMax];
			shader.data.green.value = [greenMin, greenMax];
			shader.data.blue.value = [blueMin, blueMax];
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}