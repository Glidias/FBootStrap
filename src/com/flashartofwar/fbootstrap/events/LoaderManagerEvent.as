/**
 * <p>Original Author:  jessefreeman</p>
 * <p>Class File: LoaderManagerEvent.as</p>
 *
 * <p>Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:</p>
 *
 * <p>The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.</p>
 *
 * <p>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.</p>
 *
 * <p>Licensed under The MIT License</p>
 * <p>Redistributions of files must retain the above copyright notice.</p>
 *
 * <p>Revisions<br/>
 *     2.0  Initial version Jan 7, 2009</p>
 * 
 * 	   2.x  Sep 9, 2010 - (Glidias) Made event specific to my BootStrap implementation (supports bulk percentage loading)
 *
 */

package com.flashartofwar.fbootstrap.events
{
	
import flash.events.Event;

public class LoaderManagerEvent extends Event
{

    public static const COMPLETE:String = "complete";
    public static const LOADED:String = "loaded";
    public static const PRELOAD_DONE:String = "preload_done";
    public static const PRELOAD_NEXT:String = "preload_next";
    public static const PROGRESS:String = "progress";

	public var progressRatio:Number = 1;
	
    /**
     * <p>Used by the LoadManager.</p>
     *
     * @param type
     * @param eventData
     * @param bubbles
     * @param cancelable
     *
     */
    public function LoaderManagerEvent(type:String, progressRatio:Number = 1, bubbles:Boolean = false, cancelable:Boolean = false)
    {
        super(type, bubbles, cancelable);
		this.progressRatio = progressRatio;
    }
	
	public override function clone():Event 
	{ 
		return new LoaderManagerEvent(type, progressRatio, bubbles, cancelable);
	} 
		
	public override function toString():String 
	{ 
		return formatToString("LoaderManagerEvent", "type", "bubbles", "cancelable", "progressRatio"); 
	}
}
}