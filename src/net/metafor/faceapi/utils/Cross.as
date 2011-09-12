package net.metafor.faceapi.utils
{
	import flash.display.Shape;
	import flash.display.Sprite;
	
	public class Cross extends Sprite
	{
		public function Cross( _size : int = 10 , _color : uint = 0xFF0000 )
		{
			var h:Shape = new Shape();
			h.graphics.lineStyle( 1 , _color );
			h.graphics.moveTo( 0, 0 );
			h.graphics.lineTo( _size, 0 );
			
			var v:Shape = new Shape();
			v.graphics.lineStyle( 1 , _color );
			v.graphics.moveTo( 0, 0 );
			v.graphics.lineTo( 0, _size );
			
			
			h.x = - _size* 0.5;
			v.y = - _size* 0.5;
			
			addChild( h ) , addChild( v );
		}
	}
}