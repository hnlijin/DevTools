package core.mediator
{
	import flash.events.MouseEvent;
	
	import core.view.MainView;
	import core.view.SimulatorDirView;
	
	import robotlegs.bender.bundles.mvcs.Mediator;
	
	public class MainMediator extends Mediator
	{
		[Inject]
		public var view:MainView;
		
		public function MainMediator()
		{
			super();
		}
		
		override public function initialize():void
		{
			super.initialize();
			
			view.btnSyncLua.addEventListener(MouseEvent.CLICK, onViewBtnSyncLua);
		}
		
		private function onViewBtnSyncLua(evt:MouseEvent):void
		{
			new SimulatorDirView().show(view.parent);
		}
		
		override public function destroy():void
		{
			view.btnSyncLua.removeEventListener(MouseEvent.CLICK, onViewBtnSyncLua);
			
			super.destroy();
		}
	}
}