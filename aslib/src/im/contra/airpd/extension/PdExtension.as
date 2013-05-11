////////////////////////////////////////////////////////////////////////////////
//  
// Copyright (c) 2013 Contra.
// More information see the file "LICENSE.txt". 
//
////////////////////////////////////////////////////////////////////////////////
package im.contra.airpd.extension
{
	
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	
	public class PdExtension extends EventDispatcher implements IPdBase
	{
		
		private static var _instance:PdExtension;
		private var _ext:ExtensionContext;
		
		public static function getInstance():PdExtension 
		{
			if (!_instance) 
			{
				_instance = new PdExtension();
			}
			
			return _instance;
		}
		
		public function PdExtension() 
		{
			super();
			
			if(_instance)
			{
				throw new Error("PdExtension is singleton");
			}
			
			
			
			_ext = ExtensionContext.createExtensionContext("im.contra", "");
			
			if (!_ext) 
			{
				throw new Error("native extension is not supported on this platform.");
			}
			
			_ext.addEventListener(StatusEvent.STATUS, onPdMessage, false, 0, true);
		}
		
		public function init(numInChannels:int, numOutChannels:int, sampleRate:int):Boolean
		{
			return _ext.call("init", numInChannels, numOutChannels, sampleRate) as Boolean;
		}
		
		public function clear():void
		{
			_ext.call("clear");
		}
		
		public function addToSearchPath(path:String):void
		{
			_ext.call("addToSearchPath", path);
		}
		
		public function clearSearchPath():void
		{
			_ext.call("clearSearchPath");
		}
		
		public function openPatch(patchName:String, path:String):Object
		{
			return _ext.call("openPatch", patchName, path);
		}
		
		/*	public function openPatch(patch:File):Object
		{
		return _ext.call("openPatch", patch);
		}*/
		
		public function closePatch(patchName:String):void
		{
			_ext.call("closePatch", patchName);
		}
		
		public function processRaw(inBuffer:Vector.<Number>, outBuffer:Vector.<Number>):Boolean
		{
			return _ext.call("processRaw", inBuffer, outBuffer) as Boolean;
		}
		
		public function processShort(ticks:int, inBuffer:Vector.<int>, outBuffer:Vector.<int>):Boolean
		{
			return _ext.call("processShort", ticks, inBuffer, outBuffer) as Boolean;
		}
		
		public function processFloat(ticks:int, inBuffer:Vector.<Number>, outBuffer:Vector.<Number>):*
		{
			return _ext.call("processFloat", ticks, inBuffer, outBuffer);
		}
		
		public function processDouble(ticks:int, inBuffer:Vector.<Number>, outBuffer:Vector.<Number>):Boolean
		{
			return _ext.call("processDouble", ticks, inBuffer, outBuffer) as Boolean;
		}
		
		public function computeAudio(state:Boolean):void
		{
			_ext.call("computeAudio", state);
		}
		
		public function subscribe(source:String):void
		{
			_ext.call("subscribe", source);
		}
		
		public function unsubscribe(source:String):void
		{
			_ext.call("unsubscribe", source);
		}
		
		public function exists(source:String):Boolean
		{
			return _ext.call("exists", source) as Boolean;
		}
		
		public function unsubscribeAll():void
		{
			_ext.call("unsubscribeAll");
		}
		
		public function get numMessages():int
		{
			return _ext.call("numMessages") as int;
		}
		
		public function get nextMessage():Object
		{
			return _ext.call("nextMessage");
		}
		
		public function clearMessages():void
		{
			_ext.call("clearMessages");
		}
		
		public function pollPdMessageQueue():void
		{
			_ext.call("pollPdMessageQueue");
		}
		
		public function setReceiver(receiver:Object):void
		{
			_ext.call("setReceiver", receiver);
		}
		
		public function sendBang(dest:String):void
		{
			_ext.call("sendBang", dest);
		}
		
		public function sendFloat(dest:String, num:Number):void
		{
			_ext.call("sendFloat", dest, num);
		}
		
		public function sendSymbol(dest:String, symbol:String):void
		{
			_ext.call("sendSymbol", dest, symbol);
		}
		
		public function startMessage():void
		{
			_ext.call("startMessage");
		}
		
		public function addFloat(num:Number):void
		{
			_ext.call("addFloat", num);
		}
		
		public function addSymbol(symbol:String):void
		{
			_ext.call("addSymbol", symbol);
		}
		
		public function finishList(dest:String):void
		{
			_ext.call("finishList", dest);
		}
		
		public function finishMessage(dest:String, msg:String):void
		{
			_ext.call("finishMessage", dest, msg);
		}
		
		public function sendList(dest:String, list:Array):void
		{
			_ext.call("finishMessage", dest, list);
		}
		
		public function sendMessage(dest:String, msg:String, list:Array):void
		{
			_ext.call("sendMessage", dest, msg, list);
		}
		
		public function callFunc(funcName:String, ...args):Object
		{
			return this._ext.call(funcName, args);
		}
		
		
		/**
		 * Cleans up the instance of the native extension. 
		 */		
		public function dispose():void 
		{ 
			_ext.dispose(); 
		}
		
		private function onPdMessage(e:StatusEvent):void
		{
			this.dispatchEvent(e);
		}
		
	}
}