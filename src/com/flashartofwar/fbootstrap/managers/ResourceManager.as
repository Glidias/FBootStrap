package com.flashartofwar.fbootstrap.managers
{
import com.flashartofwar.fbootstrap.events.BootstrapEvent;
import com.flashartofwar.fbootstrap.events.LoaderManagerEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;

/**
 * @author jessefreeman
 * @author Glidias
 */
public class ResourceManager extends EventDispatcher
{
    public var preloadList:Vector.<QueueRequest>;
    public var currentLoader:LoaderWrapper;
    private var resources:Array = [];
	
	private var _isCompleted:Boolean = false;
	private var _currentItemBulkRatio:Number = 0;
	private var bulkRatioLoaded:Number = 0;
	private var bulkPercDeclared:int = 0;
	private var bulkRatioDeclared:Number = 0;
	private var bulkItemRatios:Vector.<Number>;
	

    public function ResourceManager()
    {
		preloadList = new Vector.<QueueRequest>;
    }
	
	public function getResources():Array {
		return resources;
	}

    public function addToQueue(url:String, type:String, id:String = null, percRatio:Number=0 ):void {
        percRatio = percRatio < 0 ? -percRatio : percRatio;
		bulkRatioDeclared += percRatio;
		//try {
			if (bulkRatioDeclared > 1 ) throw new Error("Declared bulk ratio has exceeded limit! "+bulkRatioDeclared);
		//}
		//catch (e:Error) {
			//trace("Bulk ratio has exceeded");
			//percRatio = 0;
		//}
		preloadList.push(new QueueRequest(url, type, id, percRatio));
		bulkPercDeclared+= percRatio == 0 ? 0 : 1;
    }

    public function loadQueue():void
    {
		bulkRatioLoaded = 0;
		_isCompleted = false;
		bulkItemRatios  = new Vector.<Number>(preloadList.length);
		var i:int = bulkItemRatios.length;
		var undeclaredItems:int = (i - bulkPercDeclared);
		var ratioPerUndeclared:Number = undeclaredItems > 0 ? (1 - bulkRatioDeclared) /  undeclaredItems : 0;
		if ( !(ratioPerUndeclared > 0) && undeclaredItems > 0 ) 
			throw new Error("Invalid perc ratio per undeclared item! " + ratioPerUndeclared);
		while (--i > -1) {
			var request:QueueRequest = preloadList[i];
			bulkItemRatios[i] =  request.perc == 0 ?  ratioPerUndeclared : request.perc;
		}
        preload();
    }

    /**
     * Handles preloading our images. Checks to see how many are left then
     * calls loadNext or compositeImage.
     */
    private function preload():void
    {
        var totalLeft:int = preloadList.length;

        if (preloadList.length == 0)
        {
            onPreloadComplete();
        }
        else
        {
            loadNextFile();
        }
    }

    /**
     * Loads the next item in the preloadList
     */
    private function loadNextFile():void
    {
        var currentRequest:QueueRequest = preloadList.shift();
		_currentItemBulkRatio = bulkItemRatios.shift();

        currentLoader = new LoaderWrapper(currentRequest.type, currentRequest.id);
        addEventListeners(currentLoader);
        currentLoader.load(new URLRequest(currentRequest.url));
    }

    protected function addEventListeners(target:LoaderWrapper):void {
        target.addEventListener(Event.COMPLETE, onFileLoaded, false, 0, true);
		target.dispatcher.addEventListener(ProgressEvent.PROGRESS, onProgress, false , 0, true);
        target.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
        target.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, true);
    }

    protected function removeEventListeners(target:LoaderWrapper):void {
        target.removeEventListener(Event.COMPLETE, onFileLoaded);
		target.dispatcher.removeEventListener(ProgressEvent.PROGRESS, onProgress);
        target.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
        target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityError);
    }
	
	protected function onProgress(e:ProgressEvent):void {
		var myProgress:Number = bulkRatioLoaded + (e.bytesLoaded / e.bytesTotal) * _currentItemBulkRatio;
		dispatchEvent ( new LoaderManagerEvent(LoaderManagerEvent.PROGRESS, myProgress) );
	}

    /**
     * Handles onLoad, saves the BitmapData then calls preload
     */
    private function onFileLoaded(event:Event):void
    {
		bulkRatioLoaded += _currentItemBulkRatio;
        resources[currentLoader.id] = currentLoader.data;
		
        //Cleanup
        removeEventListeners(currentLoader);
       // currentLoader = null;  // tendency to produce null reference, need to look into this 

		dispatchEvent( new Event("onFileLoaded") );
		preload();
		
    }

    private function onIOError(event:IOErrorEvent):void {
		throw new Error(event);
    }

    private function onSecurityError(event:SecurityErrorEvent):void {
		throw new Error(event);
    }

    private function onPreloadComplete():void {
		_isCompleted = true;

        dispatchEvent(new Event(Event.COMPLETE));
    }
	
	public function get loaded():Boolean {
		return _isCompleted;
	}

    public function getResource(id:String):*
    {
		if (resources[id] == null) throw new Error("Resource retrieval failed:"+id)
        return resources[id];
    }

}
}

import flash.display.Loader;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.LoaderContext;

internal class LoaderWrapper extends EventDispatcher
{
    private var _type:String;
    private var _instance:*;
    private var _id:String;

    public function LoaderWrapper(type:String, id:String):void
    {
        _type = type.toLowerCase();

        if (_type == "urlloader")
        {
            _instance = new URLLoader();
        }
        else
        {
            _instance = new Loader();
        }
	
		_id = id;
    }
	

    public function get dispatcher():IEventDispatcher
    {
        if (_type == "urlloader")
        {
            return URLLoader(_instance);
        }
        else
        {
            return Loader(_instance).contentLoaderInfo;
        }
    }

    public function load(request:URLRequest, context:LoaderContext = null):void
    {
      
        if (_type == "urlloader")
        {
            URLLoader(_instance).load(request);
        }
        else
        {
            Loader(_instance).load(request, context);
        }
    }

    override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
    {
        dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }

    override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
    {
        dispatcher.removeEventListener(type, listener, useCapture);
    }


    public function get id():String {
        return _id;
    }

    public function get data():*
    {
        if (_type == "urlloader")
        {
            return URLLoader(_instance).data; 
        }
        else
        {
            return Loader(_instance).content;
        }
    }
}

internal class QueueRequest
{
    public var url:String;
    public var type:String;
	public var id:String;
	public var perc:Number;

    public function QueueRequest(url:String, type:String, id:String=null, percRatio:Number=0):void
    {
        this.url = url;
        this.type = type;
		this.id  = id;
		perc = percRatio;
    }
}
