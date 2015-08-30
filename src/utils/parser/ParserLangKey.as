package utils.parser
{
	import flash.events.DataEvent;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import utils.FileUtils;

	public class ParserLangKey extends EventDispatcher
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
		private var _diffList:Array = null;
		private var _checkoutList:Array = null;
		private var _checkoutForHeadList:Array = null;
		
		private var _locked:Boolean = false;
		
		private var _timerId:int = -1;
		private var _parserIndex:int = 0;
		
		private var _wuchaTimerId:int = -1;
		private var _wuchaParserIndex:int = 0;
		
		private var _headTimerId:int = -1;
		private var _headParserIndex:int = 0;
		
		private var _enPlistStrings:Object = null;
		
		public function ParserLangKey()
		{
		}
		
		public function isParserComplete():Boolean
		{
			return _locked == false;
		}
		
		public function get diffList():Array
		{
			return _diffList;
		}
		
		public function get wuchaList():Object
		{
			return _wuchaList;
		}
		
		public function get stringList():Object
		{
			return _stringList;
		}
		
		public function get errList():Object
		{
			return _errList;
		}
		
		public function stopParser():void
		{
			_locked = false;
			
			clearTimeout(_timerId);
			_parserIndex = 0;
			
			clearTimeout(_wuchaTimerId);
			_wuchaParserIndex = 0;
			
			clearTimeout(_headTimerId);
			_headParserIndex = 0;
		}
		
		public function parser(path:String, enPlistPath:String):void
		{
			if (_locked == true) return;
			
			var enPlistStr:String = FileUtils.loadStringWidthPath(enPlistPath);
			_enPlistStrings = ParserPlist.parserPlistToObject(enPlistStr);
			
			if (enPlistStr == "" || _enPlistStrings == null)
			{
				dispatchEvent(new DataEvent("parser_error", false, false, "文件" + enPlistPath + "没有找到！"));
				return;
			}
			
			_locked = true;
			_defineDict = {};
			_stringList = {};
			_errList = {};
			_wuchaList = {};
			_checkoutList = [];
			_diffList = [];
			_checkoutForHeadList = [];
			
			_headParserIndex = 0;
			_parserIndex = 0;
			_wuchaParserIndex = 0;
			
			var file:File = File.applicationDirectory.resolvePath(path);
			FileUtils.recursiveCheckoutFile(file, _checkoutList, "", checkCondition);
			
			parserFileWithHead();
		}
		
		public function checkCondition(file:File):Boolean
		{
			if (file != null)
			{
				var extension:String = file.extension;
				if (extension == "cpp" || extension == "mm" || extension == "m" || extension == "java")
				{
					return true;
				}
				else if (extension == "h")
				{
					_checkoutForHeadList.push({file:file});
				}
				else if (extension == "lua")
				{
					return true;
				}
			}
			
			return false;
		}
		
		private function parserFileWithHead():void
		{
			clearTimeout(_headTimerId);
			
			var data:Object = _checkoutForHeadList[_headParserIndex];
			var file:File = data.file as File;
			
			if (file != null)
			{
				var extension:String = file.extension;
				if (extension == "h")
				{
					var headStr:String = FileUtils.loadStringWidthFile(file);
					parserHeadFile(headStr, _defineDict, startupIgnoreNotes);
				}
			}
			
			dispatchEvent(new DataEvent("parser_item", false, false, file.name));
			
			if (_headParserIndex >= _checkoutForHeadList.length - 1)
			{
				_parserIndex = 0;
				parserNextFileWithString();
			}
			else
			{
				_headParserIndex += 1;
				_headTimerId = setTimeout(parserFileWithHead, 1 / 100);
			}
		}
		
		private function parserNextFileWithString():void
		{
			clearTimeout(_timerId);
			
			var data:Object = _checkoutList[_parserIndex];
			var file:File = data.file as File;
			
			if (file != null)
			{
				var extension:String = file.extension;
				if (extension == "cpp" || extension == "mm" || extension == "m" || extension == "java")
				{
					var cppStr:String = FileUtils.loadStringWidthFile(file);
					parserCPPFile(cppStr, _stringList, _defineDict, _errList, startupIgnoreNotes);
				}
				else if (extension == "lua")
				{
					var luaStr:String = FileUtils.loadStringWidthFile(file);
					parserLuaFile(luaStr, _stringList, _errList);
				}
			}
			
			dispatchEvent(new DataEvent("parser_item", false, false, file.name));
			
			if (_parserIndex >= _checkoutList.length - 1)
			{
				_parserIndex = 0;
				_wuchaParserIndex = 0;
				
				for(var k:String in _enPlistStrings)
				{
					if (k.indexOf("/story/") == 0 || k.indexOf("/store/") == 0 || k.indexOf("/event/") == 0 || k.indexOf("/achievement/") == 0 || k.indexOf("/npc/") == 0)
						continue;
					
					if (_stringList[k] == null)
					{
						_diffList.push(k);
					}
				}
				
				parserFileWithWucha();
			}
			else
			{
				_parserIndex += 1;
				_timerId = setTimeout(parserNextFileWithString, 1 / 100);
			}
		}
		
		private function parserFileWithWucha():void
		{
			clearTimeout(_wuchaTimerId);
			
			var data:Object = _checkoutList[_wuchaParserIndex];
			var file:File = data.file as File;
			
			if (file != null)
			{
				var diffLen:int = _diffList.length;
				for (var i:int = 0; i < diffLen; i++)
				{
					var diffKey:String = '"' + _diffList[i] + '"';
					var str:String = FileUtils.loadStringWidthFile(file);
					var findIndex:int = str.indexOf(diffKey);
					if (findIndex >= 0)
					{
						var tempKey:String = _diffList[i];
						if (_wuchaList.hasOwnProperty(tempKey) == false)
							_wuchaList[tempKey] = 0;
						_wuchaList[tempKey] += 1;
					}
				}
			}
			
			dispatchEvent(new DataEvent("parser_item", false, false, file.name));
			
			if (_wuchaParserIndex >= _checkoutList.length - 1)
			{
				_locked = false;
				_wuchaParserIndex = 0;
				dispatchEvent(new DataEvent("parser_complete", false, false, ""));
			}
			else
			{
				_wuchaParserIndex += 1;
				_wuchaTimerId = setTimeout(parserFileWithWucha, 1 / 100);
			}
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
				
				if (arr1 != null || arr1.length > 0) flag = true;
				
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
		
		static public function parserCPPFile(source:String, stringList:Object, headDefineDict:Object, errList:Object, ignoreNotes:Boolean):void
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
				else if (line.indexOf("/*") >= 0 && ignoreNotes == true)
				{
					skipParser = true;
				}
				else if (line.indexOf("//") >= 0 && ignoreNotes == true)
				{
					continue;
				}
				
				if(skipParser == false && line != "")
				{
					parserDefineLine(line, cppDefineDict);
					parserCPPLine(line, stringList, headDefineDict, cppDefineDict, errList);
				}
				
				if (line.indexOf("*/") >= 0 && ignoreNotes == true)
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
				
				if (arr1 == null || arr1.length == 0) continue;
				
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
				
				if (arr2 == null || arr2.length == 0) continue;
				
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
		
		static public function parserHeadFile(source:String, defineDict:Object, ignoreNotes:Boolean):void
		{
			var lines:Array = source.split(LINE_BREAK);
			var skipParser:Boolean = false;
			
			for each(var line:String in lines)
			{
				if (line.indexOf("#include") >= 0)
				{
					continue;
				}
				else if (line.indexOf("/*") >= 0 && ignoreNotes == true)
				{
					skipParser = true;
				}
				else if (line.indexOf("//") >= 0 && ignoreNotes == true)
				{
					continue;
				}
				
				if(skipParser == false)
				{
					parserDefineLine(line, defineDict);
				}
				
				if (line.indexOf("*/") >= 0 && ignoreNotes == true)
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