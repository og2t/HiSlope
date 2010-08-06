package hislope.filters 
{
	import hislope.display.MetaBitmapData;
	
    public interface IFilter
    {
        function process(metaBmpData:MetaBitmapData):void;
		function updateParams():void;
		function dispose():void;
        function toString():String;
    }
}
