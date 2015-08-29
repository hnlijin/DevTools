package core.mediator
{
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	
	import spark.events.IndexChangeEvent;
	
	import core.manager.LocalDataMananger;
	import core.suppotClass._BaseMediator;
	import core.view.ImageStatisticsView;
	
	import utils.FileUtils;
	import utils.parser.ParserCCB;
	import utils.parser.ParserImageName;
	
	public class ImageStatisticsMediator extends _BaseMediator
	{
		[Inject]
		public var view:ImageStatisticsView;
		
		private var _parserImage:utils.parser.ParserImageName = new utils.parser.ParserImageName();
		private var _parserCCB:ParserCCB = new ParserCCB();
		
		private var _fileCodeRootPath:File = new File();
		private var _fileCCBRootPath1:File = new File();
		private var _fileCCBRootPath2:File = new File();
		
		private var _defautlCodeRootPath:Array = ["/Users/funplus/Documents/workspace/familyfarm2-client-code/FamilyFarm"];
		private var _defaultCCBRootPath1:Array = ["/Users/funplus/Documents/workspace/farm2-mobile-asset/develop/UI_CCB_v3/iphone"];
		private var _defaultCCBRootPath2:Array = ["/Users/funplus/Documents/workspace/farm2-mobile-asset/develop/UI_CCB_lua/iphone"];
		
		private var _dataCodeRootPath:ArrayCollection = new ArrayCollection();
		private var _dataCCBRootPath1:ArrayCollection = new ArrayCollection();
		private var _dataCCBRootPath2:ArrayCollection = new ArrayCollection();

		private var _indexCodeRootPath:int = 0;
		private var _indexCCBRootPath1:int = 0;
		private var _indexCCBRootPath2:int = 0;
		
		public function ImageStatisticsMediator()
		{
			super();
		}
		
		override public function initialize():void
		{
			super.initialize();
			
			view.addEventListener(MouseEvent.CLICK, onViewClick);
			
			_parserImage.addEventListener("parser_item", onParserLog);
			_parserImage.addEventListener("parser_error", onParserError);
			_parserImage.addEventListener("parser_complete", onParserComplete);
			
			_parserCCB.addEventListener("parser_item", onParserLog);
			_parserCCB.addEventListener("parser_error", onParserError);
			_parserCCB.addEventListener("parser_complete", onParserComplete);
			
			_fileCodeRootPath.addEventListener(Event.SELECT, onFileSelected);
			_fileCCBRootPath1.addEventListener(Event.SELECT, onFileSelected);
			_fileCCBRootPath2.addEventListener(Event.SELECT, onFileSelected);
			
			_dataCodeRootPath.source = LocalDataMananger.getInstance().getLocalData("fileCodeRootPath", _defautlCodeRootPath) as Array;
			_dataCCBRootPath1.source = LocalDataMananger.getInstance().getLocalData("fileCCBRootPath1", _defaultCCBRootPath1) as Array;
			_dataCCBRootPath2.source = LocalDataMananger.getInstance().getLocalData("fileCCBRootPath2", _defaultCCBRootPath2) as Array;
			
			_indexCodeRootPath = LocalDataMananger.getInstance().getLocalData("indexCodeRootPath", _indexCodeRootPath) as int;
			_indexCCBRootPath1 = LocalDataMananger.getInstance().getLocalData("indexCCBRootPath1", _indexCCBRootPath1) as int;
			_indexCCBRootPath2 = LocalDataMananger.getInstance().getLocalData("indexCCBRootPath2", _indexCCBRootPath2) as int;
			
			view.txtCodeRootPath.addEventListener(IndexChangeEvent.CHANGE, onPathChangeHandler);
			view.txtCCBRootPath1.addEventListener(IndexChangeEvent.CHANGE, onPathChangeHandler);
			view.txtCCBRootPath2.addEventListener(IndexChangeEvent.CHANGE, onPathChangeHandler);
			
			view.txtCodeRootPath.textInput.enabled = false;
			view.txtCCBRootPath1.textInput.enabled = false;
			view.txtCCBRootPath2.textInput.enabled = false;
			
			updatePaths();
		}
		
		private function onViewClick(evt:MouseEvent):void
		{
			if (evt.target == view.btnClose)
			{
				view.close();
			}
			else if (evt.target == view.btnParser)
			{
				startParserImage();
			}
			else if (evt.target == view.btnSaveDiffPngs)
			{
				FileUtils.saveStringToPath(JSON.stringify(_parserImage.plistPngsDiffList), "/Users/funplus/Desktop/plisDiffList.json");
				FileUtils.saveStringToPath(JSON.stringify(_parserCCB.ccbPngsList), "/Users/funplus/Desktop/ccbPngsList.json");
				FileUtils.saveStringToPath(JSON.stringify(_parserImage.pngsErrList), "/Users/funplus/Desktop/pngsErrList.json");
				FileUtils.saveStringToPath(JSON.stringify(_parserImage.codePngsList), "/Users/funplus/Desktop/codePngsList.json");
				view.txtLog.text = "已经保存相关文件到桌面，plisDiffList.json, ccbPngsList.json, pngsErrList.json, codePngsList.json"
			}
			else if (evt.target == view.btnParserHistory)
			{
				var plistPngsDiffListStr:String = FileUtils.loadStringWidthPath(File.applicationStorageDirectory.nativePath +  "/plisDiffList.json");
				var ccbPngsListStr:String = FileUtils.loadStringWidthPath(File.applicationStorageDirectory.nativePath +  "/ccbPngsList.json");
				var pngsErrListStr:String = FileUtils.loadStringWidthPath(File.applicationStorageDirectory.nativePath +  "/pngsErrList.json");
				var codePngsListStr:String = FileUtils.loadStringWidthPath(File.applicationStorageDirectory.nativePath +  "/codePngsList.json");
				
				if (plistPngsDiffListStr != "" && ccbPngsListStr != "" && pngsErrListStr != "" && codePngsListStr != "")
				{
					var plistPngsDiffList:Object = JSON.parse(plistPngsDiffListStr);
					updatePlistListData(plistPngsDiffList);
					
					var ccbPngsList:Object = JSON.parse(ccbPngsListStr);
					updateCCBData(ccbPngsList);
					
					var pngsErrList:Object = JSON.parse(pngsErrListStr);
					updateCheckPngErrorData(pngsErrList);
					
					var codePngsList:Object = JSON.parse(codePngsListStr);
					updateCheckCodePngData(codePngsList);
				}
				else
				{
					startParserImage();
				}
			}
			else if (evt.target == view.btnSettingPath)
			{
				view.groupPath.visible = !view.groupPath.visible;
				
				if (view.groupPath.visible == true)
				{
					view.btnSettingPath.label = "隐藏目录设置";
					view.groupPath.scaleY = 1;
				}
				else
				{
					view.btnSettingPath.label = "显示目录设置";
					view.groupPath.scaleY = 0;
				}
			}
			else if (evt.target == view.btnCodeRootPath)
			{
				_fileCodeRootPath.browseForDirectory("选择代码根目录");
			}
			else if (evt.target == view.btnCCBRootPath1)
			{
				_fileCCBRootPath1.browseForDirectory("选择CCB根目录1");
			}
			else if (evt.target == view.btnCCBRootPath2)
			{
				_fileCCBRootPath2.browseForDirectory("选择CCB根目录2");
			}
			else if (evt.target == view.btnOpenCodeRootPath)
			{
				_fileCodeRootPath.openWithDefaultApplication();
			}
			else if (evt.target == view.btnOpenCCBRootPath1)
			{
				_fileCCBRootPath1.openWithDefaultApplication();
			}
			else if (evt.target == view.btnOpenCCBRootPath2)
			{
				_fileCCBRootPath2.openWithDefaultApplication();
			}
			else if (evt.target == view.btnDelCodeRootPath)
			{
				if (view.txtCodeRootPath.selectedIndex >= 0)
				{
					_dataCodeRootPath.removeItemAt(view.txtCodeRootPath.selectedIndex);
					_indexCodeRootPath = view.txtCodeRootPath.selectedIndex - 1;
					_indexCodeRootPath = _indexCodeRootPath < 0 ? 0 : _indexCodeRootPath;
					
					LocalDataMananger.getInstance().setLocalData("fileCodeRootPath", _dataCodeRootPath.source);
					LocalDataMananger.getInstance().saveLocalData();
					
					updatePaths();
				}
			}
			else if (evt.target == view.btnDelCCBRootPath1)
			{
				if (view.txtCCBRootPath1.selectedIndex >= 0)
				{
					_dataCCBRootPath1.removeItemAt(view.txtCCBRootPath1.selectedIndex);
					_indexCCBRootPath1 = view.txtCCBRootPath1.selectedIndex -1;
					_indexCCBRootPath1 = _indexCCBRootPath1 < 0 ? 0 : _indexCCBRootPath1;
					
					LocalDataMananger.getInstance().setLocalData("strCCBRootPath1", _dataCCBRootPath1.source);
					LocalDataMananger.getInstance().saveLocalData();
					
					updatePaths();
				}
			}
			else if (evt.target == view.btnDelCCBRootPath2)
			{
				if (view.txtCCBRootPath2.selectedIndex >= 0)
				{
					_dataCCBRootPath2.removeItemAt(view.txtCCBRootPath2.selectedIndex);
					_indexCCBRootPath2 = view.txtCCBRootPath2.selectedIndex - 1;
					_indexCCBRootPath2 = _indexCCBRootPath2 < 0 ? 0 : _indexCCBRootPath2;
					
					LocalDataMananger.getInstance().setLocalData("strCCBRootPath2", _dataCCBRootPath2.source);
					LocalDataMananger.getInstance().saveLocalData();
					
					updatePaths();
				}
			}
		}
		
		protected function onPathChangeHandler(event:IndexChangeEvent):void
		{
			if (event.target == view.txtCodeRootPath)
			{
				_indexCodeRootPath = view.txtCodeRootPath.selectedIndex;
				
				LocalDataMananger.getInstance().setLocalData("indexCodeRootPath", _indexCodeRootPath);
				LocalDataMananger.getInstance().saveLocalData();
				
				updatePaths();
			}
			else if (event.target == view.txtCCBRootPath1)
			{
				_indexCCBRootPath1 = view.txtCCBRootPath1.selectedIndex;
				
				LocalDataMananger.getInstance().setLocalData("indexCCBRootPath1", _indexCCBRootPath1);
				LocalDataMananger.getInstance().saveLocalData();
				
				updatePaths();
			}
			else if (event.target == view.txtCCBRootPath2)
			{
				_indexCCBRootPath2 = view.txtCCBRootPath2.selectedIndex;
				
				LocalDataMananger.getInstance().setLocalData("indexCCBRootPath2", _indexCCBRootPath2);
				LocalDataMananger.getInstance().saveLocalData();
				
				updatePaths();
			}
		}
		
		private function onFileSelected(evt:Event):void
		{
			if (evt.target == _fileCodeRootPath)
			{
				_dataCodeRootPath.source.push(_fileCodeRootPath.nativePath);
				_indexCodeRootPath = _dataCodeRootPath.length - 1;
				_indexCodeRootPath = _indexCodeRootPath < 0 ? 0 : _indexCodeRootPath;
					
				LocalDataMananger.getInstance().setLocalData("fileCodeRootPath", _dataCodeRootPath.source);
				LocalDataMananger.getInstance().saveLocalData();
			}
			else if (evt.target == _fileCCBRootPath1)
			{
				_dataCCBRootPath1.source.push(_fileCCBRootPath1.nativePath);
				_indexCCBRootPath1 = _dataCCBRootPath1.length - 1;
				_indexCCBRootPath1 = _indexCCBRootPath1 < 0 ? 0 : _indexCCBRootPath1;
				
				LocalDataMananger.getInstance().setLocalData("strCCBRootPath1", _dataCCBRootPath1.source);
				LocalDataMananger.getInstance().saveLocalData();
			}
			else if (evt.target == _fileCCBRootPath2)
			{
				_dataCCBRootPath2.source.push(_fileCCBRootPath2.nativePath);
				_indexCCBRootPath2 = _dataCCBRootPath2.length - 1;
				_indexCCBRootPath2 = _indexCCBRootPath2 < 0 ? 0 : _indexCCBRootPath2;
				
				LocalDataMananger.getInstance().setLocalData("strCCBRootPath2", _dataCCBRootPath2.source);
				LocalDataMananger.getInstance().saveLocalData();
			}
			
			updatePaths();
		}
		
		private function updatePaths():void
		{
			view.txtCodeRootPath.dataProvider = _dataCodeRootPath;
			view.txtCCBRootPath1.dataProvider = _dataCCBRootPath1;
			view.txtCCBRootPath2.dataProvider = _dataCCBRootPath2;
			
			if (_indexCodeRootPath > _dataCodeRootPath.length - 1)
			{
				_indexCodeRootPath = _dataCodeRootPath.length - 1;
			}
			
			if (_indexCCBRootPath1 > _dataCCBRootPath1.length - 1)
			{
				_indexCCBRootPath1 = _dataCCBRootPath1.length - 1;
			}
			
			if (_indexCCBRootPath2 > _dataCCBRootPath2.length - 1)
			{
				_indexCCBRootPath2 = _dataCCBRootPath2.length - 1;
			}
			
			view.txtCodeRootPath.selectedIndex = _indexCodeRootPath;
			view.txtCCBRootPath1.selectedIndex = _indexCCBRootPath1;
			view.txtCCBRootPath2.selectedIndex = _indexCCBRootPath2;
			
			view.txtCodeRootPathTip.text = "请添加目录";
			view.txtCCBRootPath1Tip.text = "请添加目录";
			view.txtCCBRootPath2Tip.text = "请添加目录";
			
			if (_dataCodeRootPath.length > 0)
			{
				var selectedItemForCodeRootPath:String = _dataCodeRootPath[view.txtCodeRootPath.selectedIndex];
				if (selectedItemForCodeRootPath != "")
				{
					_fileCodeRootPath.nativePath = selectedItemForCodeRootPath;
					view.txtCodeRootPathTip.text = _fileCodeRootPath.exists ? "有效目录" : "目录不存在";
				}
			}
			
			if (_dataCCBRootPath1.length > 0)
			{
				var selectedItemForCCBRootPath1:String = _dataCCBRootPath1[view.txtCCBRootPath1.selectedIndex];
				if (selectedItemForCCBRootPath1 != "") 
				{
					_fileCCBRootPath1.nativePath = selectedItemForCCBRootPath1;
					view.txtCCBRootPath1Tip.text = _fileCCBRootPath1.exists ? "有效目录" : "目录不存在";
				}
			}
			
			if (_dataCCBRootPath2.length > 0)
			{
				var selectedItemForCCBRootPath2:String = _dataCCBRootPath2[view.txtCCBRootPath2.selectedIndex];
				if (selectedItemForCCBRootPath2 != "") 
				{
					_fileCCBRootPath2.nativePath = selectedItemForCCBRootPath2;
					view.txtCCBRootPath2Tip.text = _fileCCBRootPath2.exists ? "有效目录" : "目录不存在";
				}
			}
		}
		
		private function onParserComplete(evt:DataEvent):void
		{
			if (_parserImage.isParserComplete() && _parserCCB.isParserComplete())
			{
				_parserImage.comparePngs(_parserCCB.ccbPngsList);
				view.btnParser.enabled = true;
				view.btnSaveDiffPngs.enabled = true;
				view.btnParserHistory.enabled = true;
				view.txtLog.text = "解析完成";
				
				var plistPngsDiffList:Object = _parserImage.plistPngsDiffList;
				FileUtils.saveStringToPath(JSON.stringify(plistPngsDiffList), File.applicationStorageDirectory.nativePath +  "/plisDiffList.json");
				
				var ccbPngsList:Object = _parserCCB.ccbPngsList;
				FileUtils.saveStringToPath(JSON.stringify(ccbPngsList), File.applicationStorageDirectory.nativePath +  "/ccbPngsList.json");
				
				var plistPngsList:Object = _parserImage.plistPngsList;
				FileUtils.saveStringToPath(JSON.stringify(plistPngsList), File.applicationStorageDirectory.nativePath +  "/plistPngsList.json");
				
				var pngsErrList:Object = _parserImage.pngsErrList;
				FileUtils.saveStringToPath(JSON.stringify(pngsErrList), File.applicationStorageDirectory.nativePath +  "/pngsErrList.json");
				
				var codePngsList:Object = _parserImage.codePngsList;
				FileUtils.saveStringToPath(JSON.stringify(codePngsList), File.applicationStorageDirectory.nativePath +  "/codePngsList.json");
				
				updatePlistListData(plistPngsDiffList);
				updateCCBData(ccbPngsList);
				updateCheckPngErrorData(pngsErrList);
				updateCheckCodePngData(codePngsList);
			}
		}
		
		private function onParserError(evt:DataEvent):void
		{
			view.txtLog.text = evt.data;
		}
		
		private function startParserImage():void
		{
			view.btnParser.enabled = false;
			view.btnSaveDiffPngs.enabled = false;
			view.btnParserHistory.enabled = false;
			view.txtLog.text = "正在检查文件...";
			
			if (_fileCodeRootPath.exists && _fileCCBRootPath1.exists && _fileCCBRootPath2.exists)
			{
				_parserImage.parser(_fileCodeRootPath.nativePath);
				_parserCCB.parser([_fileCCBRootPath1.nativePath, _fileCCBRootPath2.nativePath]);
			}
			else
			{
				view.txtLog.text = "请检查目录!";
			}
		}
		
		private function updatePlistListData(plistPngsDiffList:Object):void
		{
			var plistData:ArrayCollection = new ArrayCollection();
			
			for(var plist:String in plistPngsDiffList)
			{
				var data:Array = [];
				
				for each(var png:String in plistPngsDiffList[plist])
				{
					data.push(png);
				}
				
				plistData.addItem({"label":plist, "pngs":data});
			}
			
			view.plistData = plistData;
			
			var pngs:Array = plistData[0].pngs;
			view.plistPngsData.source = pngs;
		}
		
		private function updateCCBData(ccbList:Object):void
		{
			var ccbPlist:ArrayCollection = new ArrayCollection();
			
			for(var ccb:String in ccbList)
			{
				var data:Array = [];
				
				for(var plist:String in ccbList[ccb])
				{
					var pngs:Array = [];
					
					for(var png:String in ccbList[ccb][plist])
					{
						pngs.push({"label":png});
					}
					
					data.push({"label":plist, "pngs":pngs});
				}
				
				ccbPlist.addItem({"label":ccb, "plists":data});
			}
			
			view.ccbData = ccbPlist;
			
			var plists:Array = ccbPlist[0].plists;
			view.ccbPlistData.source = plists;
			
			if (plists.length > 0)
			{
				var plistPngs:Array = plists[0].pngs;
				view.ccbPlistPngsData.source = plistPngs
			}
		}

		private function updateCheckPngErrorData(checkPngError:Object):void
		{
			var checkPngErrorListData:Array = [];
			
			for(var key:String in checkPngError)
			{
				checkPngErrorListData.push(key);
			}
			
			view.checkErrorData.source = checkPngErrorListData;
		}
		
		private function updateCheckCodePngData(codePngList:Object):void
		{
			var checkCodePngListData:Array = [];
			
			for (var key:String in codePngList)
			{
				checkCodePngListData.push(key);
			}
			
			view.checkCodePngData.source = checkCodePngListData;
		}
		
		private function onParserLog(evt:DataEvent):void
		{
			view.txtLog.text = "解析:" + evt.data;
		}
		
		override public function destroy():void
		{
			view.removeEventListener(MouseEvent.CLICK, onViewClick);
			
			_parserImage.removeEventListener("parser_item", onParserLog);
			_parserImage.removeEventListener("parser_error", onParserLog);
			_parserCCB.removeEventListener("parser_item", onParserLog);
			
			_parserImage.removeEventListener("parser_complete", onParserComplete);
			_parserImage.removeEventListener("parser_error", onParserComplete);
			_parserCCB.removeEventListener("parser_complete", onParserComplete);
			
			_fileCodeRootPath.removeEventListener(Event.SELECT, onFileSelected);
			_fileCCBRootPath1.removeEventListener(Event.SELECT, onFileSelected);
			_fileCCBRootPath2.removeEventListener(Event.SELECT, onFileSelected);
			
			super.destroy();
		}
	}
}