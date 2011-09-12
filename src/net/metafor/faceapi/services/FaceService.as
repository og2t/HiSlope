package net.metafor.faceapi.services
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import net.metafor.faceapi.FaceApi;
	import net.metafor.faceapi.FaceResult;
	import net.metafor.faceapi.events.FaceEvent;
	
	/**
	 * This class provide the core interface for all the used service. 
	 *  
	 * @author jeannawratil
	 * 
	 */	
	public class FaceService extends EventDispatcher
	{		
		private var _loader		:URLLoader;
		
		private var _api		:FaceApi;
		
		public function FaceService( a : FaceApi )
		{
			api = a;
			setLoader();
		}
		
		private function setLoader() : void
		{
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, 					loaderCompleteHandler);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, 			ioErrorHandler);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			
		}
		
		
		protected function call( url : URLRequest ) : void
		{
			_loader.load( url );
		}
		
		/**	 
		 * Event Handlers
		 */
		
		private function loaderCompleteHandler( evt : Event ) : void
		{
			var result:*;
			
			if (evt.target.data.indexOf('<?xml version="1.0" encoding="utf-8"?>') == -1)
			{
				result = JSON.decode( evt.target.data );
			} else {
				result = new XML( evt.target.data );
			}
			
			dispatchEvent( new FaceEvent( FaceEvent.SUCCESS , result , evt.target.data , new FaceResult( result ) ));
		}
		
		private function ioErrorHandler( evt : IOErrorEvent ) : void
		{
			trace("IOError : " + evt );
		}
		
		private function securityErrorHandler( evt : SecurityErrorEvent ) : void
		{
			trace("SecurityError : " + evt );	
		}

		protected function get api():FaceApi
		{
			return _api;
		}

		protected function set api(value:FaceApi):void
		{
			_api = value;
		}

	}
}