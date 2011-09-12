/*---------------------------------------------------------------------------------------------

	[AS3] FaceApiDetect
	=======================================================================================

	HiSlope toolkit copyright (c) 2008-2011 Tomek 'Og2t' Augustyn
	http://play.blog2t.net/HiSlope

	You are free to use this source code in any non-commercial project. 
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
	
	1. Detect a face in an image and get your temporary id (tid)
	2. Save the tid in your private namespace
	3. Conduct reconnaissance on another picture to compare it with the id stored

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.filters.services
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import hislope.filters.FilterBase;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	
	import flash.events.Event;
	
	import hislope.vo.faceapi.FaceFeatures;
	
	import net.metafor.faceapi.FaceApi;
	import net.metafor.faceapi.events.FaceEvent;
	import net.metafor.faceapi.utils.FaceXMLParser;
	
	import net.blog2t.util.print_r;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class FaceAPIDetect extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		public static const FEATURES_DETECTED:String = "featuresDetected";
		public static const NO_FEATURES_DETECTED:String = "noFeaturesDetected";
		public static const REQUEST_SUBMITTED:String = "requestSumbitted";
		public static const FACE_RECOGNIZED:String = "faceRecognized";
		public static const FACE_NOT_RECOGNIZED:String = "faceNotRecognized";

		private static const NAME:String = "face.com API";
		
		private const PARAMETERS:Array = [
			{
				name: "confidenceThreshold",
				label: "confidence threshold",
				current: 50,
				min: 0,
				max: 100,
				type: "int"
			}/*, {
				label: "detect",
				type: "button",
				callback: "detect"
			}*/, {
				label: "recognize",
				type: "button",
				callback: "recognizeFace"
			}, {
				name: "uid",
				current: "tomek",
				type: "input"
			}, {
				name: "nameSpace",
				current: "hislope",
				type: "input"
			}, {
				label: "tag",
				type: "button",
				callback: "tagImage"
			}
		];
		
		private const DEBUG_VARS:Array = [
		];
		
		[Embed(source="../../keys/face.com_API_key.txt", mimeType="application/octet-stream")]
		private const API_KEY:Class;
		
		[Embed(source="../../keys/face.com_API_secret.txt", mimeType="application/octet-stream")]
		private const API_SECRET:Class;

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		private var faceApi:FaceApi;
		
		private var canvasShape:Shape = new Shape();
		private const canvas:Graphics = canvasShape.graphics;
		
		private var sourceBmpData:BitmapData;
		public var submitBmpData:BitmapData;
		public var markedBmpData:BitmapData;
		
		public var faceFeatures:Vector.<FaceFeatures>;
		
		public var confidence:int = 0;
		public var responseXML:XML;
		
		private var featuresDetected:Boolean;
		private var submitted:Boolean = false;
	
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var tid:String;
		public var uidRecognized:String;
		public var confidenceThreshold:int;
		
		public var uid:String;
		public var nameSpace:String;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function FaceAPIDetect(OVERRIDEN:Object = null)
		{
			sourceBmpData = resultMetaBmpData.clone();
			submitBmpData = resultMetaBmpData.clone();
			markedBmpData = resultMetaBmpData.clone();
			
			faceApi = new FaceApi();
			faceApi.apiKey = String(new API_KEY());
			faceApi.apiSecret = String(new API_SECRET());
			
			featuresDetected = false;
			
			init(NAME, PARAMETERS, OVERRIDEN, DEBUG_VARS);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			sourceBmpData.draw(metaBmpData);
			
			if (featuresDetected)
			{
				metaBmpData.faceFeatures = faceFeatures;
				featuresDetected = false;
			}
			
			if (submitted)
			{
				submitted = false;
				metaBmpData.draw(submitBmpData);
			}
			
			postPreview(markedBmpData);
		}
		
		
		// uploads image and detect
		public function detect(event:Event = null):void
		{
			submitBmpData.draw(sourceBmpData);
			markedBmpData.draw(sourceBmpData);
			
			uploadAndDetect(submitBmpData);
			
			submitted = true;
		}
		
		
		public function recognizeFace(event:Event = null):void
		{
			submitBmpData.draw(sourceBmpData);
			markedBmpData.draw(sourceBmpData);
			
			submitted = true;
			
			uploadAndRecognize(submitBmpData, ["all@" + nameSpace]);
		}
		
		
		public function uploadAndDetect(bitmapData:BitmapData):void
		{
			tid = "";
			
			faceApi.recognitionService.addEventListener(FaceEvent.SUCCESS, onDetectSuccess);
			faceApi.recognitionService.uploadAndDetect(bitmapData, "xml", 50);
			/*faceApi.recognitionService.uploadAndDetect(bitmapData, "json", 50);*/
		}

		
		public function uploadAndRecognize(bitmapData:BitmapData, uids:Array):void
		{
			tid = "";
			uidRecognized = "";
			
			// So you can compare a new image, in this case with all tags registered in the namespace (all @ namespace).
			// You can also compare seuleument with a tag (eg. franck_ribery@nstuto).
			faceApi.recognitionService.addEventListener(FaceEvent.SUCCESS, onRecognitionSuccess);
			faceApi.recognitionService.uploadAndRecognize(bitmapData, uids , "", "", "xml", 50);
			/*faceApi.recognitionService.uploadAndRecognize(bitmapData, uids , "", "", "json", 50);*/
		}
		
		
		public function tagImage(event:Event = null):void
		{
			tag(uid, nameSpace);
		}


		public function tag(uid:String = "tomek", nameSpace:String = "hislope"):void
		{
			trace("TAG", uid + "@" + nameSpace);
			
			faceApi.tagsService.addEventListener(FaceEvent.SUCCESS, onTagSaved);
			
			//Save then your tid, in combination with the uid of your choice.
			//Comply with the following syntax: name@namespace
			faceApi.tagsService.save(tid, uid + "@" + nameSpace, "", "", "", "", "", "xml");
		}

		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		private function processDetectResponse(responseXML:XML):void 
		{
			/*trace("processDetectResponse", responseXML);*/
			
			if (!responseXML) return;
			
			var numFacesFound:int = responseXML..photo[0].tags.tag.length();
			
			trace("numFacesFound", numFacesFound);
			
			if (numFacesFound > 0)
			{
				faceFeatures = FaceXMLParser.parseXML(responseXML);
				
				tid = faceFeatures[0].tid;
				trace("uids:", faceFeatures[0].uids);
				trace("tid:", faceFeatures[0].tid);
				
				FaceXMLParser.drawFeaturePoints(faceFeatures[0], canvas, FaceXMLParser.POINT_FEATURES);
				markedBmpData.draw(canvasShape);
				
				dispatchEvent(new Event(FaceAPIDetect.FEATURES_DETECTED));
				
				featuresDetected = true;
				
			} else {
				dispatchEvent(new Event(FaceAPIDetect.NO_FEATURES_DETECTED));
			}
		}
		
		
		private function processRecognitionResponseJSON(responseJSON:*):void
		{
			trace(responseJSON, typeof responseJSON);
			
			/*print_r(responseJSON);*/
		}
		
		
		private function processRecognitionResponseXML(responseXML:XML):void
		{
			processDetectResponse(responseXML);
			
			/*trace("processRecognitionResponseXML", responseXML);*/

			if (responseXML..recognition[0])
			{
				confidence = responseXML..recognition[0].confidence;
				
				if (confidence > confidenceThreshold)
				{
					uidRecognized = String(responseXML..recognition[0].uid).split("@")[0];
					dispatchEvent(new Event(FaceAPIDetect.FACE_RECOGNIZED));
				}
			} else {
				dispatchEvent(new Event(FaceAPIDetect.FACE_NOT_RECOGNIZED));
			}
		}
		
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		
		private function onRecognitionSuccess(event:FaceEvent):void
		{
			faceApi.recognitionService.removeEventListener(FaceEvent.SUCCESS, onRecognitionSuccess);
			/*processRecognitionResponseXML(event.data);*/
			/*processRecognitionResponseJSON(event.data);*/
			processDetectResponse(event.data);
		}

		
		private function onDetectSuccess(event:FaceEvent):void
		{
			faceApi.recognitionService.removeEventListener(FaceEvent.SUCCESS, onDetectSuccess);
			processDetectResponse(event.data);
		}

		
		private function onTagSaved(event:FaceEvent):void
		{
			faceApi.tagsService.removeEventListener(FaceEvent.SUCCESS, onTagSaved);

			if (event.data..saved_tags != undefined)
			{
				trace("TAG SAVED", event.data.saved_tags);
				tid = "saved";
			}
		}
		
		// HELPERS ////////////////////////////////////////////////////////////////////////////
		
	}
}