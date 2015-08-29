package utils.parser
{
	import flash.events.DataEvent;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import utils.FileUtils;

	public class ParserCCB extends EventDispatcher
	{
		private var _ccbPngsList:Object = null;
		private var _checkoutList:Array = null;
		
		private var _locked:Boolean = false;
		private var _timerId:int = -1;
		private var _parserIndex:int = 0;
		
		public function ParserCCB()
		{
		}
		
		public function isParserComplete():Boolean
		{
			return _locked == false;
		}
		
		public function stopParser():void
		{
			clearTimeout(_timerId);
			_locked = false;
			_parserIndex = 0;
		}

		public function parser(paths:Array):void
		{
			if (_locked == true) return;
			
			_locked = true;
			_ccbPngsList = {};
			_checkoutList = [];
			
			var len:int = paths.length;
			
			for (var i:int = 0; i < len; i++)
			{
				var path:String = paths[i];
				var file:File = File.applicationDirectory.resolvePath(path);
				if (file.exists == false)
				{
					dispatchEvent(new DataEvent("parser_error", false, false, "路径不存在: " + path));
					break;
				}
				FileUtils.recursiveCheckoutFile(file, _checkoutList, "", checkCondition);
			}
			
			parserNextFile();
		}
		
		private function checkCondition(file:File):Boolean
		{
			if (file.extension == "ccb")
			{
				return true;
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
				var str:String = FileUtils.loadStringWidthFile(file);
				var ccbPngs:Object = {};
				
				parserPlistFile(str, ccbPngs);
				
				_ccbPngsList[file.name] = ccbPngs;
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
		
		public function get ccbPngsList():Object
		{
			return _ccbPngsList;
		}
		
		private function parserPlistFile(source:String, ccbPngs:Object):void
		{
			var plist:Object = ParserPlist.parserPlistToObject(source);
			parserNode(ccbPngs, plist.nodeGraph.object);
		}
		
		private function parserNode(ccbPngs:Object, node:Object):void
		{
			var props:Array = node.properties.object;
			var len:int = props.length;
			
			for (var i:int = 0; i < len; i++)
			{
				var prop:Object = props[i].object;
				var type:String = prop.type.object;
				
				if (type == "SpriteFrame")
				{
					var value:Array = prop.value.object;
					
					if (value.length >= 2)
					{
						var spriteFile1:String = value[0].object;
						var spriteSheetFile1:String = value[1].object;
						
						spriteFile1 = getFileName(spriteFile1);
						spriteSheetFile1 = getFileName(spriteSheetFile1);
						
						if (ccbPngs.hasOwnProperty(spriteFile1) == false)
						{
							ccbPngs[spriteFile1] = {};
						}
						
						if (ccbPngs[spriteFile1].hasOwnProperty(spriteSheetFile1) == false)
						{
							ccbPngs[spriteFile1][spriteSheetFile1] = 0;
						}
						
						ccbPngs[spriteFile1][spriteSheetFile1] += 1;
					}
				}
			}
			
			var animatedProperties:Object = node.animatedProperties == null ? null : node.animatedProperties.object;
			
			for each(var obj:Object in animatedProperties)
			{
				for each(var objItem:Object in obj.object)
				{
					var displayFrame:Object = objItem.object;
					
					if (displayFrame == null) continue;
					
					var keyframes:Array = displayFrame.keyframes.object;
					var keyframesLen:int = keyframes.length;
					
					for (var f:int = 0; f < keyframesLen; f++)
					{
						var item:Object = keyframes[f].object;
						var itemType:Object = item.type.object;
						
						if (itemType == 7)
						{
							var itemValue:Array = item.value.object;
							
							var spriteFile2:String = itemValue[1].object;
							var spriteSheetFile2:String = itemValue[0].object;
							
							spriteFile2 = getFileName(spriteFile2);
							spriteSheetFile2 = getFileName(spriteSheetFile2);
							
							if (ccbPngs.hasOwnProperty(spriteFile2) == false)
							{
								ccbPngs[spriteFile2] = {};
							}
							
							if (ccbPngs[spriteFile2].hasOwnProperty(spriteSheetFile2) == false)
							{
								ccbPngs[spriteFile2][spriteSheetFile2] = 0;
							}
							
							ccbPngs[spriteFile2][spriteSheetFile2] += 1;
						}
					}
				}
			}
			
			var children:Array = node.children.object;
			var childrenLen:int = children.length;
			
			for (var j:int = 0; j < childrenLen; j++)
			{
				parserNode(ccbPngs, children[j].object);
			}
		}
		
		private function getFileName(path:String):String
		{
			var arr2:Array = path.match(/\/\S+.plist/);
			var fileName:String = path;
			
			if (arr2 != null && arr2.length > 0)
			{
				fileName = arr2[0];
				fileName = fileName.replace(/\//g, "");
			}
			
			return fileName;
		}
	}
}