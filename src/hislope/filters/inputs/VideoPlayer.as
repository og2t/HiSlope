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
	
	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class VideoPlayer extends FilterBase
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		private static const NAME:String = "Video Player";
		private static const PARAMETERS:Array = [
			{
				name: "position",
				label: "position"
			}, {
				name: "bufferLength",
				label: "buffer length",
				mode: "readonly"
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
				label: "restart",
				callback: "restart",
				type: "button"
			}
		];

		// MEMBERS ////////////////////////////////////////////////////////////////////////////

		private var videoFile:VideoFile;
		private var matrix:Matrix = new Matrix();
		private var scale:Number = 1;
		
		// PARAMETERS /////////////////////////////////////////////////////////////////////////
		
		public var position:Number;
		public var bufferLength:Number;
		public var mirrorMode:Boolean;
			
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function VideoPlayer(OVERRIDE:Object = null)
		{
						
			init(NAME, PARAMETERS, OVERRIDE);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////

		public function addVideo(url:String, name:String):void
		{
			videoFile = new VideoFile(url);//, name);
			//add to combo box with the name
			videoFile.addEventListener(Event.CHANGE, render, false, 0, true);
			videoFile.addEventListener(VideoFile.START, initVideo, false, 0, true);
		}
		
		private function initVideo(event:Event):void
		{
			scale = WIDTH / videoFile.width;
			updateParams();
		}

		override public function process(metaBmpData:MetaBitmapData):void
		{
			metaBmpData.fillRect(metaBmpData.rect, 0x000000);
			metaBmpData.processingScale = scale;
			
			metaBmpData.draw(videoFile.currentFrame, matrix, null, null, null, true);
			metaBmpData.fullSizeBmpData = videoFile.currentFrame;
			
			getPreviewFor(metaBmpData);
		}
		
		override public function updateParams():void
		{
			// current video
			/*if (videoFile) videoFile.scrub(position);*/
			
			matrix.identity();

			if (mirrorMode)
			{
				matrix.scale(-scale, scale);
				matrix.translate(width, 0);
			} else {
				matrix.scale(scale, scale);
			}
		}
		
		override public function start():void
		{
			videoFile.start();
			trace("video start");
			
			/*videoFile.addEventListener(VideoFile.BUFFER_EMPTY, hideBufferingIcon, false, 0, true);*/
			/*videoFile.addEventListener(VideoFile.BUFFER_FULL, showBufferingIcon, false, 0, true);*/
			/*videoFile.addEventListener(VideoFile.START, hideBufferingIcon, false, 0, true);*/
		}
		
		override public function stop():void
		{
			videoFile.stop();
			trace("video stop");
		}
		
		public function togglePlay():void
		{
			if (videoFile.isPlaying) stop(); else start();
		}
		
		public function restart():void
		{
			videoFile.scrub(0);
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		
		private function render(event:*):void
		{
			updateUI("position", videoFile.position);
			
			/*videoFile.position = position;*/
			
			dispatchEvent(new Event(HiSlopeEvent.INPUT_RENDERED));
			
			updateUI("bufferLength", videoFile.bufferLengthPercent);
			
		}
		
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}