////////////////////////////////////////////////////////////////////////////////
//  
// Copyright (c) 2013 Contra.
// More information see the file "LICENSE.txt". 
//
////////////////////////////////////////////////////////////////////////////////
package  im.contra.airpd.extension
{
	

	public interface IPdBase
	{
		/// \section Initializing Pd
		
		/// initialize resources and set up the audio processing
		///
		/// set the audio latency by setting the libpd ticks per buffer:
		/// ticks per buffer * lib pd block size (always 64)
		///
		/// ie 4 ticks per buffer * 64 = buffer len of 512
		///
		/// the lower the number of ticks, the faster the audio processing
		/// if you experience audio dropouts (audible clicks), increase the
		/// ticks per buffer
		///
		/// return true if setup successfully
		///
		/// note: must be called before processing
		///
		function init(numInChannels:int, numOutChannels:int, sampleRate:int):Boolean;
		
		/// clear resources
		function clear():void;
		
		/// \section Adding Search Paths
		
		/// add to the pd search path
		/// takes an absolute or relative path (in data folder)
		///
		/// note: fails silently if path not found
		///
		function addToSearchPath(path:String):void;
		
		/// clear the current pd search path
		function clearSearchPath():void;
		
		/// \section Opening Patches
		
		/// open a patch file (aka somefile.pd) in a specified path
		/// returns a Patch object
		///
		/// use Patch::isValid() to check if a patch was opened successfully:
		///
		/// Patch p1 = pd.openPatch("somefile.pd", "/some/path/");
		/// if(!p1.isValid()) {
		///     cout << "aww ... p1 couldn't be opened" << endl;
		/// }
		function openPatch(patchName:String, path:String):Object;//virtual pd::Patch 
		
		/// open a patch file using the filename and path of an existing patch
		///
		/// set the filename within the patch object or use a previously opened
		/// object
		///
		/// // open an instance of "somefile.pd"
		/// Patch p2("somefile.pd", "/some/path");    // set file and path
		/// pd.openPatch(p2);
		///
		/// // open a new instance of "somefile.pd"
		/// Patch p3 = pd.openPatch(p2);
		///
		/// // p2 and p3 refer to 2 different instances of "somefile.pd"
		///
//		function openPatch(patch:File):Object;//pd::Patch 
		
		/// close a patch file
		/// takes only the patch's basename (filename without extension)
		function closePatch(patchName:String):void;
		
		/// close a patch file, takes a patch object
		/// note: clears the given Patch object
	//	function closePatch(pd::Patch& patch);
		
		/// \section Audio Processing
		
		/// main process callbacks
		///
		/// one of these must be called for audio dsp and message computation to occur
		///
		/// processes one pd tick, writes raw data to buffers
		///
		/// inBuffer must be an array of the right size, never null
		/// use inBuffer = new type[0] if no input is desired
		///
		/// outBuffer must be an array of size outBufferSize from openAudio call
		/// returns false on error
		///
		/// note: raw does not interlace the buffers
		///
		function processRaw(inBuffer:Vector.<Number>, outBuffer:Vector.<Number>):Boolean;
		function processShort(ticks:int, inBuffer:Vector.<int>, outBuffer:Vector.<int>):Boolean;
		function processFloat(ticks:int, inBuffer:Vector.<Number>, outBuffer:Vector.<Number>):*;
		function processDouble(ticks:int, inBuffer:Vector.<Number>, outBuffer:Vector.<Number>):Boolean;
		
		/// \section Audio Processing Control
		
		/// start/stop audio processing
		///
		/// note: in general, once started, you won't need to turn off audio processing
		///
		/// shortcut for [; pd dsp 1( & [; pd dsp 0(
		///
		function computeAudio(state:Boolean):void;
		
		//// \section Message Receiving
		
		/// subscribe/unsubscribe to source names from libpd
		///
		/// aka the pd receive name
		///
		/// [r source]
		/// |
		///
		function subscribe(source:String):void;
		function unsubscribe(source:String):void;
		function exists(source:String):Boolean; ///< is a receiver subscribed?
		function unsubscribeAll():void; ///< receivers will be unsubscribed from *all* sources
		
		/// poll for messages
		///
		/// by default, PdBase receieves print, event, and midi messages into a FIFO
		/// queue which can be polled
		///
		/// while(pd.numMessages() > 0) {
		///        pd::Message& msg = pd.nextMessage(&msg);
		///
		///        switch(msg.type) {
		///            case PRINT:
		///                cout << got print: " << msg.symbol << endl;
		///                break;
		///            case BANG:
		///                cout << "go a bang to " << msg.dest << endl;
		///                break;
		///            case NOTE_ON:
		///                cout << "got a note on " << msg.channel
		///                     << msg.pitch << " " << msg.velocity << endl;
		///                break;
		///            ...
		///        }
		///    }
		///
		/// if you set a PdReceiver callback receiver, then event messages will
		/// not be added to the queue
		///
		/// the same goes for setting a PdMidiReceiver regarding midi messages
		///
		/// if the message queue is full, the oldest message will be dropped
		/// see setMaxQueueLen()
		
		function pollPdMessageQueue():void;
		
		/// returns the number of waiting messages in the queue
		function get numMessages():int;
		
		/// get the current waiting message
		///
		/// copies current message into given message object
		///
		/// returns true if message was copied, returns false if no message
		function get nextMessage():Object;//pd::Message& 
		
		/// clear currently waiting messages
		function clearMessages():void;
		
		/// \section Event Receiving via Callbacks
		
		/// set the incoming event receiver, disables the event queue
		///
		/// automatically receives from all currently subscribed sources
		///
		/// set this to NULL to disable callback receiving and reenable the
		/// event queue
		///
		function setReceiver(receiver:Object):void;//pd::PdReceiver* 
		
		/// \section Midi Receiving via Callbacks
		
		/// set the incoming midi event receiver, disables the midi queue
		///
		/// automatically receives from all midi channels
		///
		/// set this to NULL to disable midi events and reenable the midi queue
		///
	//	void setMidiReceiver(pd::PdMidiReceiver* midiReceiver);
		
		/// \section Sending Functions
		
		/// messages
		function sendBang(dest:String):void;
		function sendFloat(dest:String, num:Number):void;
		function sendSymbol(dest:String, symbol:String):void;
		
		/// compound messages
		///
		/// pd.startMessage();
		/// pd.addSymbol("hello");
		/// pd.addFloat(1.23);
		/// pd.finishList("test");  // "test" is the reciever name in pd
		///
		/// sends [list hello 1.23( -> [r test],
		/// you will need to use the [list trim] object on the reciving end
		///
		/// finishMsg sends a typed message -> [; test msg1 hello 1.23(
		///
		/// pd.startMessage();
		/// pd.addSymbol("hello");
		/// pd.addFloat(1.23);
		/// pd.finishMessage("test", "msg1");
		///
		function startMessage():void;
		function addFloat(num:Number):void;
		function addSymbol(symbol:String):void;
		function finishList(dest:String):void;
		function finishMessage(dest:String, msg:String):void;
		
		/// compound messages using the PdBase List type
		///
		/// List list;
		/// list.addSymbol("hello");
		/// list.addFloat(1.23);
		/// pd.sendList("test", list);
		///
		/// sends [list hello 1.23( -> [r test]
		///
		/// clear the list:
		///
		/// list.clear();
		///
		/// stream operators work as well:
		///
		/// list << "hello" << 1.23;
		/// pd.sendMessage("test", "msg1", list);
		///
		/// sends a typed message -> [; test msg1 hello 1.23(
		///
		function sendList(dest:String, list:Array):void;
		function sendMessage(dest:String, msg:String, list:Array):void;
	}
}