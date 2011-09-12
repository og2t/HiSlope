/*---------------------------------------------------------------------------------------------

	[AS3] BlinkDetector
	=======================================================================================

	Copyright (c) 2009 blog2t.net
	All Rights Reserved

	VERSION HISTORY:
	v0.1	Born on 2009-07-17

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.filters.detectors
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import flash.display.BitmapData;
	import hislope.filters.FilterBase;
	import net.blog2t.util.BlobDetection;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.display.Shape;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class BlinkDetector extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Blink Detector";
		private static const PARAMETERS:Array = [
			{
				name: "maxBlobs",
				label: "max number of blobs",
				current: 2,
				min: 1,
				max: 200,
				type: "uint"
			}, {
				name: "blobColor",
				label: "blob color",
				current: 0xffffff,
				type: "rgb"
			}, {
				name: "minBlobWidth",
				label: "min blob width",
				current: 20,
				min: 1,
				max: 50,
				type: "uint"
			}, {
				name: "minBlobHeight",
				label: "min blob height",
				current: 20,
				min: 1,
				max: 50,
				type: "uint"
			}, {
				name: "maxBlobWidth",
				label: "max blob width",
				current: 50,
				min: 1,
				max: 200,
				type: "uint"
			}, {
				name: "maxBlobHeight",
				label: "max blob height",
				current: 50,
				min: 1,
				max: 200,
				type: "uint"
			}
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		
		private var blobRects:Array = [];
		private var oversizedBlobRects:Array = [];
		private var outline:Shape = new Shape();
		
		private var leftEyePos:Point = new Point();
		private var rightEyePos:Point = new Point();
		
		private var sourceBmpData:BitmapData;
		
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var maxBlobs:int;
		public var blobColor:uint;
		public var maxBlobWidth:int;
		public var maxBlobHeight:int;
		public var minBlobWidth:int;
		public var minBlobHeight:int;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function BlinkDetector(newParams:Object = null)
		{
			sourceBmpData = resultMetaBmpData.clone();
			
			init(NAME, PARAMETERS, newParams);
		}

		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		
		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.roi = rect;
			metaBmpData.copyTo(sourceBmpData);
			
			blobRects = [];
			oversizedBlobRects = [];
			
			leftEyePos.x = leftEyePos.y = rightEyePos.x = rightEyePos.y = -1;

			metaBmpData.eyesBlink = false;
			
			if (!metaBmpData.motionAreasBmpData) return;
			
			BlobDetection.detect(metaBmpData.motionAreasBmpData as BitmapData, blobRects, blobColor, minBlobWidth, minBlobHeight, maxBlobWidth, maxBlobHeight, 10, oversizedBlobRects);
			
			outline.graphics.clear();
			
			var scale:Matrix = new Matrix();
			scale.scale(previewScale, previewScale);
			
			/*if (metaBmpData.fullSizeBmpData) metaBmpData.draw(metaBmpData.fullSizeBmpData, scale);*/
			
			// TODO better filtering
			// - match size
			// - match y position
			// - match x symmetry
			
			sourceBmpData.draw(outline);
			
			metaBmpData.leftEyePos = metaBmpData.rightEyePos = null;
			
			if (blobRects.length == 2)
			{
				if (metaBmpData.eyesArea)
				{
					outline.graphics.lineStyle(0, 0x00ff00, 1);

					var leftEye:Rectangle = blobRects[0].clone();
					var rightEye:Rectangle = blobRects[1].clone();
					var eyesArea:Rectangle = metaBmpData.eyesArea.clone();
				
					if (leftEye.x > rightEye.x)
					{
						var temp:Rectangle = leftEye.clone();
						rightEye = leftEye;
						leftEye = temp;
					}
					
					var positionConditionLeft:Boolean = leftEye.x + leftEye.width < eyesArea.x + eyesArea.width / 2;
					var positionConditionRight:Boolean = rightEye.x + rightEye.width / 2 > eyesArea.x + eyesArea.width / 2;
					
					var containsEyeLeft:Boolean = eyesArea.containsRect(leftEye);
					var containsEyeRight:Boolean = eyesArea.containsRect(rightEye);
					
					var horizontalAlignment:Boolean = Math.abs(leftEye.y - rightEye.y) < 30;
					
					var widthRatio:Number = leftEye.width / rightEye.width;
					if (widthRatio > 1) widthRatio = 1 / widthRatio;
			
					var heightRatio:Number = leftEye.height / rightEye.height;
					if (heightRatio > 1) heightRatio = 1 / heightRatio;

					var widthTolerance:Number = 0.6;
					var heightTolerance:Number = 0.6;
					
					var widthProximity:Boolean = widthRatio > widthTolerance;
					var heightProximity:Boolean = heightRatio > heightTolerance;
					
					if (
						// TODO check symmetry and l/r blob order
					
						positionConditionRight
						&& positionConditionLeft
						&& eyesArea
						&& containsEyeRight
						&& containsEyeLeft
						&& horizontalAlignment
						/*&& widthProximity*/
						/*&& heightProximity*/
					){				
						leftEyePos.x = leftEye.x + leftEye.width / 2;
						leftEyePos.y = leftEye.y + leftEye.height / 2;
						metaBmpData.leftEyePos = leftEyePos;//leftEye;
						/*metaBmpData.leftEyeRect = leftEye.clone();*/

						rightEyePos.x = rightEye.x + rightEye.width / 2;
						rightEyePos.y = rightEye.y + rightEye.height / 2;
						metaBmpData.rightEyePos = rightEyePos;//rightEye;
						/*metaBmpData.rightEyeRect = rightEye.clone();*/

						metaBmpData.eyesBlink = true;
						
						drawRect(leftEye, 0x00ff00);
						drawRect(rightEye, 0x00ff00);
						metaBmpData.draw(outline);
					}
				}
			}
			
			drawRect(metaBmpData.eyesArea, 0xffff00);
			
			drawBlobs(blobRects, 0x00ff00);
			drawBlobs(oversizedBlobRects, 0xff0000);
			
			sourceBmpData.draw(outline);
			postPreview(sourceBmpData);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		private function drawBlobs(blobsRectsArray:Array, color:uint = 0x00ff00):void
		{
			for each (var blobRect:Rectangle in blobsRectsArray)
			{
				drawRect(blobRect, color);
			}
		}
		
		private function drawRect(blobRect:Rectangle, color:uint):void
		{
			outline.graphics.lineStyle(0, color, 1);
			outline.graphics.drawRect(blobRect.x, blobRect.y, blobRect.width, blobRect.height);
		}
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}