Hello, 

Welcome to FBootStrap, this is a simple library to help load in core
assets to your Flash Application such as a config files, external
resources, and other useful utilities.

**Right now FBootStrap is dependant on F*CSS's (http://github.com/theflashbum/fcss)
Type utility. A SWC version of this can be found in the build/libs/ directory.** 

Understanding the config file

This is a basic config file:

<code>
<?xml version="1.0" encoding="UTF-8"?>
<config>
    <uris handler="parseURIs">
        <uri name="css"><![CDATA[css/${filename}.css]]></uri>
        <uri name="xml"><![CDATA[xml/${filename}.xml]]></uri>
        <uri name="swf"><![CDATA[${filename}.swf]]></uri>
        <uri name="scripts"><![CDATA[http://www.somedomain.com/scripts/${filename}.php]]></uri>
        <uri name="twitter_id"><![CDATA[http://www.twitter.com/home?status=http://www.somedomain.com/?id=${id}]]></uri>
    </uris>
    <resources handler="loadResources">
        <file name="styles" uri="css" type="urlloader"/>
        <file name="decalsheet" uri="xml" type="urlloader"/>
        <file name="assets" uri="swf" type="loader" >
        <file name="getlistings" uri="scripts" type="urlloader" >
    </resources>
    <settings handler="parseSettings">
        <property id="version" type="string"><![CDATA[1.0.0]]></property>
        <property id="debug" type="boolean">true</property>
        <property id="siteColor" type="uint">#ffccdd</property>
    </settings>
</config>
</code>

As you can see in this example the config is broken down into 3 parts: uris,
settings, and resources. You can add any "data block" you would like. Each
block is mapped to a method (in the handler node attribute) which handles
automatically passing the xml block to an instance method in the FBootStrap class.

You can extend the FBootStrap class and create more of your own method handlers to 
parse any custom xml blocks specific to your application (or you can strip the class
apart and use only the tools/managers you need).

These 3 handles are built into the library. Lets talk about each one.

URIs (parseURIs)
 A uniform resource indicator (URI) is like a url format you can specify to determine 
the file-path and file-extension conventionally used in your application. For example, 
to remotely retrieve a result url with token replacement, you can do something like: 
var url:String = URIManager.instance.getURI("twitter_id", {id:someIdFromApplication});
// The token is usually some object in 2nd parameter with a string key to replace ${string} values
// ...multiple token-string-key replacement is also supported.

Resources  (loadResources)
Conventionally for FBootStrap, we use a single "${filename}" token for file name replacement 
for the resource manager. As a result of using URIs, the resource file nodes passed into the 
resource manager in FBootStrap need only to specify the bare file name with a given uri format.

Settings  (parseSettings)
This helps store serialized values into the SettingsManager. The string values in the xml
are serialized into strictly-typed values with the help of F*CSS based on the "type" attribute.
For more information on what type of serializable data types are available 
(and how you can register your own custom functions to serialize your own data types), 
check out:
http://github.com/theflashbum/fcss/blob/master/src/com/flashartofwar/fcss/utils/TypeHelperUtil.as

You can retrieve your settings remotely like:
var colorToUse:uint = SettingsManager.instance.siteColor. 
// SettingsManager.instance is a dynamic proxy object that allows you to get properties 
// dynamically as shown above:
// ...note that you can't write values directly into the SettingsManager.instance though.


Instantiating the FBootStrap:
-----------------------------

FBootStrap is designed to be simple to use. Currently there is only one event
which signals when the boot process is complete. Lets take a look at an example:

------------------------------------------------------------------------------------

// You can optionally use the SingletonManager to make sure there is only one instance 
// of the BootStrap
var bootstrap:BootStrap = SingletonManager.getClassReference(BootStrap);

// Add an event listener for complete
bootstrap.addEventListener(BootstrapEvent.COMPLETE, onBootStrapComplete);

// Load in a config xml
bootstrap.loadConfig(_configURL);

------------------------------------------------------------------------------------

Bulk Percentage Loading (com.flashartofwar.fbootstrap.managers.ResourceManager):
----------------------------------------
This fork contains additional code to handle approximate bulk percentage loading of assets.
By default, all assets in a resource manager are treated to be of equal load size.
But a "perc" attribute can be used to specify biased load size percentage ratios for certain
assets.
For example:

    <resources handler="loadResources">
        <file name="styles" uri="css" type="urlloader"/>
        <file name="decalsheet" uri="xml" type="urlloader"/>
        <file name="assets" uri="swf" type="loader" perc=".6">
        <file name="getlistings" uri="scripts" type="urlloader" perc=".2" >
    </resources> 

In the example above, the last 2 files have declared percentages amounting up to 0.8. This leaves
behind 0.2, which is divided equally among the remaining (undeclared) assets, resulting in 0.1
each for the first 2 files. This allows users to customize the rough file size ratios per load.

If declared percentages exceed a value of 1 or the remaining divided percentages can't be divided
up into sizable ratios, an error is thrown to indicate the perc results.

To listen for progress ratio events:

bootstrap.addEventListener(LoaderManagerEvent.PROGRESS, onBootLoaderProgress);

function onBootLoaderProgress(e:LoaderManagerEvent):void {
  someSitePreloader.updatePreloader( e.progressRatio );  // a progress ratio between 0 - 1
}

Actually, LoaderManagerEvent.PROGRESS event is dispatched from the ResourceManager class itself, 
and is simply bubbled from the current FBootStrap instance.
Since the ResourceManager class isn't a singleton, it can be used for other separate utility purposes
(if you so wish) to batch load other resource-queues. (basically 1 ResourceManager per queue).

Dependency Injection:
----------------------
If you don't like to remotely retrieve settings through the Flash Art-Of-War's SettingsManager,
, metadata dependency injection can be used in other frameworks like RobotLegs/SwiftSuspenders
by mapping the named serialized values beforehand in an overwritten "parseSettings" method. 
An example can be found here:
(link to be included)

As a result, metadata can be used to mark class member variables like:

[Inject("siteColor")]
public var siteColorToUse:uint;

to mark required configuration dependencies which the injector would automatically supply
to the given instantiated class.

For more information on RobotLegs or SwiftSuspenders:
http://www.robotlegs.org/
http://github.com/tschneidereit/SwiftSuspenders

-----------------

That's all for now. For better improvements/fixes to any of the utilities found here. Feel free to fork again as always.
