package core
{
	import flash.events.IEventDispatcher;
	
	import core.mediator.ImageStatisticsMediator;
	import core.mediator.MainMediator;
	import core.mediator.MultiLangueKeyMediator;
	import core.mediator.SimulatorDirMediator;
	import core.mediator.SyncLuaFeatureMediator;
	import core.model.AppModel;
	import core.view.ImageStatisticsView;
	import core.view.MainView;
	import core.view.MultiLangueKeyView;
	import core.view.SimulatorDirView;
	import core.view.SyncLuaFeatureView;
	
	import robotlegs.bender.extensions.eventCommandMap.api.IEventCommandMap;
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.framework.api.IConfig;
	import robotlegs.bender.framework.api.IInjector;
	
	public final class ShareConfig implements IConfig
	{
		[Inject]
		public var injector:IInjector;
		
		[Inject]
		public var dispatcher:IEventDispatcher;
		
		[Inject]
		public var mediatorMap:IMediatorMap;
		
		[Inject]
		public var commandMap:IEventCommandMap;
		
		// 
		public var appModel:AppModel;
		
		
		public function configure():void
		{
			//model
			appModel = new AppModel();
			injector.injectInto(appModel);
			
			injector.map(core.model.AppModel).toValue(appModel);
			
			//view
			mediatorMap.map(core.view.SimulatorDirView).toMediator(core.mediator.SimulatorDirMediator);
			mediatorMap.map(core.view.MainView).toMediator(core.mediator.MainMediator);
			mediatorMap.map(core.view.ImageStatisticsView).toMediator(core.mediator.ImageStatisticsMediator);
			mediatorMap.map(core.view.MultiLangueKeyView).toMediator(core.mediator.MultiLangueKeyMediator);
			mediatorMap.map(core.view.SyncLuaFeatureView).toMediator(core.mediator.SyncLuaFeatureMediator);			
			
			//controller
//			commandMap.map(core.events.ModelEvent.PARSED_MODEL_ANIMATION_DATA_CHANGE).toCommand(core.controller.ModelCommand);

		}
	}
}
