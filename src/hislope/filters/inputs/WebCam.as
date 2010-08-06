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

		private static const MAX_WIDTH:int = 640;
		private static const MAX_HEIGHT:int = 480;

		private static const NAME:String = "WebCam";
		private static const PARAMETERS:Array = [
			{
				name: "fps",
				label: "fps",
				current: 25,
				min: 0.1,
				max: 60,
				type: "number"
			}, {
				name: "scale",
				label: "processing scale",
				current: 0.5,
				min: 0.1,
				max: 1.0,
				type: "number"
			}, {
				name: "mirrorMode",
				label: "mirror",
				current: false,
				type: "boolean"
			}, {
				name: "backgroundColor",
				label: "background color",
				type: "rgb"
			}, {
				label: "refresh camera",
				callback: "refreshCamera",
				type: "button"
			}, {
				name: "bandwidth",
				label: "bandwidth",
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
				callback: "showSettings",
				type: "button"
			}
		];
		
		private static const DEBUG_VARS:Array = [
			"cameraActivity",
			"activityDetected"
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var video:Video;
		private var camera:Camera;
		private var matrix:Matrix = new Matrix();
		private var timer:Timer;
		private var cameraBmpData:BitmapData;
		private var fullSizeBmpData:BitmapData;

		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var fps:int;
		public var mirrorMode:Boolean;
		public var scale:Number;
		public var backgroundColor:uint;
		
		public var cameraWidth:int = WebCam.MAX_WIDTH;
		public var cameraHeight:int = WebCam.MAX_HEIGHT;
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
						
			init(NAME, PARAMETERS, OVERRIDE, DEBUG_VARS);
			
			video = new Video(cameraWidth, cameraHeight);
			
			cameraBmpData = new BitmapData(WebCam.MAX_WIDTH, WebCam.MAX_HEIGHT, false, backgroundColor);
			
			// FIXME use timer or camera event here?
			timer = new Timer(int(1000 / fps));
			timer.addEventListener(TimerEvent.TIMER, render);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.fillRect(metaBmpData.rect, backgroundColor);
			metaBmpData.processingScale = scale;
			
			metaBmpData.draw(cameraBmpData, matrix, null, null, null, true);
			metaBmpData.fullSizeBmpData = cameraBmpData;
			
			getPreviewFor(metaBmpData);
		}
		
		public function refreshCamera():void
		{
			if (camera)
			{
				camera.setMode(cameraWidth, cameraHeight, fps, cameraFavourArea);
				camera.setMotionLevel(motionLevel, motionTimeout);
				camera.setQuality(bandwidth, quality); 
				camera.setLoopback(compressFrames);
				camera.setKeyFrameInterval(keyFrameInterval);
			}
		}
		
		public function showSettings():void
		{
			Security.showSettings(SecurityPanel.CAMERA);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////

		private function attachCamera():void
		{
			var index:int = 0;

			for (var i:int = 0; i < Camera.names.length; i++)
			{
				/* Finds default iSight webcam on a Mac */
				if (Camera.names[i] == "USB Video Class Video")
				{
					index = i;
					break;
				}
			}
			
			trace("GET CAMERA", Camera.names[index]);
			camera = getCamera(index);
			trace("CAMERA:", camera);
			
			camera.setMode(cameraWidth, cameraHeight, fps, cameraFavourArea);
			camera.addEventListener(ActivityEvent.ACTIVITY, activityHandler);
			
			video.attachCamera(camera);
		}
		
		private function getCamera(cameraIndex:int = -1):Camera
		{
			if (camera != null)
			{
				if (muted) Security.showSettings(SecurityPanel.PRIVACY);
				return camera;
			}
			
			camera = Camera.getCamera(cameraIndex != -1 ? cameraIndex.toString() : null);
			
			if (camera != null)
			{
				// Init camera
				camera.setMode(cameraWidth, cameraHeight, fps, cameraFavourArea);
				camera.addEventListener(StatusEvent.STATUS, onStatusChange);
				return camera;
				
			} else {
				// No camera found
				Security.showSettings(SecurityPanel.CAMERA);
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
			timer.stop();
		}
			
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		
		private function render(event:TimerEvent):void
		{
			cameraBmpData.draw(video);
			dispatchEvent(new Event(HiSlopeEvent.INPUT_RENDERED));
		}
		
		override public function updateParams():void
		{		
			matrix.identity();
			
			if (mirrorMode)
			{
				matrix.scale(-scale, scale);
				matrix.translate(width, 0);
			} else {
				matrix.scale(scale, scale);
			}
			
			/*fitPreviewScale(scale);*/
			
			if (timer) timer.delay = int(1000 / fps);
		}
		
		private function activityHandler(event:ActivityEvent):void
		{
			activityDetected = event.activating;
			cameraActivity = camera.activityLevel;
		}
		
		private function onStatusChange(event:StatusEvent):void
		{
			trace(event.code);
			
			if (event.code == "Camera.Unmuted")
			{
				// Shows all available cameras
				showSettings();
			}
		}
		
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
						
		public function get muted():Boolean
		{
			return camera == null || camera.muted || camera.name == null || camera.width == 0;
		}
		
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}