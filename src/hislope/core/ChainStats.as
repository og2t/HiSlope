/*---------------------------------------------------------------------------------------------

	[AS3] ChainStats
	=======================================================================================

	Copyright (c) 2011 blog2t.net
	All Rights Reserved

	VERSION HISTORY:
	v0.1	Born on 2011-08-29

	USAGE:

	TODOs:

	DEV IDEAS:

	KNOWN ISSUES:

---------------------------------------------------------------------------------------------*/

package hislope.core
{
	// IMPORTS ////////////////////////////////////////////////////////////////////////////////

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.utils.getTimer;
	
	import com.bit101.components.Label;

	// CLASS //////////////////////////////////////////////////////////////////////////////////

	public class ChainStats extends Sprite
	{
		// CONSTANTS //////////////////////////////////////////////////////////////////////////

		public static const WIDTH:int = 320;
		public static const HEIGHT:int = 60;

		// MEMBERS ////////////////////////////////////////////////////////////////////////////
		
		private var info:Label;
		private var fps:Label;
		private var memory:Label;
		
		private var chainName:String;
		
		private var currentFPS:int;
		private var minFPS:int;
		private var maxFPS:int;
		
		private var prevTime:int;
		private var currentTime:int;
		
		private var maxMemory:Number;
		private var totalMemory:Number;

		private var fpsGraph:Sprite = new Sprite();
		private var memoryGraph:Sprite = new Sprite();
		
		private var graphBox:Sprite = new Sprite();
		private var graphOffset:uint;
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////////////////
		
		public function ChainStats(chainName:String = "Filter Chain")
		{
			this.chainName = chainName.toUpperCase();
			
			setup();
		}

		// PUBLIC METHODS /////////////////////////////////////////////////////////////////////
		
		public function dispose():void
		{
		}
		
		// PRIVATE METHODS ////////////////////////////////////////////////////////////////////
		
		private function setup():void
		{
			initGraph();

			info = new Label(this, 10, 0, chainName);
			fps = new Label(this, 10, 20, "FPS:");
			memory = new Label(this, 10, 35, "MEM:");
			
			prevTime = 0;
			minFPS = 60;
			maxFPS = 0;
			maxMemory = 0;
			currentTime = 0;
			
			totalMemory = System.totalMemory * 0.000000954;

			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		
		private function onEnterFrame(event:Event):void
		{
			currentFPS++;

			currentTime = getTimer();
			
			if (currentTime - 1000 > prevTime)
			{
				prevTime = currentTime;
				
				minFPS = Math.min(currentFPS, minFPS);
				maxFPS = Math.max(Math.max(currentFPS, maxFPS), stage.frameRate);
				fps.text = "FPS: " + currentFPS + "/" + stage.frameRate + "\t(" + minFPS + "-" + maxFPS + ")";

				var currentMemory:Number = Number((System.totalMemory * 0.000000954).toFixed(2));
				maxMemory = Math.max(currentMemory, maxMemory);
				memory.text = "MEM: " + currentMemory + "\t(max: " + maxMemory + ")";

				graphOffset++;

				fpsGraph.x--;
				fpsGraph.graphics.lineTo(graphOffset, 1 + (stage.frameRate - currentFPS));

				memoryGraph.x--;
				memoryGraph.graphics.lineTo(graphOffset, (totalMemory / currentMemory) * HEIGHT);
				
				currentFPS = 0;
			}
		}
		
		
		private function initGraph():void
		{
			graphOffset = 0;
			
			fpsGraph.x = WIDTH;
			memoryGraph.x = WIDTH;
			
			graphBox.graphics.beginFill(0x000000);
			graphBox.graphics.drawRect(0, 0, WIDTH, HEIGHT);
			graphBox.graphics.lineStyle(0, 0x888888);
			graphBox.graphics.moveTo(0, HEIGHT - 1);
			graphBox.graphics.lineTo(WIDTH, HEIGHT - 1);
			
			
			fpsGraph.graphics.lineStyle(1, 0xCC0000);
			fpsGraph.graphics.moveTo(0, HEIGHT);

			memoryGraph.graphics.lineStyle(1, 0xFFCC33);
			memoryGraph.graphics.moveTo(0, HEIGHT);

			addChild(graphBox);
			addChild(fpsGraph);
			addChild(memoryGraph);
			
			scrollRect = new Rectangle(0, 0, WIDTH, HEIGHT);
		}
		
		
		// EVENT HANDLERS /////////////////////////////////////////////////////////////////////
		// GETTERS & SETTERS //////////////////////////////////////////////////////////////////
		
		public function set status(value:String):void
		{
			info.text = chainName + ": " + value;
		}
		
		
		public function set chainTime(value:int):void
		{
			info.text = chainName + ": " + value + " ms";
		}
		
		
		// HELPERS ////////////////////////////////////////////////////////////////////////////
	}
}