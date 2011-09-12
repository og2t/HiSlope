/*---------------------------------------------------------------------------------------------

	[AS3] VideoFile
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
	v0.1	Born on 07/07/2009

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.controllers
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.EventDispatcher;
	import flash.display.MovieClip;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.media.Video;
	import flash.net.NetStream;
	import flash.net.NetConnection;
	import flash.events.StatusEvent;
	import flash.events.NetStatusEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	/*import hislope.controllers.IInputSource;*/

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class VideoFile extends EventDispatcher //implements IInputSource
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		public static const START:String = "start";
		public static const BUFFER_FULL:String = "bufferFull";
		public static const BUFFER_EMPTY:String = "bufferEmpty";
		
		public static const VIDEO_WIDTH:int = 320;
		public static const VIDEO_HEIGHT:int = 240;
		
		public static const VIDEO_FPS:int = 30;

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
	
		public var video:Video;
		private var stream:NetStream;
		private var connection:NetConnection;
		
		private var videoURL:String;
		
		private var timer:Timer;
		private var fps:Number;
		private var loop:Boolean;
		private var duration:Number;
		public var headPosition:Number;
		
		private var _width:Number;
		private var _height:Number;
		
		private var matrix:Matrix = new Matrix();

		public var _currentFrame:BitmapData;
		
		private var _loaded:Boolean = false;
		private var bufferSize:Number = 3;
		
		private var doOnceFull:Boolean = true;
		private var doOnceEmpty:Boolean = true;
		
		private var bufferCheckTimer:Timer;
		public var isPlaying:Boolean;

		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////

		public function VideoFile(videoURL:String, width:int = VIDEO_WIDTH, height:int = VIDEO_HEIGHT, fps:Number = VIDEO_FPS, loop:Boolean = true, smoothing:Boolean = false)
		{
			this.loop = loop;
			this.fps = fps;
			this.videoURL = videoURL;
			
			connection = new NetConnection();
			connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			connection.connect(null);
			
			stream = new NetStream(connection);
			stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);

			var metaDataListener:Object = new Object();
			metaDataListener.onMetaData = onMetaData;
			stream.client = metaDataListener;

			video = new Video();
			video.smoothing = smoothing;
			video.attachNetStream(stream);

			_width = width;
			_height = height;
						
			_currentFrame = new BitmapData(width, height, false, 0);
						
			bufferCheckTimer = new Timer(250, 0);
			bufferCheckTimer.addEventListener(TimerEvent.TIMER, checkBuffer);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		
		public function load(url:String = null):void
		{
			trace("loadVideo", url);
			
			stream.play(url);
			isPlaying = true;
			
			_loaded = true;
			
			bufferCheckTimer.start();
		}
		
		public function start():void
		{
			if (!_loaded)
			{
				load(videoURL);
			} else {
				resume();
			}
		}
		
		public function stop():void
		{
			pause();
		}
		
		public function play():void
		{
			stream.play();
			isPlaying = true;
		}	
				
		public function resume():void
		{
			stream.resume();
			isPlaying = true;
		}
		
		public function pause():void
		{
			stream.pause();
			isPlaying = false;
		}
		
		public function close():void
		{
			stream.close();
			bufferCheckTimer.stop();
		}
		
		public function scrubPercent(percent:Number):void
		{
			stream.seek(duration * percent);
		}
		
		public function get currentFrame():BitmapData
		{
			return _currentFrame;
		}
		
		public function dispose():void
		{
			//removeEventListener(TimerEvent.TIMER, render);

			video = null;
			_currentFrame.dispose();
			_currentFrame = null;
		}

		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		
		/**
		 *	Hmm, that's quite experimental... just to support firing native events.
		 *	Sometimes they just don't work.
		 *	
		 *	As usual, use with care.
		 */
		public function checkBuffer(event:TimerEvent):void
		{
			if (bufferLength > bufferSize * .9)
			{
				if (doOnceFull)
				{
					dispatchEvent(new Event(VideoFile.BUFFER_FULL));
					doOnceFull = false;
					doOnceEmpty = true;
				}
			} else if (bufferLength < 0.5)
			{
				if (doOnceEmpty)
				{
					dispatchEvent(new Event(VideoFile.BUFFER_EMPTY));
					doOnceEmpty = false;
					doOnceFull = true;
				}
			}
		}

		private function render(event:TimerEvent):void
		{
			/*trace(stream.currentFPS, stream.liveDelay, stream.time);*/
			
			_currentFrame.draw(video, matrix);
			
			dispatchEvent(new Event(Event.CHANGE));
			
			headPosition = stream.time / duration;
		}

		private function onMetaData(metadata:Object):void
		{	
			duration = metadata.duration;
			fps = metadata.framerate;
					
			_width = metadata.width;
			_height = metadata.height;

			/* FIXME:
			   re-setting dimensions on Video object won't work, need to set scale matrix to fix.
			*/
			
			// TODO move this shit to Video Player? or some cam input utils?
			// TODO keep original video here as fullSizeBitmap
			
			var hRatio:Number = _width / video.width;
			var vRatio:Number = _height / video.height;
			
			matrix.identity();
			matrix.scale(hRatio, vRatio);

			_currentFrame = new BitmapData(_width, _height, false, 0);
			
			dispatchEvent(new Event(VideoFile.START));
		}
		
		private function netStatusHandler(event:NetStatusEvent):void
		{
			switch (event.info.code)
			{
				case "NetStream.Play.Stop":
					if (loop) stream.seek(0);
				break;
				
				case "NetStream.Play.Start":
					checkFPS(stream.currentFPS);
					dispatchEvent(new Event(VideoFile.START));
				break;
				
				case "NetStream.Buffer.Empty":
					dispatchEvent(new Event(VideoFile.BUFFER_EMPTY));
				break;
				
				case "NetStream.Buffer.Full":
					dispatchEvent(new Event(VideoFile.BUFFER_FULL));
				break;
			}	
		}

		private function checkFPS(fps:Number = 0):void
		{
			if (fps <= 0)
			{
				setTimeout(checkFPS, 250, stream.currentFPS);
				return;
			}
			
			fps = 50;
			
			trace(stream.currentFPS, stream.liveDelay, stream.time);
			timer = new Timer(int(1000 / fps));
			timer.addEventListener(TimerEvent.TIMER, render);
			timer.start();
		}

		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		
		public function get bufferLength():Number
		{
			return stream.bufferLength;
		}
		
		public function get bufferLengthPercent():Number
		{
			return stream.bufferLength / bufferSize;
		}
		
		public function get percentLoaded():Number
		{
			return stream.bytesLoaded / stream.bytesTotal;
		}
		
		public function get width():Number
		{
			return _width;
		}
		
		public function get height():Number
		{
			return _height;
		}
		
		public function get loaded():Boolean
		{
			return _loaded;
		}
		
		public function get videoTime():int
		{
			return stream.time;
		}

		// HELPERS ////////////////////////////////////////////////////////////////////////////

		override public function toString():String
		{
			return "[VideoFile]";
		}
	}
}
