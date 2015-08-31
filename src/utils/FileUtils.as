package utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import miniui.utils.MString;
	
	import utils.parser.ParserPlist;
	
	import zero.zip.Zip;

	public class FileUtils
	{
		static public function loadStringWidthFile(file:File):String
		{
			if (file.exists == true)
			{
				var f:FileStream = new FileStream();
				f.open(file, FileMode.READ)
				var str:String = f.readUTFBytes(f.bytesAvailable);
				f.close();
				return str;
			}
			return "";
		}
		
		static public function loadStringWidthPath(path:String):String
		{
			var file:File = File.applicationDirectory.resolvePath(path);
			var str:String = "";
			if (file.exists == true)
			{
				var f:FileStream = new FileStream();
				f.open(file, FileMode.READ)
				str = f.readUTFBytes(f.bytesAvailable);
				f.close();
			}
			return str;
		}
		
		/**
		 * 把File文件或文件夹下的所有文件都添加到Zip里
		*/
		public static function fileToZip(zip:Zip, file:File, date:Date, fileName:String = ""):void
		{
			var fileList:Array = null;
			var fileItem:File = null;
			var zipFileName:String = null;
			var fileStream:FileStream = null;
			var byteArray:ByteArray = null;
			if (zip == null || file == null || date == null || file.exists == false)
			{
				return;
			}
			if (file.isDirectory == true)
			{
				fileList = file.getDirectoryListing();
				for each (fileItem in fileList)
				{
					
					fileToZip(zip, fileItem, date, fileName == "" ? (file.name) : (fileName + "/" + file.name));
				}
			}
			else if (file.name.charAt(0) != "." && file.exists == true)
			{
				zipFileName = fileName == "" ? (file.name) : (fileName + "/" + file.name);
				fileStream = new FileStream();
				fileStream.open(file, FileMode.READ);
				byteArray = new ByteArray();
				fileStream.readBytes(byteArray, 0, fileStream.bytesAvailable);
				zip.add(byteArray, zipFileName, date);
				fileStream.close();
			}
		}
		
		/**
		 * 保存zip文件到path文件夹下
		 */
		public static function saveZip(zip:Zip, path:String) : void
		{
			if (zip == null || path == "")
			{
				return;
			}
			
			var byteArray:ByteArray = zip.encode();
			var fullPath:String = path + ".zip";
			var file:File = new File(fullPath);
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(byteArray, 0, byteArray.length);
			fileStream.close();
		}
		
		/**
		 * 保存文件到path文件夹下
		 */
		public static function saveStringToPath(source:String, path:String) : void
		{
			if (source == "" || path == "")
			{
				return;
			}
			
			var file:File = new File(path);
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeUTFBytes(source);
			fileStream.close();
		}
		
		/**
		 * 根据扩展名递归检出当前File下所有的文件
		 */
		public static function recursiveCheckoutFile(file:File, checkoutList:Array, extension:String, condition:Function = null) : void
		{
			var fileItem:File = null;
			var data:Object = null;
			if (file == null || file.exists == false)
			{
				return;
			}
			var fileList:* = file.getDirectoryListing();
			for each (fileItem in fileList)
			{
				
				if (fileItem.isDirectory == true)
				{
					if (condition != null) condition(fileItem);
					
					recursiveCheckoutFile(fileItem, checkoutList, extension, condition);
					continue;
				}
				if (fileItem.extension == extension || extension == "")
				{
					if (condition == null || condition(fileItem) == true)
					{
						data = {};
						data.label = fileItem.name;
						data.selected = false;
						data.filePath = fileItem.nativePath;
						data.file = fileItem;
						checkoutList.push(data);
					}
				}
			}
		}
		
		/**
		 * 检出当前File下所有的文件夹
		 */
		public static function checkoutDirWithFile(file:File, checkoutList:Array, condition:Function = null):void
		{
			var fileList:Array = null;
			var fileItem:File = null;
			var data:Object = null;
			if (file != null)
			{
				fileList = file.getDirectoryListing();
				for each (fileItem in fileList)
				{
					if (fileItem.isDirectory == true)
					{
						if (condition == null || condition(fileItem) == true)
						{
							data = {};
							data.label = fileItem.name;
							data.selected = false;
							data.filePath = fileItem.nativePath;
							data.file = fileItem;
							checkoutList.push(data);
						}
					}
				}
			}
		}
		
		/**
		 * 检出Mac OS下所有的模拟器目录
		 */
		public static function checkoutDirWithMacOSSimulator(checkoutList:Array) : void
		{
			var devicesFileList:Array = null;
			var _loc_4:File = null;
			var _loc_5:String = null;
			var _loc_6:File = null;
			var _loc_7:Object = null;
			var _loc_8:Array = null;
			var _loc_9:Object = null;
			var _loc_10:File = null;
			var _loc_11:String = null;
			var _loc_12:File = null;
			var _loc_13:File = null;
			var _loc_14:String = null;
			var str:String = null;
			var devicePlistObj:Object = null;
			var runtimeVer:String = null;
			var data:Object = null;
			var _loc_21:String = null;
			var devicesFile:File = File.applicationDirectory.resolvePath(File.userDirectory.nativePath + "/Library/Developer/CoreSimulator/Devices");
			if (devicesFile != null && checkoutList != null)
			{
				devicesFileList = devicesFile.getDirectoryListing();
				for each (_loc_4 in devicesFileList)
				{
					
					if (_loc_4.isDirectory == true)
					{
						_loc_5 = _loc_4.nativePath + "/data/Containers/Data/Application";
						_loc_6 = File.applicationDirectory.resolvePath(_loc_5);
						if (_loc_6.exists == true)
						{
							_loc_7 = {};
							_loc_8 = [];
							_loc_9 = {};
							for each (_loc_10 in _loc_6.getDirectoryListing())
							{
								
								_loc_11 = _loc_10.nativePath + "/Library/Caches";
								_loc_12 = File.applicationDirectory.resolvePath(_loc_11);
								if (_loc_12.exists == true)
								{
									for each (_loc_13 in _loc_12.getDirectoryListing())
									{
										
										_loc_14 = _loc_13.name;
										if (_loc_14.indexOf("com.funplus.") > -1)
										{
											_loc_9[_loc_14] = _loc_12.nativePath;
											_loc_7[_loc_14] = _loc_12.nativePath;
											_loc_8.push(_loc_12.nativePath);
										}
									}
								}
							}
							if (_loc_8.length > 0)
							{
								str = FileUtils.loadStringWidthPath(_loc_4.nativePath + "/device.plist");
								devicePlistObj = ParserPlist.parserPlistToObject(str);
								runtimeVer = String(devicePlistObj.runtime);
								runtimeVer = runtimeVer.replace("com.apple.CoreSimulator.SimRuntime.iOS-", "");
								runtimeVer = MString.replaceStr(runtimeVer, "-", ".");
								data = {};
								data.filePath = _loc_4.nativePath;
								data.label = String(devicePlistObj.name) + " [" + runtimeVer + "]";
								data.paths = _loc_7;
								data.bundles = [];
								checkoutList.push(data);
								for (_loc_21 in _loc_9)
								{
									data.bundles.push(_loc_21);
								}
							}
						}
					}
				}
			}
		}
	}
}
