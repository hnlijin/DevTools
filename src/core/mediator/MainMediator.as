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
	import core.view.SyncLuaFeatureView;
	
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
			
			view.addEventListener(MouseEvent.CLICK, onViewClick);
		}
		
		private function onViewClick(evt:MouseEvent):void
		{
			if (evt.target == view.btnMultiLangKey)
			{
				var subView1:MultiLangueKeyView = new MultiLangueKeyView();
				subView1.addEventListener(Event.ADDED_TO_STAGE, onSubViewAddToStage);
				subView1.show(view.parent as Group);
			}
			else if (evt.target == view.btnSimulatorDir)
			{
				var subView2:SimulatorDirView = new SimulatorDirView();
				subView2.addEventListener(Event.ADDED_TO_STAGE, onSubViewAddToStage);
				subView2.show(view.parent as Group);
			}
			else if (evt.target == view.btnSyncLua)
			{
				var subView3:SyncLuaFeatureView = new SyncLuaFeatureView();
				subView3.addEventListener(Event.ADDED_TO_STAGE, onSubViewAddToStage);
				subView3.show(view.parent as Group);
			}
			else if (evt.target == view.btnImageStatistics)
			{
				var subView4:ImageStatisticsView = new ImageStatisticsView();
				subView4.addEventListener(Event.ADDED_TO_STAGE, onSubViewAddToStage);
				subView4.show(view.parent as Group);
			}
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
			view.removeEventListener(MouseEvent.CLICK, onViewClick);
			
			super.destroy();
		}
	}
}