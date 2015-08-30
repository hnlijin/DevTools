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
	import core.view.MultiLangueKeyView;
	
	import utils.FileUtils;
	import utils.parser.ParserLangKey;
	
	public class MultiLangueKeyMediator extends _BaseMediator
	{
		[Inject]
		public var view:MultiLangueKeyView
		
		private var _multiLanguageParser:ParserLangKey = new ParserLangKey();
		
		private var _dataLangCodeRootPath:ArrayCollection = new ArrayCollection();
		private var _dataLangEnPath:ArrayCollection = new ArrayCollection();
		
		private var _defautlCodeRootPath:Array = [File.documentsDirectory.nativePath + "/workspace/familyfarm2-client-code/FamilyFarm"];
		private var _indexLangCodeRootPath:int = 0;
		private var _fileLangCodeRootPath:File = new File();
		
		private var _defautlLangEnPath:Array = [File.documentsDirectory.nativePath + "/workspace/farm2-mobile-asset/server_farm/en.plist"];
		private var _indexLangEnPath:int = 0;
		private var _fileLangEnPath:File = new File();
		
		public function MultiLangueKeyMediator()
		{
			super();
		}
		
		override public function initialize():void
		{
			super.initialize();
			
			view.addEventListener(MouseEvent.CLICK, onViewClick);
			
			_dataLangCodeRootPath.source = LocalDataMananger.getInstance().getLocalData("fileLangCodeRootPath", _defautlCodeRootPath) as Array;
			_indexLangCodeRootPath = LocalDataMananger.getInstance().getLocalData("indexLangCodeRootPath", _indexLangCodeRootPath) as int;
			
			_dataLangEnPath.source = LocalDataMananger.getInstance().getLocalData("fileLangEnPath", _defautlLangEnPath) as Array;
			_indexLangEnPath = LocalDataMananger.getInstance().getLocalData("indexLangEnPath", _indexLangEnPath) as int;
			
			view.txtCodeRootPath.addEventListener(IndexChangeEvent.CHANGE, onPathChangeHandler);
			view.txtCodeRootPath.textInput.enabled = false;
			
			_multiLanguageParser.addEventListener("parser_item", onParserLog);
			_multiLanguageParser.addEventListener("parser_error", onParserError);
			_multiLanguageParser.addEventListener("parser_complete", onParserComplete);
			
			_fileLangCodeRootPath.addEventListener(Event.SELECT, onFileSelected);
			_fileLangEnPath.addEventListener(Event.SELECT, onFileSelected);
			
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
				startParserLang();
			}
			else if (evt.target == view.btnSaveFile)
			{
				var file:File = new File();
				file.nativePath = File.desktopDirectory.nativePath + "/check_lang";
				file.createDirectory();
				
				FileUtils.saveStringToPath(JSON.stringify(_multiLanguageParser.stringList), file.nativePath + "/stringList.json");
				FileUtils.saveStringToPath(JSON.stringify(_multiLanguageParser.diffList), file.nativePath + "/diffList.json");
				FileUtils.saveStringToPath(JSON.stringify(_multiLanguageParser.wuchaList), file.nativePath + "/wuchaList.json");
				FileUtils.saveStringToPath(JSON.stringify(_multiLanguageParser.errList), file.nativePath + "/errList.json");
				
				view.txtLog.text = "已经保存相关文件到桌面，plisDiffList.json, ccbPngsList.json, pngsErrList.json, codePngsList.json"
			}
			else if (evt.target == view.btnParserHistory)
			{
				var stringListStr:String = FileUtils.loadStringWidthPath(File.applicationStorageDirectory.nativePath + "/check_lang/stringList.json");
				var diffListStr:String = FileUtils.loadStringWidthPath(File.applicationStorageDirectory.nativePath + "/check_lang/diffList.json");
				var wuchaListStr:String = FileUtils.loadStringWidthPath(File.applicationStorageDirectory.nativePath + "/check_lang/wuchaList.json");
				var errListStr:String = FileUtils.loadStringWidthPath(File.applicationStorageDirectory.nativePath + "/check_lang/errList.json");
				
				var stringList:Object = JSON.parse(stringListStr);
				var diffList:Array = JSON.parse(diffListStr) as Array;
				var wuchaList:Object = JSON.parse(wuchaListStr);
				var errList:Object = JSON.parse(errListStr);
				
				if (stringListStr != "" && diffList != null && wuchaListStr != "" && errListStr != "")
				{
					updateStringListData(stringList);
					updateDiffListData(diffList);
					updateWuchaListData(wuchaList);
					updateErrorListData(errList);
				}
				else
				{
					startParserLang();
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
				_fileLangCodeRootPath.browseForDirectory("选择代码根目录");
			}
			else if (evt.target == view.btnLangEnPath)
			{
				_fileLangEnPath.browse();
			}
			else if (evt.target == view.btnOpenCodeRootPath)
			{
				_fileLangCodeRootPath.openWithDefaultApplication();
			}
			else if (evt.target == view.btnOpenLaneEnPath)
			{
				_fileLangEnPath.openWithDefaultApplication();
			}
			else if (evt.target == view.btnDelCodeRootPath)
			{
				if (view.txtCodeRootPath.selectedIndex >= 0)
				{
					_dataLangCodeRootPath.removeItemAt(view.txtCodeRootPath.selectedIndex);
					_indexLangCodeRootPath = view.txtCodeRootPath.selectedIndex - 1;
					_indexLangCodeRootPath = _indexLangCodeRootPath < 0 ? 0 : _indexLangCodeRootPath;
					
					LocalDataMananger.getInstance().setLocalData("fileLangCodeRootPath", _dataLangCodeRootPath.source);
					LocalDataMananger.getInstance().setLocalData("indexLangCodeRootPath", _indexLangCodeRootPath);
					LocalDataMananger.getInstance().saveLocalData();
					
					updatePaths();
				}
			}
			else if (evt.target == view.btnDelLangEnPath)
			{
				if (view.txtLangEnPath.selectedIndex >= 0)
				{
					_dataLangEnPath.removeItemAt(view.txtLangEnPath.selectedIndex);
					_indexLangEnPath = view.txtLangEnPath.selectedIndex - 1;
					_indexLangEnPath = _indexLangEnPath < 0 ? 0 : _indexLangEnPath;
					
					LocalDataMananger.getInstance().setLocalData("fileLangEnPath", _dataLangEnPath.source);
					LocalDataMananger.getInstance().setLocalData("indexLangEnPath", _indexLangEnPath);
					LocalDataMananger.getInstance().saveLocalData();
					
					updatePaths();
				}
			}
		}
		
		private function startParserLang():void
		{
			view.btnParser.enabled = false;
			view.btnSaveFile.enabled = false;
			view.btnParserHistory.enabled = false;
			view.txtLog.text = "正在检查文件...";
			
			if (_fileLangCodeRootPath.exists)
			{
				_multiLanguageParser.parser(_fileLangCodeRootPath.nativePath, _fileLangEnPath.nativePath);
			}
			else
			{
				view.txtLog.text = "请检查目录!";
			}
		}
		
		private function onParserComplete(evt:DataEvent):void
		{
			if (_multiLanguageParser.isParserComplete())
			{
				view.btnParser.enabled = true;
				view.btnSaveFile.enabled = true;
				view.btnParserHistory.enabled = true;
				view.txtLog.text = "解析完成";
				
				var stringList:Object = _multiLanguageParser.stringList;
				FileUtils.saveStringToPath(JSON.stringify(stringList), File.applicationStorageDirectory.nativePath +  "/check_lang/stringList.json");
				
				var diffList:Array = _multiLanguageParser.diffList;
				FileUtils.saveStringToPath(JSON.stringify(diffList), File.applicationStorageDirectory.nativePath +  "/check_lang/diffList.json");
				
				var wuchaList:Object = _multiLanguageParser.wuchaList;
				FileUtils.saveStringToPath(JSON.stringify(wuchaList), File.applicationStorageDirectory.nativePath +  "/check_lang/wuchaList.json");
				
				var errList:Object = _multiLanguageParser.errList;
				FileUtils.saveStringToPath(JSON.stringify(errList), File.applicationStorageDirectory.nativePath +  "/check_lang/errList.json");
				
				updateStringListData(stringList);
				updateDiffListData(diffList);
				updateWuchaListData(wuchaList);
				updateErrorListData(errList);
			}
		}
		
		private function onParserError(evt:DataEvent):void
		{
			view.txtLog.text = evt.data;
		}
		
		private function onParserLog(evt:DataEvent):void
		{
			view.txtLog.text = "解析:" + evt.data;
		}
		
		private function updatePaths():void
		{
			view.txtCodeRootPath.dataProvider = _dataLangCodeRootPath;
			view.txtLangEnPath.dataProvider = _dataLangEnPath;
			
			if (_indexLangCodeRootPath > _dataLangCodeRootPath.length - 1)
			{
				_indexLangCodeRootPath = _dataLangCodeRootPath.length - 1;
			}
			
			if (_indexLangEnPath > _dataLangEnPath.length - 1)
			{
				_indexLangEnPath = _dataLangEnPath.length - 1;
			}
			
			view.txtCodeRootPath.selectedIndex = _indexLangCodeRootPath;
			view.txtLangEnPath.selectedIndex = _indexLangEnPath;
			
			view.txtCodeRootPathTip.text = "请添加目录";
			view.txtLangEnPathTip.text = "请添加目录";
			
			if (_dataLangCodeRootPath.length > 0)
			{
				var selectedItemForCodeRootPath:String = _dataLangCodeRootPath[view.txtCodeRootPath.selectedIndex];
				if (selectedItemForCodeRootPath != "")
				{
					_fileLangCodeRootPath.nativePath = selectedItemForCodeRootPath;
					view.txtCodeRootPathTip.text = _fileLangCodeRootPath.exists ? "有效目录" : "目录不存在";
				}
			}
			
			if (_dataLangEnPath.length > 0)
			{
				var selectedItemForLangEntPath:String = _dataLangEnPath[view.txtLangEnPath.selectedIndex];
				if (selectedItemForLangEntPath != "")
				{
					_fileLangEnPath.nativePath = selectedItemForLangEntPath;
					view.txtLangEnPathTip.text = _fileLangEnPath.exists ? "有效目录" : "目录不存在";
				}
			}
		}
		
		protected function onPathChangeHandler(event:IndexChangeEvent):void
		{
			if (event.target == view.txtCodeRootPath)
			{
				_indexLangCodeRootPath = view.txtCodeRootPath.selectedIndex;
				
				LocalDataMananger.getInstance().setLocalData("indexLangCodeRootPath", _indexLangCodeRootPath);
				LocalDataMananger.getInstance().saveLocalData();
				
				updatePaths();
			}
		}
		
		private function onFileSelected(evt:Event):void
		{
			if (evt.target == _fileLangCodeRootPath)
			{
				_dataLangCodeRootPath.source.push(_fileLangCodeRootPath.nativePath);
				_indexLangCodeRootPath = _dataLangCodeRootPath.length - 1;
				_indexLangCodeRootPath = _indexLangCodeRootPath < 0 ? 0 : _indexLangCodeRootPath;
				
				LocalDataMananger.getInstance().setLocalData("fileLangCodeRootPath", _dataLangCodeRootPath.source);
				LocalDataMananger.getInstance().setLocalData("indexLangCodeRootPath", _indexLangCodeRootPath);
				LocalDataMananger.getInstance().saveLocalData();
				
				updatePaths();
			}
			else if (evt.target == _fileLangEnPath)
			{
				_dataLangEnPath.source.push(_fileLangEnPath.nativePath);
				_indexLangEnPath = _dataLangEnPath.length - 1;
				_indexLangEnPath = _indexLangEnPath < 0 ? 0 : _indexLangEnPath;
				
				LocalDataMananger.getInstance().setLocalData("fileLangEnPath", _dataLangEnPath.source);
				LocalDataMananger.getInstance().setLocalData("indexLangEnPath", _indexLangEnPath);
				LocalDataMananger.getInstance().saveLocalData();
				
				updatePaths();
			}
		}
		
		private function updateStringListData(stringList:Object):void
		{
			var stringListData:Array = [];
			
			for(var key:String in stringList)
			{
				stringListData.push(key);
			}
			
			view.stringData.source = stringListData;
		}
		
		private function updateDiffListData(diffList:Array):void
		{
			view.nouseStringData.source = diffList;
		}
		
		private function updateWuchaListData(wuchaList:Object):void
		{
			var wuchaListData:Array = [];
			
			for(var key:String in wuchaList)
			{
				wuchaListData.push(key);
			}
			
			view.wuchaStringData.source = wuchaListData;
		}
		
		private function updateErrorListData(errList:Object):void
		{
			var errListData:Array = [];
			
			for(var key:String in errList)
			{
				errListData.push(key);
			}
			
			view.checkErrorStringData.source = errListData;
		}
	}
}