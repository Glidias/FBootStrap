package com.flashartofwar.fbootstrap.events {
	import flash.events.Event;

public class BootstrapEvent extends AbstractDataEvent {

    public static const HANDLER_COMPLETE:String = "handlerComplete";
    public static const COMPLETE:String = "com.flashartofwar.fbootstrap.events.BootstrapEvent.COMPLETE"

    public function BootstrapEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
    {
        super(this, type, data, bubbles, cancelable);
    }
	
	public override function clone():Event 
	{ 
		return new BootstrapEvent(type, data, bubbles, cancelable);
	} 
		
	public override function toString():String 
	{ 
		return formatToString("BootstrapEvent", "type", "bubbles", "cancelable", "data"); 
	}
}
}