/*---------------------------------------------------------------------------------------------

	AS3 version on PHP print_r
	=======================================================================================

	USAGE:
	
	var obj:Object = {};
	obj.var1 = "test";
	obj.var2 = { var2a: "a", var2b: 10 };
	
	print_r(obj);
	print_r(("a,b,c").split(","));	

---------------------------------------------------------------------------------------------*/

package net.blog2t.util
{
	public function print_r(obj:*, level:int = 0, output:String = ""):*
	{
		var tabs:String = "";
		for (var i:int = 0; i < level; i++, tabs += "\t") {};

		for (var child:* in obj)
		{
			output += tabs + "["+ child + "] => " + obj[child];

			var childOutput:String = print_r(obj[child], level + 1);
			if (childOutput != "") output += " {\n"+ childOutput + tabs + "}";

			output += "\n";
		}

		if (level > 20) return "";
		else if (level == 0) trace(output); else return output;
	}
}