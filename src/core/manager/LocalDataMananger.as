package core.manager
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	public class LocalDataMananger
	{
		private var _localData:Object;
		private static var _instance:LocalDataMananger = null;
		private static const LOCALDATA_FILE_PATH:String = "config/app_local_data.json";
		
		public function LocalDataMananger()
		{
			this._localData = {};
			if (_instance != null)
			{
				throw new Error("LocalDataMananger is Simple Instance!!!");
			}
			this.readLocalData();
		}
		
		private function readLocalData() : void
		{
			var fs:FileStream;
			var jsonStr:String;
			var file:* = File.applicationDirectory.resolvePath(LOCALDATA_FILE_PATH);
			if (file.exists == true)
			{
				fs = new FileStream();
				fs.open(file, FileMode.READ);
				jsonStr = fs.readUTFBytes(fs.bytesAvailable);
				try
				{
					this._localData = JSON.parse(jsonStr);
				}
				catch (err:Error)
				{
					if (_localData == null)
					{
						_localData = {};
					}
				}
				fs.close();
			}
		}
		
		public function getLocalData(key:String, value:Object = null) : Object
		{
			if (this._localData != null && this._localData[key] != null)
			{
				return this._localData[key];
			}
			return value;
		}
		
		public function setLocalData(key:String, value:Object) : void
		{
			if (this._localData != null)
			{
				this._localData[key] = value;
			}
		}
		
		public function saveLocalData() : void
		{
			var file:File = File.applicationDirectory.resolvePath(LOCALDATA_FILE_PATH);
			var writefile:File = new File(file.nativePath.toString());
			var fileStream:* = new FileStream();
			fileStream.open(writefile, FileMode.WRITE);
			fileStream.writeMultiByte(JSON.stringify(this._localData), "utf-8");
			fileStream.close();
		}
		
		public static function getInstance() : LocalDataMananger
		{
			if (_instance == null)
			{
				_instance = new LocalDataMananger;
			}
			return _instance;
		}
	}
}