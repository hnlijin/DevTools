package core.mediator
{
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	
	import spark.events.IndexChangeEvent;
	
	import core.view.SimulatorDirView;
	
	import robotlegs.bender.bundles.mvcs.Mediator;
	
	import utils.FileUtils;
	
	public class SimulatorDirMediator extends Mediator
	{
		[Inject]
		public var view:SimulatorDirView;
		
		[Bindable]
		private var deviceDataList:ArrayCollection = new ArrayCollection();
		
		[Bindable]
		private var idsDataList:ArrayCollection = new ArrayCollection();
		
		public function SimulatorDirMediator()
		{
			super();
		}
		
		override public function initialize():void
		{
			super.initialize();
			
			view.addEventListener(MouseEvent.CLICK, onViewClick);
			view.deviceComboBox.addEventListener(IndexChangeEvent.CHANGE, onDeviceChange);
			
			view.deviceComboBox.dataProvider = deviceDataList;
			view.idsComboxBox.dataProvider = idsDataList;
			
			view.deviceComboBox.selectedIndex = 0;
			view.idsComboxBox.selectedIndex = 0;
			
			var checkoutList:Array = [];
			FileUtils.checkoutDirWithMacOSSimulator(checkoutList);
			deviceDataList.source = checkoutList;
			
			updateIdsComboxBox();
		}
		
		private function onViewClick(evt:MouseEvent):void
		{
			if (evt.target == view.btnClose)
			{
				view.close();
			}
			else if (evt.target == view.btnOpenFolder)
			{
				var paths:Object = view.deviceComboBox.selectedItem.paths;
				var id:String = view.idsComboxBox.selectedItem;
				
				if (paths && id)
				{
					var path:String = paths[id];
					var file:File = new File();
					file.nativePath = path;
					if (file.exists)
					{
						file.openWithDefaultApplication();
					}
				}
			}
		}
		
		private function onDeviceChange(evt:IndexChangeEvent):void
		{
			updateIdsComboxBox();
		}
		
		private function updateIdsComboxBox():void
		{
			if (view.deviceComboBox.selectedItem.bundles != null)
			{
				idsDataList.source = view.deviceComboBox.selectedItem.bundles;
			}
			else
			{
				idsDataList.source =  [];
			}
		}
		
		override public function destroy():void
		{
			super.destroy();
			
			view.removeEventListener(MouseEvent.CLICK, onViewClick);
			view.deviceComboBox.removeEventListener(IndexChangeEvent.CHANGE, onDeviceChange);
		}
	}
}