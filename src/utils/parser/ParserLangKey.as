package utils.parser
{
	import flash.filesystem.File;
	
	import utils.FileUtils;

	public class ParserLangKey
	{	
		private static const startupIgnoreNotes:Boolean = false;
		
		private static const patternDefine:RegExp = /\s*#define\s*\w*+\s*\"\w*+\"/;
		private static const patternDefStrKey:RegExp = /[^\s*#define\s*]\w*+/;
		private static const patternDefStrValue:RegExp = /\"\w*\"/;
		
		private static const patternString1:RegExp = /\"\w+/;
		private static const patternString2:RegExp = /\(\s*\w+\s*\,*/;
		
		private static const LINE_BREAK:String = "\n";
		private static const LINE_BREAK2:String = "\r";
		
		private static var langFieldList:Array = ["getStringTable().getFormatString", 
												  "getStringTable().getString", 
												  "getFormatStringWithInt", 
												  "getFormatStringWithFloat", 
												  "getFormatStringWithList", 
												  "getFormatStringEx", 
												  "getFormatStringWithIntEx", 
												  "LOC_STRING", 
												  "LOC_STRING_TO_STR", 
												  "LOC_STRING_BY_STR", 
												  "LOC_STRING_BY_NUM", 
												  "LOC_COMPLEX_STRING", 
												  "getLocalizedString",
												  "getLocalizedStringByStr", 
												  "getLocalizedStringByNum", 
												  "getComplexLocalizedString", 
												  "getLangString",
												  "loc_string",
												  "loc_string_by_int",
												  "loc_string_by_str",
												  "loc_string_by_list",
												  "loc_string_by_CCArray"];
		
		private static var patternList1:Array = [
				new RegExp(/getStringTable\(\)\.getFormatString\(\s*\"\w+\_*\w+/g),
				new RegExp(/getStringTable\(\)\.getString\(\s*\"\w+\_*\w+/g),
				new RegExp(/getStringTable\(\)\.getFormatStringWithCCArray\(\s*\"\w+\_*\w+/g),
				
				new RegExp(/getFormatStringWithInt\(\s*\"\w+\_*\w+/g),
				new RegExp(/getFormatStringWithFloat\(\s*\"\w+\_*\w+/g),
				new RegExp(/getFormatStringWithList\(\s*\"\w+\_*\w+/g),
				new RegExp(/getFormatStringEx\(\s*\"\w+\_*\w+/g),
				new RegExp(/getFormatStringWithIntEx\(\s*\"\w+\_*\w+/g),
				
				new RegExp(/LOC_STRING\(\s*\"\w+\_*\w+/g),
				new RegExp(/LOC_STRING_TO_STR\(\s*\"\w+\_*\w+/g),
				new RegExp(/LOC_STRING_BY_STR\(\s*\"\w+\_*\w+/g),
				new RegExp(/LOC_STRING_BY_NUM\(\s*\"\w+\_*\w+/g),
				new RegExp(/LOC_COMPLEX_STRING\(\s*\"\w+\_*\w+/g),
				
				new RegExp(/getLocalizedString\(\s*\"\w+\_*\w+/g),
				new RegExp(/getLocalizedStringByStr\(\s*\"\w+\_*\w+/g),
				new RegExp(/getLocalizedStringByNum\(\s*\"\w+\_*\w+/g),
				new RegExp(/getComplexLocalizedString\(\s*\"\w+\_*\w+/g),
				
				new RegExp(/getLangString\(\s*\"\w+\_*\w+/)
			];
		
		private static var patternList2:Array = [
			new RegExp(/getStringTable\(\)\.getFormatString\(\s*\w+\_*\w+\s*,/g),
			new RegExp(/getStringTable\(\)\.getString\(\s*\w+\_*\w+\s*,/g),
			new RegExp(/getStringTable\(\)\.getFormatStringWithCCArray\(\s*\w+\_*\w+\s*,/g),
			
			new RegExp(/getFormatStringWithInt\(\s*\w+\_*\w+\s*,/g),
			new RegExp(/getFormatStringWithFloat\(\s*\w+\_*\w+\s*,/g),
			new RegExp(/getFormatStringWithList\(\s*\w+\_*\w+\s*,/g),
			new RegExp(/getFormatStringEx\(\s*\w+\_*\w+\s*,/g),
			new RegExp(/getFormatStringWithIntEx\(\s*\w+\_*\w+\s*,/g),
			
			new RegExp(/LOC_STRING\(\s*\w+\_*\w+\s*\)/g),
			new RegExp(/LOC_STRING\(\s*\w+\_*\w+\s*,/g),
			new RegExp(/LOC_STRING_TO_STR\(\s*\w+\_*\w+\s*,/g),
			new RegExp(/LOC_STRING_BY_STR\(\s*\w+\_*\w+\s*,/g),
			new RegExp(/LOC_STRING_BY_STR\(\s*\w+\_*\w+\s*/g),
			new RegExp(/LOC_STRING_BY_NUM\(\s*\w+\_*\w+\s*,/g),
			new RegExp(/LOC_COMPLEX_STRING\(\s*\w+\_*\w+\s*,/g),
			
			new RegExp(/getLocalizedString\(\s*\w+\_*\w+,/g),
			new RegExp(/getLocalizedStringByStr\(\s*\w+\_*\w+,/g),
			new RegExp(/getLocalizedStringByNum\(\s*\w+\_*\w+,/g),
			new RegExp(/getComplexLocalizedString\(\s*\w+\_*\w+,/g)
		];
		
		private static var patternListLua1:Array = [
			new RegExp(/loc_string\(\s*\"\w+\_*\w+/g),
			new RegExp(/loc_string_by_int\(\s*\"\w+\_*\w+/g),
			new RegExp(/loc_string_by_str\(\s*\"\w+\_*\w+/g),
			new RegExp(/loc_string_by_list\(\s*\"\w+\_*\w+/g),
			new RegExp(/loc_string_by_CCArray\(\s*\"\w+\_*\w+/g)
		];
		
		private var _defineDict:Object = null;
		private var _stringList:Object = null;
		private var _errList:Object = null;
		private var _wuchaList:Object = null;
		
		public function ParserLangKey()
		{
			
		}
		
		public function setPath(path:String):void
		{
			_defineDict = {};
			_stringList = {};
			_errList = {};
			_wuchaList = {};
			
			var enPlistStr:String = FileUtils.loadStringWidthPath("en.plist");
			var enPlist:Object = ParserPlist.parserPlistToObject(enPlistStr);
			
			var checkoutList:Array = [];
			var file:File = File.applicationDirectory.resolvePath(path);
			FileUtils.recursiveCheckoutFile(file, checkoutList, "", checkCondition);
			
			for each(var item:Object in checkoutList)
			{
				var fileItem:File = item.file;
				if (fileItem != null)
				{
					trace(fileItem.name);
					
					if (fileItem.extension == "cpp" || fileItem.extension == "mm" || fileItem.extension == "m")
					{
						var cppStr:String = FileUtils.loadStringWidthFile(fileItem);
						parserCPPFile(cppStr, _stringList, _defineDict, _errList);
					}
					else if (fileItem.extension == "lua")
					{
						var luaStr:String = FileUtils.loadStringWidthFile(fileItem);
						parserLuaFile(luaStr, _stringList, _errList);
					}
				}
			}
			
			var diffList:Array = [];
			var index:int = -1;
			
			for(var k:String in enPlist)
			{
				if (k.indexOf("/story/") == 0 || k.indexOf("/store/") == 0 || k.indexOf("/event/") == 0 || k.indexOf("/achievement/") == 0 || k.indexOf("/npc/") == 0)
					continue;
				
				if (_stringList[k] == null)
				{
					diffList.push(k);
				}
			}
			
			var diffLen:int = diffList.length;
			
			for (var i:int = 0; i < diffLen; i++)
			{
				var diffKey:String = '"' + diffList[i] + '"';
				
				for each(var obj:Object in checkoutList)
				{
					var tempFile:File = obj.file;
					if (tempFile != null)
					{
						trace(tempFile.name);
						
						var str:String = FileUtils.loadStringWidthFile(tempFile);
						var findIndex:int = str.indexOf(diffKey);
						if (findIndex >= 0)
						{
							var tempKey:String = diffList[i];
							if (_wuchaList.hasOwnProperty(tempKey) == false)
								_wuchaList[tempKey] = 0;
							_wuchaList[tempKey] += 1;
						}
					}
				}
			}
			
			FileUtils.saveStringToPath(JSON.stringify(diffList), path + "/diffList.json");
			FileUtils.saveStringToPath(JSON.stringify(_wuchaList), path + "/wuchaList.json");
			FileUtils.saveStringToPath(JSON.stringify(_stringList), path + "/stringList.json");
		}
		
		public function checkCondition(file:File):Boolean
		{
			if (file != null)
			{
				if (file.extension == "cpp" || file.extension == "mm" || file.extension == "m")
				{
					return true;
				}
				else if (file.extension == "h")
				{
					var headStr:String = FileUtils.loadStringWidthFile(file);
					parserHeadFile(headStr, _defineDict);
				}
				else if (file.extension == "lua")
				{
					return true;
				}
			}
			
			return false;
		}
		
		static public function parserLuaFile(source:String, stringList:Object, errList:Object):void
		{
			var lines:Array = source.split(LINE_BREAK);
			var cppDefineDict:Object = {};
			
			if (lines == null || lines.length == 1)
			{
				lines = source.split(LINE_BREAK2);
			}
			
			for each(var line:String in lines)
			{
				if (line.indexOf("--") >= 0 && startupIgnoreNotes == true)
				{
					continue;
				}
				
				if(line != "")
				{
					parserLuaLine(line, stringList, errList);
				}
			}
		}
		
		static public function parserLuaLine(source:String, stringList:Object, errList:Object):void
		{
			var flag:Boolean = false;
			
			for each(var regExp1:RegExp in patternListLua1)
			{
				var arr1:Array = source.match(regExp1);
				
				if (arr1 != null) flag = true;
				
				for each(var item1:String in arr1)
				{
					var item1Arr:Array = item1.match(patternString1);
					
					if (item1Arr == null) continue;
					
					var len1:int = item1Arr.length;
					
					for(var i:int = 0; i < len1; i++)
					{
						var key1:String = item1Arr[i];
						key1 = key1.replace('"', "");
						
						if(stringList.hasOwnProperty(key1) == false)
							stringList[key1] = 0;
						stringList[key1] += 1;
					}
				}
			}
			
			if (flag == false)
			{
				for each(var s:String in langFieldList)
				{
					if (source.indexOf(s) >= 0)
					{
						if(errList.hasOwnProperty(source) == false)
							errList[source] = 0;
						errList[source] += 1;
						break;
					}
				}
			}
		}
		
		static public function parserCPPFile(source:String, stringList:Object, headDefineDict:Object, errList:Object):void
		{
			var lines:Array = source.split(LINE_BREAK);
			var skipParser:Boolean = false;
			var cppDefineDict:Object = {};
			
			if (lines == null || lines.length == 1)
			{
				lines = source.split(LINE_BREAK2);
			}
			
			for each(var line:String in lines)
			{
				if (line.indexOf("#include") >= 0)
				{
					continue;
				}
				else if (line.indexOf("/*") >= 0 && startupIgnoreNotes == true)
				{
					skipParser = true;
				}
				else if (line.indexOf("//") >= 0 && startupIgnoreNotes == true)
				{
					continue;
				}
				
				if(skipParser == false && line != "")
				{
					parserDefineLine(line, cppDefineDict);
					parserCPPLine(line, stringList, headDefineDict, cppDefineDict, errList);
				}
				
				if (line.indexOf("*/") >= 0 && startupIgnoreNotes == true)
				{
					skipParser = false;
				}
			}
		}
		
		static public function parserCPPLine(source:String, stringList:Object, headDefineDict:Object, cppDefineDict:Object, errList:Object):void
		{
			var flag:Boolean = false;
			
			for each(var regExp1:RegExp in patternList1)
			{
				var arr1:Array = source.match(regExp1);		
				
				if (arr1 == null) continue;
				
				flag = true;
				
				var len1:int = arr1.length;
				
				for(var h:int = 0; h < len1; h++)
				{
					var item1:String = arr1[h];
					var item1Arr:Array = item1.match(patternString1);
					
					if (item1Arr == null) 
					{
						if(errList.hasOwnProperty(item1) == false)
							errList[item1] = 0;
						errList[item1] += 1;
						continue;
					}
					
					var lenItem1:int = item1Arr.length;
					
					for(var i:int = 0; i < lenItem1; i++)
					{
						var key1:String = item1Arr[i];
						key1 = key1.replace('"', "");
						
						if(stringList.hasOwnProperty(key1) == false)
							stringList[key1] = 0;
						stringList[key1] += 1;
					}
				}
			}
			
			for each(var regExp2:RegExp in patternList2)
			{
				var arr2:Array = source.match(regExp2);
				
				if (arr2 == null) continue;
				
				flag = true;
				
				var len2:int = arr2.length;
				
				for(var k:int = 0; k < len2; k++)
				{
					var item2:String = arr2[k];
					var item2Arr:Array = item2.match(patternString2);
					
					if (item2Arr == null) 
					{
						if(errList.hasOwnProperty(item2) == false)
							errList[item2] = 0;
						errList[item2] += 1;
						continue;
					}
					
					var lenItem2:int = item2Arr.length;
					
					for(var j:int = 0; j < lenItem2; j++)
					{
						var key2:String = item2Arr[j];
						key2 = key2.replace('(', "");
						key2 = key2.replace(',', "");
						key2 = key2.replace(/\"/g, "");
						
						var value2:String = cppDefineDict[key2];
						
						if (value2 == null)
						{
							value2 = headDefineDict[key2];
						}
						
						if (value2 != null)
						{
							if(stringList.hasOwnProperty(value2) == false)
								stringList[value2] = 0;
							stringList[value2] += 1;
						}
						else
						{
							var errKey:String = item2Arr[j];
							if(errList.hasOwnProperty(errKey) == false)
								errList[errKey] = 0;
							errList[errKey] += 1;
						}
					}
				}
			}
			
			if (flag == false)
			{
				for each(var s:String in langFieldList)
				{
					if (source.indexOf(s) >= 0)
					{
						if(errList.hasOwnProperty(source) == false)
							errList[source] = 0;
						errList[source] += 1;
						break;
					}
				}
			}
		}
		
		static public function parserHeadFile(source:String, defineDict:Object):void
		{
			var lines:Array = source.split(LINE_BREAK);
			var skipParser:Boolean = false;
			
			for each(var line:String in lines)
			{
				if (line.indexOf("#include") >= 0)
				{
					continue;
				}
				else if (line.indexOf("/*") >= 0 && startupIgnoreNotes == true)
				{
					skipParser = true;
				}
				else if (line.indexOf("//") >= 0 && startupIgnoreNotes == true)
				{
					continue;
				}
				
				if(skipParser == false)
				{
					parserDefineLine(line, defineDict);
				}
				
				if (line.indexOf("*/") >= 0 && startupIgnoreNotes == true)
				{
					skipParser = false;
				}
			}
		}
		
		static public function parserDefineLine(line:String, defineDict:Object):void
		{
			var arr:Array = line.match(patternDefine);
			if (arr != null) 
			{
				var key:String = line.match(patternDefStrKey)[0] as String;
				var value:String = line.match(patternDefStrValue)[0] as String;
				value = value.replace(/\"/g, "");
				
				if (key != "")
				{
					defineDict[key] = value;
				}
				else
				{
					trace("[ParserCPP::paserDefine:Error:]" + line + ", key=" + key + ", value=" + value);
				}
			}
		}
	}
}