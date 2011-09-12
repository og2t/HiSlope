package net.metafor.faceapi.services
{
	import com.adobe.images.JPGEncoder;
	
	import flash.display.BitmapData;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.events.Event;
	
	import com.marsonstudio.util.UploadPostHelper;
	
	import net.metafor.faceapi.FaceApi;
	import net.metafor.faceapi.events.FaceEvent;
	import net.metafor.faceapi.FaceResult;
	import net.metafor.faceapi.types.DetectorType;
	
	/**
	 * This class provide the methods to detect and recognize users on pictures 
	 * @author Jean Nawratil
	 * @version 0.1
	 */	
	public class RecognitionService extends FaceService
	{
		private static const MAIN_URL		:String = "http://api.face.com/faces/";
		
		public function RecognitionService( a : FaceApi )
		{
			super( a );
		}
		
		/**
		 * Detect one or more faces on the image(s) passed on the url
		 * @param urls
		 * @param format
		 * 
		 */		
		public function detect( urls : Array , format : String = "json") : void
		{			
			var content:URLVariables = new URLVariables();
			content.api_key = api.apiKey;
			content.api_secret = api.apiSecret;
			content.urls = urls.toString();
			
			var req:URLRequest = new URLRequest();
			req.url = MAIN_URL  +"detect." + format;
			req.method = URLRequestMethod.POST;
			req.data = content;
			
			call( req );
		}
		
		/**
		 * Detect one or more faces on the uploaded image ( allow only one picture by call )
		 * @param image
		 * @param format
		 * 
		 */		
		public function uploadAndDetect( image : BitmapData , format : String = "json" , quality : int = 50) : void
		{
			var encoder:JPGEncoder = new JPGEncoder( quality );
			var bytes:ByteArray = encoder.encode( image );
			
			var content:Object = new Object();
			content.api_key = api.apiKey;
			content.api_secret = api.apiSecret;
			/*content.detector = DetectorType.AGRESSIVE;*/
			
			var req:URLRequest = new URLRequest();
			req.url = MAIN_URL + "detect." + format;
			req.contentType = 'multipart/form-data; boundary=' + UploadPostHelper.getBoundary();
			req.method = URLRequestMethod.POST;
			req.data = UploadPostHelper.getPostData( "img.jpg", bytes , content );
			
			call( req );
		}
		
		/**
		 * Recognize the faces of the uids on the image(s) passed on the url  
		 * @param urls
		 * @param uids
		 * @param format
		 * 
		 */		
		public function recognize( urls : Array , uids : Array , format : String = "json" ) : void
		{
			
			var content:URLVariables = new URLVariables();
			content.api_key = api.apiKey;
			content.api_secret = api.apiSecret;
			content.urls = urls.toString();
			content.uids = uids.toString();
			
			var req:URLRequest = new URLRequest();
			req.url = MAIN_URL + "recognize."+format;
			req.method = URLRequestMethod.POST;
			req.data = content;
			
			call( req );
		}
		
		/**
		 * Recognize the faces of the uids on the uploaded image( allow only one picture by call )
		 * @param image
		 * @param uids
		 * @param fb_user
		 * @param fb_session
		 * @param format
		 * 
		 */		
		public function uploadAndRecognize( image : BitmapData , uids : Array , fb_user : String = "" , fb_session : String ="" , format : String = "json" , quality : int = 50 ) : void
		{
			var encoder:JPGEncoder = new JPGEncoder( quality );
			var bytes:ByteArray = encoder.encode( image );
			
			var content:Object = new Object();
			content.api_key = api.apiKey;
			content.api_secret = api.apiSecret;
			content.uids = uids.toString();
			/*content.detector = DetectorType.AGRESSIVE;*/
			
			if( fb_user != "" && fb_session != "" ) content.user_auth = "fb_user:"+fb_user+",fb_session:"+fb_session;
			
			var req:URLRequest = new URLRequest();
			req.url = "http://api.face.com/faces/recognize."+format;
			req.contentType = 'multipart/form-data; boundary=' + UploadPostHelper.getBoundary();
			req.method = URLRequestMethod.POST;
			req.data = UploadPostHelper.getPostData( "img.jpg", bytes , content );
			
			call( req );
		}
		
		/**
		 * Train the index with one or more faces
		 * @param uids
		 * @param fb_user
		 * @param fb_session
		 * @param format
		 * 
		 */		
		public function train( uids : Array , fb_user : String = "" , fb_session : String ="" , format : String = "json" ) : void
		{
			var content:URLVariables = new URLVariables();
			content.api_key = api.apiKey;
			content.api_secret = api.apiSecret;
			content.uids = uids.toString();
			if( fb_user != "" && fb_session != "" ) content.user_auth = "fb_user:"+fb_user+",fb_session:"+fb_session;
			
			var req:URLRequest = new URLRequest();
			req.url = MAIN_URL+"train."+format;
			req.method = URLRequestMethod.POST;
			req.data = content;
			
			call( req );
		}
		
		/**
		 * Returns the current index status 
		 * @param uids
		 * @param fb_user
		 * @param fb_session
		 * @param format
		 * 
		 */		
		public function status( uids : Array , fb_user : String = "" , fb_session : String ="" , format : String = "json" ) : void
		{
			var content:URLVariables = new URLVariables();
			content.api_key = api.apiKey;
			content.api_secret = api.apiSecret;
			content.uids = uids.toString();
			if( fb_user != "" && fb_session != "" ) content.user_auth = "fb_user:"+fb_user+",fb_session:"+fb_session;
			
			var req:URLRequest = new URLRequest();
			req.url = MAIN_URL+"status."+format;
			req.method = URLRequestMethod.POST;
			req.data = content;
			
			call( req );
		}
	}
}