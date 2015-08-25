package core.suppotClass
{
	import flash.display.DisplayObjectContainer;
	
	import mx.managers.PopUpManager;
	
	import spark.components.Group;
	
	import robotlegs.bender.extensions.contextView.ContextView;

	public class _BaseView extends Group
	{
		[Inject]
		public var contextView:ContextView;
		
		public function _BaseView()
		{
		}
		
		public function show(parent:DisplayObjectContainer):void
		{
			PopUpManager.addPopUp(this, parent, true);
		}
		
		public function close():void
		{
			
		}
	}
}