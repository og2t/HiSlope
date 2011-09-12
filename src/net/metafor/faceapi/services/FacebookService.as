package net.metafor.faceapi.services
{
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import net.metafor.faceapi.FaceApi;
	
	public class FacebookService extends FaceService
	{
		private static const MAIN_URL		:String = "http://api.face.com/facebook/";
		
		public function FacebookService(a:FaceApi)
		{
			super(a);
		}
		
		public function get( uids : Array , fb_user : String , fb_session : String , format : String = "json" ) : void
		{
			var content:URLVariables = new URLVariables();
			content.api_key = api.apiKey;
			content.api_secret = api.apiSecret;
			content.uids = uids.toString();
			content.user_auth = "fb_user:"+fb_user+",fb_session:"+fb_session;
			
			var req:URLRequest = new URLRequest();
			req.url = MAIN_URL+"get."+format;
			req.method = URLRequestMethod.POST;
			req.data = content;
			
			call( req );
		}
	}
}