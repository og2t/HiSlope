package net.metafor.faceapi.auth
{	
	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.hash.HMAC;
	import com.hurlant.util.Base64;
	import com.hurlant.util.Hex;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * This class provide an easiest integration for the OAuth authentification. Allow only the pin-workflow.
	 * Inspired by sandro ducceschi oauth lib, thx to him.
	 * 
	 *  @author Jean Nawratil
	 */
	
	public class OAuth extends EventDispatcher
	{
		private var _loader				:URLLoader;
		private var _consumer_key		:String = "";
		private var _consumer_secret	:String = ""
		private var _props				:Object = {};
		private var _requestTokenOK		:Boolean = false;
		private var _url				:String = "";
		
		//URL CONST 
		public static const HOSTNAME_URL			:String = "https://api.twitter.com";
		public static const REQUEST_TOKEN_URL		:String = "/oauth/request_token";
		public static const ACCESS_TOKEN_URL		:String = "/oauth/access_token";
		public static const AUTHORIZE_URL			:String = "/oauth/authorize";
		
		
		public function OAuth()
		{
			super();
			init();
		}
		
		private function init() : void
		{
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE , onCompleteHandler );
			_loader.addEventListener( HTTPStatusEvent.HTTP_STATUS , httpStatusHandler );
			_loader.addEventListener( IOErrorEvent.IO_ERROR , ioErrorHandler );
			_loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR , securityErrorHandler );
			
			
		}
		
		/**
		 * Request the token required from the authentification
		 */
		public function requestToken() : void
		{
			_url = HOSTNAME_URL + REQUEST_TOKEN_URL;
			
			_props.oauth_nonce 				= getNonce();
			_props.oauth_timestamp 			= getTimestamp();
			_props.oauth_consumer_key 		= consumer_key;
			_props.oauth_signature_method 	= "HMAC-SHA1";
			
			_props.oauth_version			= "1.0";
			_props.oauth_callback 			= "oob"
			
			
			//------------------------SIGNATURE--------------------------------//
			_props.oauth_signature = getSignature();
			
			//------------------------PARAMTERS---------------------------------//
			var params:String = "";
			for( var j:* in _props )
			{
				params += j;
				params += "=";
				params += encodeURIComponent( _props[ j ].toString() )+"&";
			}
			params = params.substring( 0 , params.length - 1 );			
			
			//------------------------REQUEST-------------------------------------//
			var urlToReq:String = _url + "?" + params;
			var req:URLRequest = new URLRequest( urlToReq );
			
			
			_loader.load( req );
		}
		
		public function requestAccess( pincode : String ) : void
		{
			_url = HOSTNAME_URL + ACCESS_TOKEN_URL;
			
			_props.oauth_nonce 				= getNonce();
			_props.oauth_timestamp 			= getTimestamp();
			_props.oauth_consumer_key 		= consumer_key;
			_props.oauth_signature_method 	= "HMAC-SHA1";
			_props.oauth_verifier			= pincode;
			
			_props.oauth_version			= "1.0";
			//_props.oauth_callback 		= "oob"
			delete( _props.oauth_callback );
			
			//------------------------SIGNATURE--------------------------------//
			_props.oauth_signature = getSignature();
			
			//------------------------PARAMTERS---------------------------------//
			var params:String = "";
			for( var j:* in _props )
			{
				params += j;
				params += "=";
				params += encodeURIComponent( _props[ j ].toString() )+"&";
			}
			params = params.substring( 0 , params.length - 1 );			
			
			//------------------------REQUEST-------------------------------------//
			var urlToReq:String = _url + "?" + params;
			var req:URLRequest = new URLRequest( urlToReq );
			
			
			_loader.load( req );
		}
		
		public function prepareBaseSignature() : String
		{
			var _params:Array = new Array();
			for (var j:String in _props) 
			{
				  if (j != "oauth_signature" && j != "oauth_token_secret") _params.push( j + "=" + encodeURIComponent( _props[j].toString()) );
			}
			
			_params.sort();
			            
			var aJoin:String = _params.join("&");
			
			var toCrypt:String = encodeURIComponent("GET") + "&" + encodeURIComponent( _url ) + "&" + encodeURIComponent( aJoin );
			
			
			return toCrypt;
		}
		
		
		private function getSignature() : String
		{
			var toBeSigned:String = "";
			for( var i:String in _props )
			{
				if (i != "oauth_signature" && i != "oauth_token_secret" )
				{
					toBeSigned += i;
					toBeSigned += "=";
					toBeSigned += encodeURIComponent( _props[ i ].toString() )+"&";	
				}
				
			}
			toBeSigned = toBeSigned.substring( 0 , toBeSigned.length - 1 );
			
			var key:String;
			if( _props.oauth_token_secret != null && _props.oauth_token_secret != undefined && _props.oauth_token_secret != "" )
			{
				key = encodeURIComponent( consumer_secret )+"&"+encodeURIComponent( _props.oauth_token_secret );
			}else
			{
				key = encodeURIComponent( consumer_secret )+"&";
			}	
			
			var hmac:HMAC = Crypto.getHMAC("sha1");
            var keyer:ByteArray = Hex.toArray(Hex.fromString(key));
            var message:ByteArray = Hex.toArray(Hex.fromString( prepareBaseSignature() ));

            var result:ByteArray = hmac.compute(keyer,message);
            var ret:String = Base64.encodeByteArray(result);
			
			return ret;
		}
		
		private function getNonce() : String
		{
			return Math.round(Math.random() * 99999).toString();
		}
		
		private function getTimestamp() : String
		{
			return ( String(new Date().time).substring(0, 10) );
		}
		
		
		private function onCompleteHandler( evt : Event )  : void
		{						
			var res:Array = String( evt.target.data ).split( "&" );
			
			if( _requestTokenOK )
			{
				trace("oauth_so " + oauth_so );
				var oauth_so:SharedObject = SharedObject.getLocal("oauth_so");
				oauth_so.data.token 		= res[0].split("=")[1];
				oauth_so.data.token_secret 	= res[1].split("=")[1];
				oauth_so.data.user_id 		= res[2].split("=")[1];
				oauth_so.data.screen_name 	= res[3].split("=")[1];
			}else{
				trace("REDIRECT TO PIN");
				_props.oauth_token 			= res[0].split( "=" )[1];
				_props.oauth_token_secret 	= res[1].split( "=" )[1];	 
				
				navigateToURL( new URLRequest( HOSTNAME_URL + AUTHORIZE_URL + "?"+ res[0] ));	
				_requestTokenOK = true;
			}
		}	
		
		private function httpStatusHandler( evt : HTTPStatusEvent ) : void
		{
			trace("HTTP Status : " + evt.status );
		}
		
		private function ioErrorHandler( evt : IOErrorEvent ) : void
		{
			trace("IOError : " + evt.text );
		}
		
		private function securityErrorHandler( evt : SecurityErrorEvent ) : void
		{
			trace("Security Error : " + evt );
		}
		
		//------------------------------------------------------------
		//						GETTET/SETTER
		//------------------------------------------------------------
		//------------------------------------------------------------
		
			
		public function get consumer_key():String
		{
			return _consumer_key;
		}

		public function set consumer_key(value:String):void
		{
			_consumer_key = value;
		}

		public function get consumer_secret():String
		{
			return _consumer_secret;
		}

		public function set consumer_secret(value:String):void
		{
			_consumer_secret = value;
		}

			
	}
}