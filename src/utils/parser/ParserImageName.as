package utils.parser
{
	import flash.events.DataEvent;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import utils.FileUtils;
	
	public class ParserImageName extends EventDispatcher
	{
		private static const LINE_BREAK:String = "\n";
		private static const LINE_BREAK2:String = "\r";
		
		private static var patternPngList:Array = [
			new RegExp(/\"\w+\.png\"/g),
			new RegExp(/\"\w+\.jpg\"/g),
			new RegExp(/\"\w+\_*\-*\w+\.png\"/g),
			new RegExp(/\"\w+\_*\-*\w+\.jpg\"/g),
			new RegExp(/\/\w+\_\w+.png\"/),
			new RegExp(/\/\w+\_\w+.jpg\"/)
			];
		
		private static var patternCcbiList:Array = [
			new RegExp(/\"\w+\.ccbi\"/g),
			new RegExp(/\"\w+\_*\-*\+*\w*\.ccbi\"/g),
		];
		
		private var _pngsList:Object = null;
		private var _pngsErrList:Object = null;
		
		private var _plistPngsList:Object = null;
		
		private var _ccbiList:Object = null;
		private var _ccbiErrList:Object = null;
		
		private var _pngsDiffList:Object = null;
		
		private var _plistPngsDiffList:Object = null;
		
		private var _checkoutList:Array = null;
		
		private var _locked:Boolean = false;
		private var _timerId:int = -1;
		private var _parserIndex:int = 0;
		
		public function ParserImageName()
		{
		}
		
		public function isParserComplete():Boolean
		{
			return _locked == false;
		}
		
		public function stopParser():void
		{
			_locked = false;
			
			clearTimeout(_timerId);
			_parserIndex = 0;
		}
		
		public function parser(path:String):void
		{
			if (_locked == true) return;
			
			_locked = true;
			_parserIndex = 0;
			
			_pngsList = {};
			_pngsErrList = {};
			
			_plistPngsList = {};
			
			_ccbiList = {};
			_ccbiErrList = {};
			
			_checkoutList = [];
			
			var file:File = File.applicationDirectory.resolvePath(path);
			
			if (file.exists == true)
			{
				FileUtils.recursiveCheckoutFile(file, _checkoutList, "", checkCondition);
				parserNextFile();
			}
			else
			{
				dispatchEvent(new DataEvent("parser_error", false, false, "路径不存在: " + path));
			}
		}
		
		public function checkCondition(file:File):Boolean
		{
			if (file != null)
			{
				var extension:String = file.extension;
				if (extension == "cpp" || extension == "mm" || extension == "m" || extension == "lua" || extension == "java")
				{
					return true;
				}
				else if (file.isDirectory == true && (file.name == "iphonehd" || file.name.indexOf("_iphonehd") >= 0))
				{
					var fileList:Array = file.getDirectoryListing();
					var len:int = fileList.length;
					
					for(var i:int = 0; i < len; i++)
					{
						var tempFile:File = fileList[i];
						
						if (tempFile.extension == "plist")
						{
							var data:Object = {};
							data.fileName = tempFile.name;
							data.selected = false;
							data.filePath = tempFile.nativePath;
							data.file = tempFile;
							_checkoutList.push(data);
						}
					}
				}
			}
			
			return false;
		}
		
		private function parserNextFile():void
		{
			clearTimeout(_timerId);
			
			var data:Object = _checkoutList[_parserIndex];
			var file:File = data.file as File;
			
			if (file != null)
			{
				var extension:String = file.extension;
				if (extension == "cpp" || extension == "mm" || extension == "m" || extension == "lua")
				{
					var str:String = FileUtils.loadStringWidthFile(file);
					parserCPPFile(str, false);
				}
				else if (extension == "plist")
				{
					var plistStr:String = FileUtils.loadStringWidthFile(file);
					var plistPngs:Array = [];
					
					parserPlistFile(plistStr, plistPngs);
					
					if (plistPngs.length > 0)
					{
						_plistPngsList[file.name] = plistPngs;
					}
				}
			}
			
			dispatchEvent(new DataEvent("parser_item", false, false, file.name));
			
			if (_parserIndex >= _checkoutList.length - 1)
			{
				_locked = false;
				_parserIndex = 0;
				dispatchEvent(new DataEvent("parser_complete", false, false, ""));
			}
			else
			{
				_parserIndex += 1;
				_timerId = setTimeout(parserNextFile, 1 / 60);
			}
		}
		
		public function comparePngs(ccbPngsList:Object):void
		{
			var ccbPngsUseList:Object = {};
			
			for(var ccbi:String in _ccbiList)
			{
				var ccb:String = ccbi.replace("ccbi", "ccb");
				
				if(ccbPngsList.hasOwnProperty(ccb) == true)
				{
					var ccbPngs:Object = ccbPngsList[ccb];
					
					for(var plist:String in ccbPngs)
					{
						if (ccbPngsUseList.hasOwnProperty(plist) == false)
						{
							ccbPngsUseList[plist] = {};
						}
						
						for(var png:String in ccbPngs[plist])
						{
							if (ccbPngsUseList[plist].hasOwnProperty(png) == false)
							{
								ccbPngsUseList[plist][png] = 0;
							}
							
							ccbPngsUseList[plist][png] += 1;
						}
					}
				}
			}
			
			var plistPngsDiffList:Object = {};
			
			for(var plistName:String in _plistPngsList)
			{
				var pngs:Array = _plistPngsList[plistName];
				var usePngs:Object = ccbPngsUseList[plistName];
				
				if (pngs != null && usePngs != null)
				{
					var len:int = pngs.length;
					
					for (var i:int = 0; i < len; i++)
					{
						var pngItem:String = pngs[i];
						
						if (usePngs[pngItem] == null && _pngsList[pngItem] == null)
						{
							if (plistPngsDiffList.hasOwnProperty(plistName) == false)
							{
								plistPngsDiffList[plistName] = [];
							}
							
							plistPngsDiffList[plistName].push(pngItem);
						}
					}
				}
				else
				{
					plistPngsDiffList[plistName] = pngs;
				}
			}
			
			_plistPngsDiffList = plistPngsDiffList;
		}
		
		public function get plistPngsDiffList():Object
		{
			return _plistPngsDiffList;
		}
		
		public function get plistPngsList():Object
		{
			return _plistPngsList;
		}
		
		public function get pngsErrList():Object
		{
			return _pngsErrList;
		}
		
		public function get codePngsList():Object
		{
			return _pngsList;
		}
		
		private function parserPlistFile(source:String, plistPngs:Array):void
		{
			var plist:Object = ParserPlist.parserPlistToObject(source);
			
			if (plist.frames != null)
			{
				for(var k:String in plist.frames.object)
				{
					plistPngs.push(k);
				}
			}
		}
		
		private function parserCPPFile(source:String, ignoreNotes:Boolean):void
		{
			var lines:Array = source.split(LINE_BREAK);
			var skipParser:Boolean = false;
			
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
					parserCPPLine(line);
				}
				
				if (line.indexOf("*/") >= 0 && ignoreNotes == true)
				{
					skipParser = false;
				}
			}
		}
		
		private function parserCPPLine(source:String):void
		{
			// png
			
			var pngFlag:Boolean = false;
			
			for each(var regExp1:RegExp in patternPngList)
			{
				var arr1:Array = source.match(regExp1);		
				
				if (arr1 == null || arr1.length == 0) continue;
				
				pngFlag = true;
				
				var len1:int = arr1.length;
				
				for(var h:int = 0; h < len1; h++)
				{
					var item1:String = arr1[h];
					item1 = item1.replace(/\"/g, "");
					item1 = item1.replace(/\//g, "");
						
					if(_pngsList.hasOwnProperty(item1) == false)
						_pngsList[item1] = 0;
					_pngsList[item1] += 1;
				}
			}
			
			if (pngFlag == false)
			{
				if (source.indexOf(".png") >= 0 || source.indexOf(".jpg") >= 0)
				{
					if(_pngsErrList.hasOwnProperty(source) == false)
						_pngsErrList[source] = 0;
					_pngsErrList[source] += 1;
				}
			}
			
			// ccbi
			
			var ccbiFlag:Boolean = false;
			
			for each(var regExp2:RegExp in patternCcbiList)
			{
				var arr2:Array = source.match(regExp2);		
				
				if (arr2 == null || arr2.length == 0) continue;
				
				ccbiFlag = true;
				
				var len2:int = arr2.length;
				
				for(var j:int = 0; j < len2; j++)
				{
					var item2:String = arr2[j];
					item2 = item2.replace(/\"/g, "");
					
					if(_ccbiList.hasOwnProperty(item2) == false)
						_ccbiList[item2] = 0;
					_ccbiList[item2] += 1;
				}
			}
			
			if (ccbiFlag == false)
			{
				if (source.indexOf(".ccbi") >= 0)
				{
					if(_ccbiErrList.hasOwnProperty(source) == false)
						_ccbiErrList[source] = 0;
					_ccbiErrList[source] += 1;
				}
			}
		}
	}
}