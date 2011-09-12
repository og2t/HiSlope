/*---------------------------------------------------------------------------------------------

	[AS3] Bloom
	=======================================================================================

	HiSlope toolkit copyright (c) 2010 Tomek 'Og2t' Augustyn
	http://play.blog2t.net/hislope

	Bloom copyright 2010 Ben Hopkins 

	Licensed under the Apache License, Version 2.0 (the "License"); 
	you may not use this file except in compliance with the License. 
	You may obtain a copy of the License at 

		http://www.apache.org/licenses/LICENSE-2.0 

	Unless required by applicable law or agreed to in writing, software 
	distributed under the License is distributed on an "AS IS" BASIS, 
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
	See the License for the specific language governing permissions and 
	limitations under the License.

	VERSION HISTORY:
	v0.1	Born on 09/07/2009

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.filters.photo
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.display.Sprite;
	import hislope.display.MetaBitmapData;
	import hislope.filters.FilterBase;
	import flash.geom.ColorTransform;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.display.BitmapData;
	import flash.display.BlendMode;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class Bloom extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Bloom";
		private static const PARAMETERS:Array = [
			{
				name: "bufferFade",
				current: 0.11,
				type: "number",
				step: 0.01
			}, {
				name: "alpha",
				current: 0.5,
				type: "number",
				step: 0.01
			}, {
				name: "threshold",
				current: 1,
				type: "number",
				step: 0.01
			}, {
				name: "blur",
				label: "blur amount",
				min: 0,
				max: 20,
				current: 10,
				type: "number"
			}, {
				label: "clear buffer",
				callback: "clearBuffer",
				type: "button"
			}
		];
		
		private static const DEBUG_VARS:Array = [
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		
		private var colorTransform:ColorTransform = new ColorTransform();
		private var colorMatrix:ColorMatrixFilter = new ColorMatrixFilter([
			0.33, 0.59, 0.11, 0, 0,
			0.33, 0.59, 0.11, 0, 0,
			0.33, 0.59, 0.11, 0, 0,
			0, 0, 0, 1, 0
		]);
		private var blurFilter:BlurFilter;
		private var greyscaleBmpData:BitmapData;
		private var downsampledBmpData:BitmapData;
		private var bufferBmpData:BitmapData;
		
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var bufferFade:Number;
		public var alpha:Number;
		public var threshold:Number;
		public var blur:Number;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function Bloom(OVERRIDEN:Object = null)
		{
			bufferBmpData = resultMetaBmpData.clone();
			greyscaleBmpData = resultMetaBmpData.clone();
			downsampledBmpData = resultMetaBmpData.clone();
			
			init(NAME, PARAMETERS, OVERRIDEN, DEBUG_VARS);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.copyTo(downsampledBmpData);
			
			greyscaleBmpData.applyFilter(downsampledBmpData, rect, point, colorMatrix);
			downsampledBmpData.threshold(greyscaleBmpData, rect, point, "<", threshold * 0xFF, 0, 0x000000FF);
			downsampledBmpData.applyFilter(downsampledBmpData, rect, point, blurFilter);
			
			// fade buffer
			/*colorTransform.alphaMultiplier = bufferFade;
			colorTransform.redMultiplier = bufferFade;
			colorTransform.greenMultiplier = bufferFade;
			colorTransform.blueMultiplier = bufferFade;	
			bufferBmpData.draw(bufferBmpData, null, colorTransform);*/

			clearBuffer();
			
			colorTransform.alphaMultiplier = alpha;
			colorTransform.redMultiplier = 1;
			colorTransform.greenMultiplier = 1;
			colorTransform.blueMultiplier = 1;
			bufferBmpData.draw(downsampledBmpData, null, colorTransform);
			
			metaBmpData.draw(bufferBmpData, null, null, BlendMode.ADD, null, true);
			
			/*postPreview(metaBmpData);*/
			postPreview(bufferBmpData as BitmapData);
			/*postPreview(downsampledBmpData as BitmapData);*/
		}
		
		public function clearBuffer():void
		{
			bufferBmpData.fillRect(rect, 0x000000);
		}
		
		override public function updateParams():void
		{
			// update parameters if changed
			blurFilter = new BlurFilter(blur, blur, 3);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
	}
}