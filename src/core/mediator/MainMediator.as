package core.mediator
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import spark.components.Group;
	
	import core.suppotClass._BaseMediator;
	import core.view.ImageStatisticsView;
	import core.view.MainView;
	import core.view.MultiLangueKeyView;
	import core.view.SimulatorDirView;
	
	public class MainMediator extends _BaseMediator
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
			view.btnImageStatistics.addEventListener(MouseEvent.CLICK, onViewImageStatistics);
			view.addEventListener(MouseEvent.CLICK, onViewClick);
		}
		
		private function onViewClick(evt:MouseEvent):void
		{
			if (evt.target == view.btnMultiLangKey)
			{
				var subView:MultiLangueKeyView = new MultiLangueKeyView();
				subView.addEventListener(Event.ADDED_TO_STAGE, onSubViewAddToStage);
				subView.show(view.parent as Group);
			}
		}
		
		private function onViewBtnSyncLua(evt:MouseEvent):void
		{
			var subView:SimulatorDirView = new SimulatorDirView();
			subView.addEventListener(Event.ADDED_TO_STAGE, onSubViewAddToStage);
			subView.show(view.parent as Group);
		}
		
		private function onViewImageStatistics(evt:MouseEvent):void
		{
			var subView:ImageStatisticsView = new ImageStatisticsView();
			subView.addEventListener(Event.ADDED_TO_STAGE, onSubViewAddToStage);
			subView.show(view.parent as Group);
		}
		
		private function onSubViewAddToStage(evt:Event):void
		{
			var subView:DisplayObject = evt.target as DisplayObject;
			subView.addEventListener(Event.REMOVED_FROM_STAGE, onSubViewRemoveFromStage);
			
			view.visible = false;
		}
		
		private function onSubViewRemoveFromStage(evt:Event):void
		{
			var subView:DisplayObject = evt.target as DisplayObject;
			subView.removeEventListener(Event.ADDED_TO_STAGE, onSubViewAddToStage);
			subView.removeEventListener(Event.REMOVED_FROM_STAGE, onSubViewRemoveFromStage);
			
			view.visible = true;
		}
		
		override public function destroy():void
		{
			view.btnSyncLua.removeEventListener(MouseEvent.CLICK, onViewBtnSyncLua);
			view.btnImageStatistics.removeEventListener(MouseEvent.CLICK, onViewImageStatistics);
			view.removeEventListener(MouseEvent.CLICK, onViewClick);
			
			super.destroy();
		}
	}
}