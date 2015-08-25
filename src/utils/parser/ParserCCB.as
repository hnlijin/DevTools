package utils.parser
{
	import net.tautausan.plist.Plist10;
	
	import utils.FileUtils;

	public class ParserCCB
	{
		public function ParserCCB()
		{
			var path:String = "/Users/funplus/Documents/workspace/farm2-mobile-asset/develop/UI_CCB_v3/iphone/AlertNpc.ccb";
			var str:String = FileUtils.loadStringWidthFile(path);
			trace(str);
			var plist10:Plist10 = new Plist10();
			plist10.parse(str);
		}
		
		static public function parserPlist():Object
		{
			return {};
		}
	}
}