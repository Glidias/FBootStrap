Hello, 

Welcome to FBootStrap, this is a simple library to help load in core
assets to your Flash Application such as a config files, external
resources, and other useful utilities.

**Right now FBootStrap relies on a certain utility class found in 
the F*CSS's library (http://github.com/theflashbum/fcss), known as TypeHelperUtil.
A SWC version of this library can be found in the build/libs/ directory.** 

Understanding the config file

This is a basic config file:

<?xml version="1.0" encoding="UTF-8"?>
<config>
    <uris handler="parseURIs">
        <uri name="css"><![CDATA[css/${filename}.css]]></uri>
        <uri name="xml"><![CDATA[xml/${filename}.xml]]></uri>
        <uri name="swf"><![CDATA[${filename}.swf]]></uri>
        <uri name="scripts"><![CDATA[somedomain.com/scripts/${filename}.php]]></uri>
        <uri name="twitter_id"><![CDATA[twitter.com/home?status=somedomain.com/?id=${id}]]></uri>
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
the file-paths/file-extensions conventionally used in your application. For example, 
to remotely retrieve a resultant url with token replacement, you can do something like: 
--

var url:String = URIManager.instance.getURI("twitter_id", {id:"20"});
// Result is: "twitter.com/home?status=somedomain.com/?id=20"
// from: <uri name="twitter_id"><![CDATA[twitter.com/home?status=somedomain.com/?id=${id}]]></uri>
// The token is usually some object in 2nd parameter with a string key to replace ${string} values
// ...multiple token-string-key replacement is also supported.


Resources  (loadResources)
Conventionally for FBootStrap, we use a single "${filename}" token for file name replacement 
for the resource manager. As a result of using URIs, the resource file nodes passed into the 
resource manager in FBootStrap need only to specify the bare file name with a given uri format.
eg.
<file name="styles" uri="css" type="urlloader"/>
// results in: css/styles.css
// from: <uri name="css"><![CDATA[css/${filename}.css]]></uri>

Settings  (parseSettings)
This helps store serialized values into the SettingsManager. The string values in the xml
are serialized into strictly-typed values with the help of F*CSS based on the "type" attribute.
For more information on what type of serializable data types are available 
(and how you can register your own custom functions to serialize your own data types), 
check out:
http://github.com/theflashbum/fcss/blob/master/src/com/flashartofwar/fcss/utils/TypeHelperUtil.as

You can retrieve your settings remotely like:
--
var colorToUse:uint = SettingsManager.instance.siteColor. 
// results in: 0xffccdd
// from: <property id="siteColor" type="uint">#ffccdd</property>

As you can see, SettingsManager.instance is a dynamic proxy object that allows you to get properties 
dynamically as shown above. Note, however, that you can't write values directly into the 
SettingsManager.instance (ie. it'll have no effect) so it's safe and your boot settings
won't change during your application.


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
bootstrap.loadConfig("config.xml");

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
Since the ResourceManager class itself isn't a singleton, it can be used for other separate utility purposes
(if you so wish) to batch load other resource-queues. (basically 1 ResourceManager instance per queue).

Note that the ResourceManager inside FBootStrap, however, is mapped as a singleton inside the Fbootstrap's
SingletonManager and can be remotely accessed using the following method:

import com.flashartofwar.fbootstrap.managers.SingletonManager;

var resManager:ResourceManager = SingletonManager.getClassReference(ResourceManager);


Which leads us to retrieving resources...

Retrieving resources:
---------------------
FBootStrap in this fork supports registering file id attributes to the XML nodes for
used to add resources to the ResourceManager.
For example:
<file id="customPage" name="custom_page" uri="swf" type="loader"  />

Just give a unique id to each file node. If no id attribute is specified,
the full resultant url (ie. the entire parsed uri with file name ) will be used.
In most cases, you SHOULD provide a unique id to uniquely identify your file resource.

To get your resources via the singleton approach:

import com.flashartofwar.fbootstrap.managers.SingletonManager;
// strictly typed
var resManager:ResourceManager = SingletonManager.getClassReference(ResourceManager);
var pageSpr:Sprite = resManager.getResource("customPage");

-or-

// untyped
private var page:Sprite = SingletonManager.getClassReference(ResourceManager).getResource("customPage');


Dependency Injection:
----------------------
If you don't like to remotely retrieve settings/resources 
through Flash Art-Of-War's SettingsManager/ResourceManager's singleton-approach,
, metadata dependency injection can be used in other frameworks like RobotLegs/SwiftSuspenders
by mapping the name/id serialized values beforehand in an overwritten "parseSettings" method or
once loading of assets for the ResourceManager has finished. 
An example can be found here:
(link to be included)

As a result, metadata can be used to mark class member variable settings like:
<!-- XML config node -->
<property id="siteColor" type="uint">#ffccdd</property>
// to
[Inject("siteColor")]
public var siteColorToUse:uint;

or

<!-- XML config node -->
<file id="customPage" name="custom_page" type="loader" uri="swf" class="com.project.pages.MyCustomPage" />
// to
[Inject("customPage")]
public var myCustomPage:MyCustomPage;

to mark required configuration dependencies which the injector would automatically supply
to the given instantiated class.

For more information on RobotLegs or SwiftSuspenders:
http://www.robotlegs.org/
http://github.com/tschneidereit/SwiftSuspenders

-----------------

That's all for now. For better improvements/fixes to any of the utilities found here. Feel free to fork again as always.
