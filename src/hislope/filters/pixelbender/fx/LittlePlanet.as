/*---------------------------------------------------------------------------------------------

	[AS3] LittlePlanet
	=======================================================================================

	VERSION HISTORY:
	v0.1	Born on 09/07/2009

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.filters.pixelbender.fx
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

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class LittlePlanet extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Little Planet";
		private static const PARAMETERS:Array = [
			{
				name: "centerX",
				label: "center X",
				max: 1.0,
				step: 0.01
			}, {
				name: "centerY",
				label: "center Y",
				max: 1.0,
				step: 0.01
			}, {
				name: "longitude",
				max: 360.0,
				step: 0.5
			}, {
				name: "latitude",
				current: 90.0,
				max: 360.0,
				step: 0.5
			}, {
				name: "rotate",
				label: "rotation",
				min: -360.0,
				max: 360.0,
				step: 0.5
			}, {
				name: "zoom",
				current: 0.4,
				min: 0.1,
				max: 10.0,
				step: 0.01
			}, {
				name: "wrap",
				min: -2.0,
				max: 2.0,
				step: 0.01
			}, {
				name: "twist",
				min: -1.0,
				max: 1.0,
				step: 0.01
			}, {
				name: "bulge",
				min: -1.0,
				max: 1.0,
				step: 0.01
			}
		];

		[Embed("/pbj/LittlePlanet.pbj", mimeType="application/octet-stream")]
		private const pbjFile:Class;
		
		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var shaderFilter:ShaderFilter;
		private var shader:Shader;

		// PARAMETERS /////////////////////////////////////////////////////////////////////////

		public var latitude:Number;
		public var longitude:Number;
		public var centerX:Number;
		public var centerY:Number;
		public var rotate:Number;
		public var zoom:Number;
		public var wrap:Number;
		public var twist:Number;
		public var bulge:Number;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function LittlePlanet(newParams:Object = null)
		{
			
			shader = new Shader(new pbjFile() as ByteArray);
           	shaderFilter = new ShaderFilter(shader);
			
			init(NAME, PARAMETERS, newParams);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.applyFilter(metaBmpData, rect, point, shaderFilter);

			getPreviewFor(metaBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		override public function updateParams():void
		{
			shader.data.size.value = [320, 240];
			shader.data.outputSize.value = [320, 240];
			shader.data.latitude.value = [latitude];
			shader.data.longitude.value = [longitude];
			shader.data.center.value = [centerX, centerY];
			shader.data.rotate.value = [rotate];
			shader.data.zoom.value = [zoom];
			shader.data.wrap.value = [wrap];
			shader.data.twist.value = [twist];
			shader.data.bulge.value = [bulge];
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}