package net.metafor.faceapi.services
{
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.events.Event;
	
	import net.metafor.faceapi.FaceApi;
	import net.metafor.faceapi.events.FaceEvent;
	import net.metafor.faceapi.FaceResult;
	
	/**
	 * This class provide the methods to manage the tags 
	 * @author jeannawratil
	 * 
	 */	
	public class TagsService extends FaceService
	{
		private static const MAIN_URL		:String = "http://api.face.com/tags/";
		
		public function TagsService( a : FaceApi )
		{
			super( a );
		}
		
		public function add() : void
		{
			
		}
		
		public function get() : void
		{
			
		}
		
		public function unploadAndGet() : void
		{
			
		}		
		
		/**
		 * Save temporary ids to permanent uids.
		 *  
		 * @param tids
		 * @param uid
		 * @param label
		 * @param fb_user
		 * @param fb_session
		 * @param twitter_user
		 * @param twitter_password
		 * @param format
		 * 
		 */		
		
		public function save( tids : String , uid : String , label : String = "" , fb_user : String = "" , fb_session : String ="" , twitter_user : String = "" , twitter_password : String = "" , format : String = "json" ) : void
		{
			if (tids == "")
			{
				throw new Error("You can't save a tag without a valid tid.");
				return;
			}
			
			if (uid == "")
			{
				throw new Error("You can't save a tag without a valid uid.");
				return;
			}
			
			var content:URLVariables = new URLVariables();
			content.api_key = api.apiKey;
			content.api_secret = api.apiSecret;
			content.tids = tids;
			content.uid = uid;
			
			if( label != "" ) content.label = label;
			if( fb_user != "" && fb_session != "" ) content.user_auth = "fb_user:" + fb_user + ",fb_session:" + fb_session;
			if( twitter_user != "" && twitter_password != "" ) content.user_auth = "twitter_user:" + twitter_user + ",twitter_password:" + twitter_password;
			
			var req:URLRequest = new URLRequest();
			req.url = MAIN_URL + "save." + format;
			req.method = URLRequestMethod.POST;
			req.data = content;
			
			call( req );
		}
		
		public function remove() : void
		{
			
		}
		
	}
}