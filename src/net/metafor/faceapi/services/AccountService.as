package net.metafor.faceapi.services
{
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import net.metafor.faceapi.FaceApi;
	
	/**
	 * This class provide methods to get specifics infos about the current Account 
	 * @author jeannawratil
	 * 
	 */	
	public class AccountService extends FaceService
	{
		private static const MAIN_URL		:String = "http://api.face.com/account/";
		
		public function AccountService( a : FaceApi )
		{
			super( a );
		}
		
		/**
		 * Returns all registres users ID's for an account's private namespace 
		 * @param namespaces
		 * @param format
		 * 
		 */		
		public function users( namespaces : Array , format : String = "json" ) : void
		{
			var content:URLVariables = new URLVariables();
			content.api_key = api.apiKey;
			content.api_secret = api.apiSecret;
			content.namespaces = namespaces.toString();
			
			var req:URLRequest = new URLRequest();
			req.url = MAIN_URL+"users."+format;
			req.method = URLRequestMethod.POST;
			req.data = content;
			
			call( req );
		}
		
		/**
		 * Returns current account's rate and namespace limits
		 * @param format
		 * 
		 */		
		public function limits( format : String = "json" ) : void
		{
			var content:URLVariables = new URLVariables();
			content.api_key = api.apiKey;
			content.api_secret = api.apiSecret;
			
			var req:URLRequest = new URLRequest();
			req.url = MAIN_URL+"limits."+format;
			req.method = URLRequestMethod.POST;
			req.data = content;
			
			call( req );
		}
	}
}