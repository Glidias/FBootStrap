package com.flashartofwar.fbootstrap.managers {
import com.flashartofwar.fcss.utils.TypeHelperUtil;

import flash.utils.Proxy;
import flash.utils.flash_proxy;

dynamic public class SettingsManager extends Proxy
{

    public static const INIT:String = "init";
    private static var _instance:SettingsManager;
    private var _data:XML;
    private var cache:Array = [];

    public function SettingsManager(enforcer:SingletonEnforcer)
    {
        if (enforcer == null)
        {
            throw new Error("Error: Instantiation failed: Use GlobalDecalSheetManager.instance instead.");
        }
    }

    public static function get instance():SettingsManager
    {
        if (SettingsManager._instance == null)
        {
            trace("SettingsManager.instance()");
            SettingsManager._instance = new SettingsManager(new SingletonEnforcer());
        }
        return SettingsManager._instance;
    }

    flash_proxy override function getProperty(name:*):*
    {
        var propName:String = String(name);

        if (cache[propName])
        {
            return cache[propName];
        }
        else
        {
            var temp_data:XML = data.property.(@id == propName)[0];

			var type:String =  temp_data.@type != undefined ? temp_data.@type : "string";
            var value:* = type!= "xml" && type != "xmlList" ? TypeHelperUtil.getType(temp_data.toString(), type) : type === "xml" ? temp_data : temp_data.children();
			cache[propName] = value;

            return value;
        }
    }
	
	
	public function trySetting(propName:String, defaultVal:*):* {
		 if (cache[propName])
        {
            return cache[propName];
        }
        else
        {
            var temp_data:XML = data.property.(@id == propName)[0];
			if (temp_data == null) return defaultVal;
			var type:String =  temp_data.@type != undefined ? temp_data.@type : "string";
            var value:* = type!= "xml" && type != "xmlList" ? TypeHelperUtil.getType(temp_data.toString(), type) : type === "xml" ? temp_data : temp_data.children();
			cache[propName] = value;

            return value;
        }
	}

    public function get data():XML
    {
        return _data;
    }

    public function set data(data:XML):void
    {
        _data = data;
    }
}
}

class SingletonEnforcer
{
}