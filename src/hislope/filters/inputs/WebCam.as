/*---------------------------------------------------------------------------------------------

	[AS3] WebCam
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
	v0.1	Born on 06/04/2010

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.filters.inputs
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.StatusEvent;
	import flash.events.ActivityEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.utils.Timer;
	import hislope.filters.FilterBase;
	import hislope.display.MetaBitmapData;
	import hislope.events.HiSlopeEvent;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class WebCam extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		public static const MAX_WIDTH:int = 640;
		public static const MAX_HEIGHT:int = 480;

		private static const NAME:String = "WebCam";
		private static var PARAMETERS:Array = [
			{
				name: "cameraIndex",
				min: 0,
				type: "stepper"
			}, {
				name: "fps",
				current: 25,
				min: 0.1,
				max: 60,
				type: "number"
			}, {
				name: "cameraFPS",
				current: 30,
				min: 1,
				max: 40,
				type: "number"
			}, {
				name: "capFPS",
				current: false,
				type: "boolean"
			}, {
				name: "scale",
				label: "processing scale",
				current: 0.5,
				min: 0.1,
				max: 1.0,
				type: "number"
			}, {
				name: "autoFit",
				label: "auto fit width",
				current: true,
				type: "boolean"
			}, {
				name: "flipX",
				current: true,
				type: "boolean"
			}, {
				name: "flipY",
				current: false,
				type: "boolean"
			}, {
				name: "backgroundColor",
				type: "rgb"
			}, {
				label: "restart camera",
				callback: "restartCamera",
				type: "button"
			}, {
				name: "bandwidth",
				current: 16384,
				min: 0,
				max: 65535,
				type: "int"
			}, {
				name: "quality",
				label: "quality",
				current: 0,
				min: 0,
				max: 100,
				type: "int"
			}, {
				name: "compressFrames",
				label: "compress Frames",
				current: false,
				type: "boolean"
			}, {
				name: "keyFrameInterval",
				label: "keyframe interval",
				current: 1,
				min: 1,
				max: 48,
				type: "int"
			}, {
				name: "motionLevel",
				label: "motion level",
				current: 100,	//@100 it won't dispatch activity event (FP gains 100% on very speed)
				min: 0,
				max: 100,
				type: "int"
			}, {
				name: "motionTimeout",
				label: "motion timeout",
				current: 0,
				min: 0,
				max: 5000,
				type: "int"
			}, {
				name: "cameraFavourArea",
				label: "favour area",
				current: false,
				type: "boolean"
			}, {
				label: "show settings",
				callback: "showCameraSettings",
				type: "button"
			}
		];
		
		private static const DEBUG_VARS:Array = [
			"cameraName",
			"currentFPS",
			"cameraActivity",
			"activityDetected",
			"cameraWidth",
			"cameraHeight"
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var video:Video;
		private var camera:Camera;
		
		private var matrix:Matrix = new Matrix();
		private var timer:Timer;
		private var cameraBmpData:BitmapData;
		private var fullSizeBmpData:BitmapData;
		
		private var fullScale:Number;

		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var fps:int;
		public var cameraFPS:int;
		public var capFPS:Boolean;
		public var flipX:Boolean;
		public var flipY:Boolean;
		public var scale:Number;
		public var autoFit:Boolean;
		public var backgroundColor:uint;
		public var cameraIndex:int;
		public var cameraName:String;
		
		public var cameraWidth:int = WebCam.MAX_WIDTH;
		public var cameraHeight:int = WebCam.MAX_HEIGHT;
		
		public var currentFPS:Number;
		public var cameraFavourArea:Boolean;
		public var cameraActivity:Number;
		public var activityDetected:Boolean;
		
		public var motionLevel:int;
		public var motionTimeout:int;
		
		public var bandwidth:int;
		public var quality:int; 
		public var keyFrameInterval:int;
		public var compressFrames:Boolean;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function WebCam(OVERRIDE:Object = null)
		{
			const numCameras:int = Camera.names.length;

			cameraIndex = 0;
			if (numCameras == 1) setDefaultMacCam();

			// FIXME: hacky way of setting default params
			PARAMETERS[0].max = numCameras - 1;
			PARAMETERS[0].current = cameraIndex;

			video = new Video(cameraWidth, cameraHeight);
			fullScale = WIDTH / cameraWidth;
			
			init(NAME, PARAMETERS, OVERRIDE, DEBUG_VARS);
			
			cameraBmpData = new BitmapData(WebCam.MAX_WIDTH, WebCam.MAX_HEIGHT, false, backgroundColor);
			
			timer = new Timer(int(1000 / fps));
			timer.addEventListener(TimerEvent.TIMER, render);
		}
		
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.fillRect(metaBmpData.rect, backgroundColor);
			
			metaBmpData.draw(cameraBmpData, matrix, null, null, null, true);
			metaBmpData.fullSizeBmpData = cameraBmpData;
			
			postPreview(metaBmpData);
			
			currentFPS = camera.currentFPS;
			
			if (capFPS && currentFPS < fps)
			{
				fps = currentFPS;
				updateUI("fps", fps);
			}
		}
		
		
		public function restartCamera(event:Event = null):void
		{
			detachCamera();
			attachCamera();
			
			if (camera)
			{
				camera.setMotionLevel(motionLevel, motionTimeout);
				camera.setQuality(bandwidth, quality); 
				camera.setLoopback(compressFrames);
				camera.setKeyFrameInterval(keyFrameInterval);
			}
		}
		
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////

		private function attachCamera():void
		{
			cameraName = Camera.names[cameraIndex];
			camera = getCamera(cameraIndex);
			
			camera.setMode(cameraWidth, cameraHeight, cameraFPS, cameraFavourArea);
			camera.addEventListener(ActivityEvent.ACTIVITY, activityHandler);
			
			video.attachCamera(camera);
		}
		
		
		private function detachCamera():void
		{
			if (camera)	camera.removeEventListener(ActivityEvent.ACTIVITY, activityHandler);
			camera = null;
			video.attachCamera(camera);
		}
		
		
		private function getCamera(cameraIndex:int = -1):Camera
		{
			if (camera != null)
			{
				if (muted) showCameraSettings(null, SecurityPanel.PRIVACY);
				return camera;
			}
			
			camera = Camera.getCamera(cameraIndex != -1 ? cameraIndex.toString() : null);
			
			if (camera != null)
			{
				// Init camera
				camera.setMode(cameraWidth, cameraHeight, cameraFPS, cameraFavourArea);
				camera.addEventListener(StatusEvent.STATUS, onStatusChange);
				return camera;
				
			} else {
				// No camera found
				showCameraSettings();
				return new Camera();
			}
		}
		
		
		override public function start():void
		{
			trace("webcam start");
			attachCamera();
			timer.start();
		}
		
		
		override public function stop():void
		{
			trace("webcam stop");
			detachCamera();
			timer.stop();
		}
			
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		
		private function render(event:TimerEvent):void
		{
			cameraBmpData.draw(video);
			
			/*// check whether frames are the same
			videoCompareData.draw(videoHolder, compareMatrix);
			videoCompareData.draw(videoData, compareMatrix, null, BlendMode.DIFFERENCE);

			var numChangedPixel : uint = videoCompareData.threshold(videoCompareData, 
					COMPARE_DIMENSION, ZERO_POINT, ">=", 
					0x00380000, 0x20FF0000, 0x00FF0000);
			
			if (numChangedPixel > _pixelThreshold)
			{
				_lastVideoUpdate = now;
				videoData.draw(videoHolder);
			}*/
			
			dispatchEvent(new Event(HiSlopeEvent.INPUT_RENDERED));
		}
		
		
		override public function updateParams():void
		{
			matrix.identity();
			
			if (autoFit)
			{
				scale = fullScale;
				updateUI("scale", scale);
			}

			if (flipX || flipY)
			{
				var mirrorX:Number = flipX ? -1 : 1;
				var mirrorY:Number = flipY ? -1 : 1;
				
				var moveX:Number = flipX ? width : 0;
				var moveY:Number = flipY ? height : 0;
				
				matrix.scale(mirrorX * scale, mirrorY * scale);
				matrix.translate(moveX, moveY);
			} else {
				matrix.scale(scale, scale);
			}
			
			// TODO check if last value of cameraIndex is the same, if not call restartCamera 
			
			/*fitPreviewScale(scale);*/
			
			if (timer) timer.delay = int(1000 / fps);
			
			super.updateParams();
		}
		
		
		private function activityHandler(event:ActivityEvent):void
		{
			activityDetected = event.activating;
			cameraActivity = camera.activityLevel;
		}
		
		
		private function onStatusChange(event:StatusEvent):void
		{
			if (event.code == "Camera.Unmuted")
			{
				showCameraSettings();
			}
		}
		
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		
		public function get muted():Boolean
		{
			return camera == null || camera.muted || camera.name == null || camera.width == 0;
		}
		
		// HELPERS ////////////////////////////////////////////////////////////////////////////
		
		private function setDefaultMacCam():void
		{
			for (var i:int = 0; i < Camera.names.length; i++)
			{
				/* Finds default iSight webcam on a Mac */
				if (Camera.names[i] == "USB Video Class Video" || Camera.names[i] == "Built-in iSight")
				{
					cameraIndex = i;
					break;
				}
			}
		}
		
		
		public function showCameraSettings(event:Event = null, panel:String = SecurityPanel.CAMERA):void
		{
			Security.showSettings(panel);
		}
		
	}
}