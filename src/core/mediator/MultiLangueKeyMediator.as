package core.mediator
{
	import flash.events.MouseEvent;
	
	import core.suppotClass._BaseMediator;
	import core.view.MultiLangueKeyView;
	
	public class MultiLangueKeyMediator extends _BaseMediator
	{
		[Inject]
		public var view:MultiLangueKeyView
		
		public function MultiLangueKeyMediator()
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
			if (evt.target == view.btnClose)
			{
				view.close();
			}
		}
	}
}