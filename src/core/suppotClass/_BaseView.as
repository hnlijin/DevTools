package core.suppotClass
{
	import spark.components.Group;
	
	import robotlegs.bender.extensions.contextView.ContextView;

	public class _BaseView extends Group
	{
		[Inject]
		public var contextView:ContextView;
		
		public function _BaseView()
		{
		}
		
		public function show(parent:Group):void
		{
			if (parent != null)
			{
				parent.addElement(this);
			}
		}
		
		public function close():void
		{
			if (parent is Group)
			{
				(parent as Group).removeElement(this);
			}
		}
	}
}