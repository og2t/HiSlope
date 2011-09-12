package net.metafor.faceapi
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import net.metafor.faceapi.services.AccountService;
	import net.metafor.faceapi.services.FacebookService;
	import net.metafor.faceapi.services.RecognitionService;
	import net.metafor.faceapi.services.TagsService;
	
	/**
	 * 
	 * <code>AS3FaceReco</code> is an actionscript port from the face.com api. It contain the most of the methods from the nativ API. 
	 * Check the face.com documentation at <a href="http://dev.face.com">http://dev.face.com</a>
	 * 
	 * @author		Jean Nawratil
	 * @version		0.1 
	 * 
	 **/
	
	public class FaceApi extends EventDispatcher
	{
		private var _apiKey			:String = "";
		private var _apiSecret		:String = "";
				
		private var _recognitionService			:RecognitionService;
		private var _accountService				:AccountService;
		private var _tagsService				:TagsService;
		private var _facebookService			:FacebookService;
		
		public function FaceApi()
		{
			super();
		}
		
		
		/**
		 * The api key 
		 */		
		public function get apiKey() : String
		{
			return _apiKey;
		}
		
		public function set apiKey( value : String ) : void
		{
			_apiKey = value;
		}
		
		/**
		 * The api secret 
		 */
		public function get apiSecret():String
		{
			return _apiSecret;
		}

		public function set apiSecret( value : String ) : void
		{
			_apiSecret = value;
		}
		
		/**
		 * The service that include all the detection and recognition requests
		 */
		public function get recognitionService() : RecognitionService
		{
			if( !_recognitionService ) _recognitionService = new RecognitionService( this );
			return _recognitionService;
		}

		public function set recognitionService( service : RecognitionService ) : void
		{ 
			_recognitionService = service;
		}
		
		/**
		 * The service that include all account requests
		 */
		public function get accountService():AccountService
		{
			if( !_accountService ) _accountService = new AccountService( this );
			return _accountService;
		}

		public function set accountService( service : AccountService ):void
		{
			_accountService = service;
		}
		
		/**
		 * The service that include all the tags requests
		 */
		public function get tagsService():TagsService
		{
			if( !_tagsService ) _tagsService = new TagsService( this );
			return _tagsService;
		}

		public function set tagsService(value:TagsService):void
		{
			_tagsService = value;
		}
		
		/**
		 * A specific service for the facebook.get requests
		 */ 
		public function get facebookService():FacebookService
		{
			if( !_facebookService ) _facebookService = new FacebookService( this );
			return _facebookService;
		}
		
		
		public function set facebookService(value:FacebookService):void
		{
			_facebookService = value;
		}
		
		

	}
}