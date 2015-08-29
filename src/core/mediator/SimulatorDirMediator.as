package core.mediator
{
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.messaging.events.ChannelEvent;
	
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
			
			view.deviceComboBox.dataProvider = deviceDataList;
			view.idsComboxBox.dataProvider = idsDataList;
			
			view.addEventListener(MouseEvent.CLICK, onViewClick);
			
			var checkoutList:Array = [];
			FileUtils.checkoutDirWithMacOSSimulator(checkoutList);
			deviceDataList.source = checkoutList;
			deviceDataList.addEventListener(CollectionEvent.COLLECTION_CHANGE, onDeviceChange);
		}
		
		private function onViewClick(evt:MouseEvent):void
		{
			if (evt.target == view.btnClose)
			{
				view.close();
			}
		}
		
		private function onDeviceChange(evt:CollectionEvent):void
		{
			
		}
		
		override public function destroy():void
		{
			super.destroy();
			
			view.btnClose.removeEventListener(MouseEvent.CLICK, onViewClick);
		}
	}
}