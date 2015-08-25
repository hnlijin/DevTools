package utils.parser
{
	import net.tautausan.plist.Plist10;

	public class ParserPlist
	{
		static public function parserPlistToObject(xml:String):Object
		{
			var plist10:Plist10 = new Plist10();
			plist10.parse(xml);
			return plist10.root;
		}
	}
}