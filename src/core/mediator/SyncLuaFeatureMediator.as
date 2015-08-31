package core.mediator
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	
	import spark.events.IndexChangeEvent;
	
	import core.manager.LocalDataMananger;
	import core.suppotClass._BaseMediator;
	import core.view.SyncLuaFeatureView;
	
	import utils.FileUtils;
	
	import zero.zip.Zip;
	
	public class SyncLuaFeatureMediator extends _BaseMediator
	{
		[Inject]
		public var view:SyncLuaFeatureView
		
		private var _dataCodeScriptPath:ArrayCollection = new ArrayCollection();
		private var _dataSvnScriptPath:ArrayCollection = new ArrayCollection();
		
		private var _defautlCodeScriptPath:Array = [File.documentsDirectory.nativePath + "/workspace/familyfarm2-client-code/FamilyFarm/Resources/localItemResources/script"];
		private var _indexCodeScriptPath:int = 0;
		private var _fileCodeScriptPath:File = new File();
		
		private var _defautSvnScriptPath:Array = [File.documentsDirectory.nativePath + "/workspace/farm2-mobile-asset/server_farm/scripts"];
		private var _indexSvnScriptPath:int = 0;
		private var _fileSvnScriptPath:File = new File();
		
		private var _checkoutFeatureList:Array = [];

		public function SyncLuaFeatureMediator()
		{
			super();
		}
		
		override public function initialize():void
		{
			super.initialize();
			
			view.addEventListener(MouseEvent.CLICK, onViewClick);
			view.deviceComboBox.addEventListener(IndexChangeEvent.CHANGE, onViewIndexChange);
			
			_dataCodeScriptPath.source = LocalDataMananger.getInstance().getLocalData("fileCodeScriptPath", _defautlCodeScriptPath) as Array;
			_indexCodeScriptPath = LocalDataMananger.getInstance().getLocalData("indexCodeScriptPath", _indexCodeScriptPath) as int;
			
			_dataSvnScriptPath.source = LocalDataMananger.getInstance().getLocalData("fileSvnScriptPath", _defautSvnScriptPath) as Array;
			_indexSvnScriptPath = LocalDataMananger.getInstance().getLocalData("indexSvnScriptPath", _indexSvnScriptPath) as int;
			
			view.txtCodeScriptPath.addEventListener(IndexChangeEvent.CHANGE, onPathChangeHandler);
			view.txtCodeScriptPath.textInput.enabled = false;
			
			view.txtSvnScriptPath.addEventListener(IndexChangeEvent.CHANGE, onPathChangeHandler);
			view.txtSvnScriptPath.textInput.enabled = false;
			
			_fileCodeScriptPath.addEventListener(Event.SELECT, onFileSelected);
			_fileSvnScriptPath.addEventListener(Event.SELECT, onFileSelected);
			
			view.listLuaFeature.addEventListener(IndexChangeEvent.CHANGE, onViewIndexChange);

			updatePaths();
			updateSimulatorPaths();
		}
		
		override public function destroy():void
		{
			view.removeEventListener(MouseEvent.CLICK, onViewClick);
			view.deviceComboBox.removeEventListener(IndexChangeEvent.CHANGE, onViewIndexChange);
			
			view.txtCodeScriptPath.removeEventListener(IndexChangeEvent.CHANGE, onPathChangeHandler);
			view.txtSvnScriptPath.removeEventListener(IndexChangeEvent.CHANGE, onPathChangeHandler);
			
			_fileCodeScriptPath.removeEventListener(Event.SELECT, onFileSelected);
			_fileSvnScriptPath.removeEventListener(Event.SELECT, onFileSelected);
			
			view.listLuaFeature.removeEventListener(IndexChangeEvent.CHANGE, onViewIndexChange);
			
			super.destroy();
		}
		
		private function onViewClick(evt:MouseEvent):void
		{
			if (evt.target == view.btnClose)
			{
				view.close();
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
			else if (evt.target == view.btnCodeScriptPath)
			{
				_fileCodeScriptPath.browseForDirectory("选择代码Script目录");
			}
			else if (evt.target == view.btnSvnScriptPath)
			{
				_fileSvnScriptPath.browseForDirectory("选择SVN://server_farm/script");
			}
			else if (evt.target == view.btnOpenCodeScriptPath)
			{
				_fileCodeScriptPath.openWithDefaultApplication();
			}
			else if (evt.target == view.btnSvnScriptPath)
			{
				_fileSvnScriptPath.openWithDefaultApplication();
			}
			else if (evt.target == view.btnDelCodeScriptPath)
			{
				if (view.txtCodeScriptPath.selectedIndex >= 0)
				{
					_dataCodeScriptPath.removeItemAt(view.txtCodeScriptPath.selectedIndex);
					_indexCodeScriptPath = view.txtCodeScriptPath.selectedIndex - 1;
					_indexCodeScriptPath = _indexCodeScriptPath < 0 ? 0 : _indexCodeScriptPath;
					
					LocalDataMananger.getInstance().setLocalData("fileCodeScriptPath", _dataCodeScriptPath.source);
					LocalDataMananger.getInstance().setLocalData("indexCodeScriptPath", _indexCodeScriptPath);
					LocalDataMananger.getInstance().saveLocalData();
					
					updatePaths();
				}
			}
			else if (evt.target == view.btnDelSvnScriptPath)
			{
				if (view.txtSvnScriptPath.selectedIndex >= 0)
				{
					_dataSvnScriptPath.removeItemAt(view.txtSvnScriptPath.selectedIndex);
					_indexSvnScriptPath = view.txtSvnScriptPath.selectedIndex - 1;
					_indexSvnScriptPath = _indexSvnScriptPath < 0 ? 0 : _indexSvnScriptPath;
					
					LocalDataMananger.getInstance().setLocalData("fileSvnScriptPath", _dataSvnScriptPath.source);
					LocalDataMananger.getInstance().setLocalData("indexSvnScriptPath", _indexSvnScriptPath);
					LocalDataMananger.getInstance().saveLocalData();
					
					updatePaths();
				}
			}
			else if (evt.target == view.btnSelectedAll || evt.target == view.btnUnSelectedAll)
			{
				var len:int = _checkoutFeatureList.length;
				for (var i:int = 0; i < len; i++)
				{
					_checkoutFeatureList[i].selected = evt.target == view.btnSelectedAll;
				}
				view.luaListData.source = _checkoutFeatureList;
			}
			else if (evt.target == view.btnSyncToSvn)
			{
				if (_fileSvnScriptPath.exists == true)
				{
					var len1:int = _checkoutFeatureList.length;
					var tempSucCount1:int = 0;
					var tempCount1:int = 0;
					var tempFile1:File = new File();
					var tempZipFile1:File = new File();
					var tempSvnFile1:File = new File();
					
					for (var a:int = 0; a < len1; a++)
					{
						if (_checkoutFeatureList[a].selected == true)
						{
							tempCount1 += 1;
							
							tempFile1 = _checkoutFeatureList[a].file as File;
							tempSvnFile1.nativePath = _fileSvnScriptPath.nativePath + "/" + tempFile1.name + ".zip";
							tempZipFile1.nativePath = tempFile1.nativePath + ".zip";
							
							if (tempZipFile1.exists == true)
							{
								tempZipFile1.moveTo(tempSvnFile1, true);
								tempSucCount1 += 1;
							}
						}
					}
					
					view.txtLog.text = "同步到SVN:script目录: 共" + tempCount1 + "个，同步成功" + tempSucCount1 + "个";
				}
				else
				{
					view.txtLog.text = "提示：请选择SVN:script目录!";
				}
			}
			else if (evt.target == view.btnZip)
			{
				var len2:int = _checkoutFeatureList.length;
				var date:Date = new Date();
				var tempSucCount2:int = 0;
				
				for (var j:int = 0; j < len2; j++)
				{
					if (_checkoutFeatureList[j].selected == true)
					{
						var zip:Zip = new Zip();
						var tempFile:File = _checkoutFeatureList[j].file as File;
						FileUtils.fileToZip(zip, tempFile, date);
						FileUtils.saveZip(zip, tempFile.nativePath);
						tempSucCount2 += 1;
					}
				}
				
				view.txtLog.text = "压缩文件: 成功" + tempSucCount2 + "个";
			}
			else if (evt.target == view.btnDelZip)
			{
				var file:File = new File();
				var len3:int = _checkoutFeatureList.length;
				var tempSucCount3:int = 0;
				var tempCount3:int = 0;
				
				for (var k:int = 0; k < len3; k++)
				{
					if (_checkoutFeatureList[k].selected == true)
					{
						tempCount3 += 1;
						
						file.nativePath = _checkoutFeatureList[k].filePath + ".zip";
						if (file.exists == true)
						{
							file.deleteFile();
							tempSucCount3 += 1;
						}
					}
				}
				
				view.txtLog.text = "删除Zip文件: 共" + tempCount3 + "个， 删除成功" + tempSucCount3 + "个";
			}
			else if (evt.target == view.btnRefreshSimulatorDir)
			{
				updateSimulatorPaths();
			}
			else if (evt.target == view.btnSyncToSimulatorDir)
			{
				if (simulatorDirFile == null || simulatorDirFile.exists == false)
				{
					view.txtLog.text = "模拟器目录不存在，请刷新模拟器目录!";
				}
				else
				{
					var scriptFile:File = new File();
					var len4:int = _checkoutFeatureList.length;
					var tempFile4:File = null;
					var tempSucCount4:int = 0;
					
					for (var m:int = 0; m < len4; m++)
					{
						if (_checkoutFeatureList[m].selected == true)
						{
							tempFile4 = _checkoutFeatureList[m].file;
							if (tempFile4.exists == true)
							{
								scriptFile.nativePath = simulatorDirFile.nativePath + "/Resources/scripts/" + tempFile4.name;
								scriptFile.createDirectory();
								tempFile4.copyTo(scriptFile, true);
								tempSucCount4 += 1;
							}
						}
					}
					
					view.txtLog.text = "同步资源到模拟器: 成功" + tempSucCount4 + "个";
				}
			}
			else if (evt.target == view.btnOpenSimulatorDir)
			{
				if (simulatorDirFile == null || simulatorDirFile.exists == false)
				{
					view.txtLog.text = "模拟器目录不存在，请刷新模拟器目录!";
				}
				else
				{
					simulatorDirFile.openWithDefaultApplication();
				}
			}
		}
		
		private function onViewIndexChange(evt:IndexChangeEvent):void
		{
			if (evt.target == view.deviceComboBox)
			{
				if (view.deviceComboBox.selectedIndex >= 0 && view.listDataSimulatorIds.length > 0)
				{
					var deviceItem:Object = view.listDataSimulatorDir[view.deviceComboBox.selectedIndex];
					view.listDataSimulatorIds.source = deviceItem.bundles;
					view.idsComboxBox.selectedIndex = 0;
				}
			}
			else if (evt.target == view.listLuaFeature)
			{
				if (view.listLuaFeature.selectedIndex >= 0)
				{
					var featrueData:Object = view.luaListData[view.listLuaFeature.selectedIndex];
					var checkoutList:Array = [];
					FileUtils.recursiveCheckoutFile(featrueData.file, checkoutList, "");
					view.luaSelectedListData.source = checkoutList;
				}
			}
		}
		
		private function get simulatorDirFile():File
		{
			if (view.deviceComboBox.selectedIndex >= 0 && view.idsComboxBox.selectedIndex >= 0)
			{
				var paths:Object = view.listDataSimulatorDir[view.deviceComboBox.selectedIndex].paths;
				var id:String = view.listDataSimulatorIds[view.idsComboxBox.selectedIndex];
			
				if (paths && id && paths[id])
				{
					var simulatorFile:File = new File();
					simulatorFile.nativePath = paths[id];
					return simulatorFile;
				}
			}
			
			return null;
		}
		
		private function updateSimulatorPaths():void
		{
			var checkoutList:Array = [];
			FileUtils.checkoutDirWithMacOSSimulator(checkoutList);
			view.listDataSimulatorDir.source = checkoutList;
			view.deviceComboBox.selectedIndex = 0;
			
			if (view.deviceComboBox.selectedIndex >= 0 && view.listDataSimulatorDir.length > 0)
			{
				var deviceItem:Object = view.listDataSimulatorDir[view.deviceComboBox.selectedIndex];
				view.listDataSimulatorIds.source = deviceItem.bundles;
				view.idsComboxBox.selectedIndex = 0;
			}
		}
		
		private function updatePaths():void
		{
			view.txtCodeScriptPath.dataProvider = _dataCodeScriptPath;
			view.txtSvnScriptPath.dataProvider = _dataSvnScriptPath;
			
			if (_indexCodeScriptPath > _dataCodeScriptPath.length - 1)
			{
				_indexCodeScriptPath = _dataCodeScriptPath.length - 1;
			}
			
			if (_indexSvnScriptPath > _dataSvnScriptPath.length - 1)
			{
				_indexSvnScriptPath = _dataSvnScriptPath.length - 1;
			}
			
			view.txtCodeScriptPath.selectedIndex = _indexCodeScriptPath;
			view.txtSvnScriptPath.selectedIndex = _indexSvnScriptPath;
			
			view.txtCodeScriptPathTip.text = "请添加目录";
			view.txtSvnScriptPathTip.text = "请添加目录";
			
			if (_dataCodeScriptPath.length > 0)
			{
				var selectedItemForCodeRootPath:String = _dataCodeScriptPath[view.txtCodeScriptPath.selectedIndex];
				if (selectedItemForCodeRootPath != "")
				{
					_fileCodeScriptPath.nativePath = selectedItemForCodeRootPath;
					view.txtCodeScriptPathTip.text = _fileCodeScriptPath.exists ? "有效目录" : "目录不存在";
					
					_checkoutFeatureList = [];
					FileUtils.checkoutDirWithFile(_fileCodeScriptPath, _checkoutFeatureList, checkFileCondition);
					view.luaListData.source = _checkoutFeatureList;
				}
			}
			
			if (_dataSvnScriptPath.length > 0)
			{
				var selectedItemForLangEntPath:String = _dataSvnScriptPath[view.txtSvnScriptPath.selectedIndex];
				if (selectedItemForLangEntPath != "")
				{
					_fileSvnScriptPath.nativePath = selectedItemForLangEntPath;
					view.txtSvnScriptPathTip.text = _fileSvnScriptPath.exists ? "有效目录" : "目录不存在";
				}
			}
		}
		
		private function checkFileCondition(file:File):Boolean
		{
			return true;
		}
		
		protected function onPathChangeHandler(event:IndexChangeEvent):void
		{
			if (event.target == view.txtCodeScriptPath)
			{
				_indexCodeScriptPath = view.txtCodeScriptPath.selectedIndex;
				
				LocalDataMananger.getInstance().setLocalData("indexCodeScriptPath", _indexCodeScriptPath);
				LocalDataMananger.getInstance().saveLocalData();
				
				updatePaths();
			}
			else if (event.target == view.txtSvnScriptPath)
			{
				_indexSvnScriptPath = view.txtSvnScriptPath.selectedIndex;
				
				LocalDataMananger.getInstance().setLocalData("indexSvnScriptPath", _indexSvnScriptPath);
				LocalDataMananger.getInstance().saveLocalData();
				
				updatePaths();
			}
		}
		
		private function onFileSelected(evt:Event):void
		{
			if (evt.target == _fileCodeScriptPath)
			{
				_dataCodeScriptPath.source.push(_fileCodeScriptPath.nativePath);
				_indexCodeScriptPath = _dataCodeScriptPath.length - 1;
				_indexCodeScriptPath = _indexCodeScriptPath < 0 ? 0 : _indexCodeScriptPath;
				
				LocalDataMananger.getInstance().setLocalData("fileCodeScriptPath", _dataCodeScriptPath.source);
				LocalDataMananger.getInstance().setLocalData("indexCodeScriptPath", _indexCodeScriptPath);
				LocalDataMananger.getInstance().saveLocalData();
				
				updatePaths();
			}
			else if (evt.target == _fileSvnScriptPath)
			{
				_dataSvnScriptPath.source.push(_fileSvnScriptPath.nativePath);
				_indexSvnScriptPath = _dataSvnScriptPath.length - 1;
				_indexSvnScriptPath = _indexSvnScriptPath < 0 ? 0 : _indexSvnScriptPath;
				
				LocalDataMananger.getInstance().setLocalData("fileSvnScriptPath", _dataSvnScriptPath.source);
				LocalDataMananger.getInstance().setLocalData("indexSvnScriptPath", _indexSvnScriptPath);
				LocalDataMananger.getInstance().saveLocalData();
				
				updatePaths();
			}
		}
	}
}