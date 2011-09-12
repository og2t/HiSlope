/*---------------------------------------------------------------------------------------------

	[AS3] VideoPlayer
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

package hislope.filters.inputs
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import hislope.display.MetaBitmapData;
	import flash.display.BitmapData;
	import flash.filters.BlurFilter;
	import hislope.filters.FilterBase;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.utils.Timer;
	import hislope.events.HiSlopeEvent;
	import hislope.controllers.VideoFile;
	import net.blog2t.util.print_r;
	
	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class VideoPlayer extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Video Player";
		private static var PARAMETERS:Array = [
			/*{
				name: "videoURL",
				label: "Select Video",
				type: "combo",
				current: 0,
				items: []
			}, */{
				name: "position",
				label: "position"
			}/*, {
				name: "videoRange",
				type: "range",
				min: 0,
				max: 1
			}*/,{
				name: "autoFit",
				label: "auto fit width",
				current: true,
				type: "boolean"
			}, {
				name: "mirrorMode",
				label: "mirror",
				current: false,
				type: "boolean"
			}, {
				label: "play / pause",
				callback: "togglePlay",
				type: "button"
			}, {
				label: "rewind video",
				callback: "rewind",
				type: "button"
			}
		];
		
		private static const DEBUG:Array = [
			"videoName",
			"videoTime",
			"bufferLength"
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var videoFile:VideoFile;
		private var matrix:Matrix = new Matrix();
		private var scale:Number = 1;
		private var videoFullScale:Number = 1;
		
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var videoURL:String;
		public var _position:Number;
		public var bufferLength:Number;
		public var mirrorMode:Boolean;
		public var autoFit:Boolean;
		/*public var videoRange:Number;*/
		public var videoName:String;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function VideoPlayer(OVERRIDE:Object = null)
		{
			init(NAME, PARAMETERS, OVERRIDE, DEBUG);
		}

		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		public function queueVideo(url:String, name:String):void
		{
		}

		public function addVideo(url:String, name:String):void
		{
			/*var numItems:int = PARAMETERS[0].items.length;
			PARAMETERS[0].items[numItems] = { label: name, value: url };*/
			
			videoFile = new VideoFile(url);
			videoFile.addEventListener(VideoFile.START, initVideo, false, 0, true);
			videoFile.addEventListener(Event.CHANGE, render, false, 0, true);
			
			this.videoName = name + " / " + url;
		}
		
		
		private function initVideo(event:Event):void
		{
			videoFullScale = WIDTH / videoFile.width;
			updateParams();
		}


		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.fillRect(metaBmpData.rect, 0x000000);
			
			metaBmpData.draw(videoFile.currentFrame, matrix, null, null, null, true);
			metaBmpData.fullSizeBmpData = videoFile.currentFrame;
			
			postPreview(metaBmpData);
		}

		
		override public function updateParams():void
		{
			matrix.identity();
			
			scale = autoFit ? videoFullScale : 1.0;

			if (mirrorMode)
			{
				matrix.scale(-scale, scale);
				matrix.translate(width, 0);
			} else {
				matrix.scale(scale, scale);
			}
			
			super.updateParams();
		}
		
		
		override public function start():void
		{
			videoFile.start();
			trace("video start");
			/*videoFile.addEventListener(Event.CHANGE, render, false, 0, true);*/
		}
		
		
		override public function stop():void
		{
			/*videoFile.removeEventListener(Event.CHANGE, render);*/
			videoFile.stop();
			trace("video stop");
		}
		
		
		public function togglePlay(event:Event = null):void
		{
			if (videoFile.isPlaying) stop(); else start();
		}
		
		
		public function rewind(event:Event = null):void
		{
			videoFile.scrubPercent(0);
		}
		
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		
		private function render(event:*):void
		{
			_position = videoFile.headPosition;
			updateUI("position", position);
			
			dispatchEvent(new Event(HiSlopeEvent.INPUT_RENDERED));
			
			bufferLength = Number(videoFile.bufferLengthPercent.toFixed(1));
		}

		
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		
		public function set position(value:Number):void
		{
			// current video
			if (videoFile) videoFile.scrubPercent(value);
		}
		
		
		public function get position():Number
		{
			return _position;
		}
		
		
		public function get videoTime():Number
		{
			if (videoFile) return videoFile.videoTime;
			return -1;
		}
		
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}